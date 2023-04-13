using Plots

function Simple_Throttle(State_1, State_9, Gas, P_mix, Q_L, T_L, T_H)
    T_evap = State_1.T
    P_evap = State_1.P 
    T_cond = State_9.T
    P_cond = State_9.P

    State_1 = State(T_evap, P_evap, h_evap, s_evap, 1.0);
    State_2 = compressor(State_1, Gas["Comp"], P_cond);
    State_3 = condensor(State_2, Gas["Cond"], T_cond);
    State_4 = throttle(State_3, Gas["Throttle"], T_evap);
    State_1_prime = evaporator(State_4, Gas["Evap"]);

    state_vec = [State_1, State_2, State_3, State_4, State_1_prime]
    print_table(state_vec)


    m_dot_1 = mass_flow_rate_1(Q_L, State_4, State_1_prime)
    work = work_in(State_1, State_2, m_dot_1)
    CoP = COP(Q_L, work)
    Q_H = Q_out(State_2, State_3, m_dot_1)

    S_throttle = S_gen(m_dot_1, State_4, State_3)
    S_condensor  = S_gen(m_dot_1, State_3, State_2, Q=Q_H, T=T_H)
    S_evaporator = S_gen(m_dot_1, State_1_prime, State_4, Q=-Q_L, T=T_L)
    S_gen_total = S_throttle + S_condensor + S_evaporator

    sgen_vec = T_H .*[S_gen_total, S_evaporator, S_condensor, S_throttle]

    print_sgen(sgen_vec)
    
    Ψ = T_H * S_gen_total

    return m_dot_1, work, CoP, Ψ
end

function Simple_Turbine(State_1, State_9, Gas, P_mix, Q_L, T_L, T_H)
    T_evap = State_1.T
    P_evap = State_1.P 
    T_cond = State_9.T
    P_cond = State_9.P

    State_1 = State(T_evap, P_evap, h_evap, s_evap, 1.0);
    State_2 = compressor(State_1, Gas["Comp"], P_cond);
    State_3 = condensor(State_2, Gas["Cond"], T_cond);
    State_4 = turbine(State_3, Gas["Throttle"], T_evap);
    State_1_Prime = evaporator(State_4, Gas["Evap"]);

    state_vec = [State_1, State_2, State_3, State_4, State_1_Prime]
    print_table(state_vec)
    #println("Enthalpy check: ", State_1.h, " ", State_1_Prime.h) #Enthalpies are consistent

    m_dot_1 = mass_flow_rate_1(Q_L, State_4, State_1_Prime)
    work = work_in_turb(State_1, State_2, State_3, State_4, m_dot_1)
    CoP = COP(Q_L, work)
    Q_H = Q_out(State_2, State_3, m_dot_1)

    S_condensor  = S_gen(m_dot_1, State_3, State_2, Q=Q_H, T=T_H)
    S_evaporator = S_gen(m_dot_1, State_1_Prime, State_4, Q=-Q_L, T=T_L)

    S_gen_total = S_condensor + S_evaporator
    sgen_vec = T_H .*[S_gen_total, S_evaporator, S_condensor]

    print_sgen(sgen_vec)

    
    Ψ = T_H * S_gen_total
    
    return m_dot_1, work, CoP, Ψ, state_vec
end


function SPECTRE(State_1, State_9, Gas, P_mix, Q_L, T_L, T_H)
    
    T_evap = State_1.T
    P_evap = State_1.P 
    T_cond = State_9.T
    P_cond = State_9.P

    State_2 = nozzle(State_9, State_1, Gas["Mix"], P_mix);
    State_4, V = diffuser(State_9.h, State_1.h, State_2, Gas["Mix"], Gas["Dif"], P_mix)
    State_5, State_7 = vapor_seperator(State_4, Gas["Dif"])
    State_6 = throttle(State_5, Gas["Throttle"], T_evap)
    State_8 = compressor(State_7, Gas["Comp"], P_cond)
    State_9_prime = condensor(State_8, Gas["Cond"], T_cond)
    State_1_prime = evaporator(State_6, Gas["Evap"])

    #println("State 4: ", State_4.P, " ", State_4.T, " ", State_4.h, " ", State_4.s, " ", State_4.X)
    
    state_vec = [State_1, State_4, State_5, State_6, State_7, State_8, State_9_prime, State_1_prime]
    print_table(state_vec)
    
    m_dot_1 = mass_flow_rate_1(Q_L, State_6, State_1_prime)
    m_dot_9 = mass_flow_rate_9(m_dot_1, State_4)
    work = work_in(State_7, State_8, m_dot_9)
    CoP = COP(Q_L, work)
    Q_H = Q_out(State_8, State_9_prime, m_dot_9)

    println("+========================================+")
    println("     The Great Component Debug         ")
    println("\nNozzle")
    println("e_in: ", m_dot_1*State_1.h + m_dot_9*State_9.h); e_in = m_dot_1*State_1.h + m_dot_9*State_9.h
    println("e_out: ", m_dot_1*(State_2[1] + 0.5*V[1]^2) + m_dot_9*(State_2[2] + 0.5*V[2]^2)); e_out = m_dot_1*(State_2[1] + 0.5*V[1]^2) + m_dot_9*(State_2[2] + 0.5*V[2]^2)
    println("delta e: ", e_in - e_out)
    println("Relative %: ", 100 * (e_in - e_out) / (0.5 * (e_in + e_out)))
    println("+========================================+")

    S_throttle = S_gen(m_dot_1, State_6, State_5)
    S_condensor = S_gen(m_dot_9, State_9_prime, State_8, Q=Q_H, T=T_H)
    S_evaporator = S_gen(m_dot_1, State_1_prime, State_6, Q=-Q_L, T=T_L)

    S_mixer = ((m_dot_1 + m_dot_9) * State_4.s) - (m_dot_9 * State_9.s + m_dot_1 * State_1.s) # therefore, issue is in the entropy of 

    S_gen_total = S_throttle + S_condensor + S_evaporator + S_mixer
    #S_gen_total = S_throttle + S_mixer

    sgen_vec = T_H .*[S_gen_total, S_evaporator,S_condensor, S_throttle,  S_mixer]
    #print_sgen(sgen_vec)

    
    Ψ = T_H * S_gen_total

    V_1 = V[1]
    V_2 = V[2]
    V_3 = V[3]
    #V_2 = State_4.P
    #println("Velocity: ", V[2], " ", V[1])

    println("+========================================+")
    println("     The Great Consveration Debug         ")
    println("m_dot_1: ", m_dot_1)
    println("m_dot_9: ", m_dot_9)
    println("m_dot_total: ", m_dot_1 + m_dot_9)
    println("v_2,i: ", V_1)
    println("v_2,o: ", V_2)
    println("v_3: ", V_3)
    println("\nMomentum Conservation")
    println("p_in: ", m_dot_1*V_1 + m_dot_9*V_2); p_in = m_dot_1*V_1 + m_dot_9*V_2
    println("p_out: ", (m_dot_1 + m_dot_9)*V_3); p_out = (m_dot_1 + m_dot_9)*V_3
    println("delta p: ", p_in - p_out)
    println("Relative %: ", -100 * (p_in - p_out)/(0.5 * (p_out + p_in)))
    println("\nEnergy Conservation (1,9) -> 4")
    println("e_in: ", m_dot_1*State_1.h + m_dot_9*State_9.h); e_in = m_dot_1*State_1.h + m_dot_9*State_9.h
    println("e_out: ", (m_dot_1 + m_dot_9)*State_4.h); e_out = (m_dot_1 + m_dot_9)*State_4.h
    println("delta e: ", e_in - e_out)
    println("Relative %: ", 100 * (e_in - e_out) / (0.5 * (e_in + e_out)))
    println("\nEnergy Conservation (Full Cycle)")
    println("e_in: ", Q_L + work); e_in = Q_L + work
    println("e_out: ", Q_H); e_out = Q_H
    println("delta e: ", e_in - e_out)
    println("Relative %: ", 100 * (e_in - e_out) / (0.5 * (e_in + e_out)))
    println("\nSecond Law Verification (1,9) -> 4")
    println("s_in: ", m_dot_1*State_1.s + m_dot_9*State_9.s); s_in = m_dot_1*State_1.s + m_dot_9*State_9.s
    println("s_out: ", (m_dot_1 + m_dot_9)*State_4.s); s_out = (m_dot_1 + m_dot_9)*State_4.s
    println("s_gen: ", s_out - s_in)
    println("Relative %: ", 100 * (s_out - s_in) / (0.5 * (s_in + s_out)))
    println("\nSecond Law Verification (Full Cycle)")
    println("s_in: ", Q_L / T_H); s_in = Q_L / T_H
    println("s_out: ", Q_H / T_H); s_out = Q_H / T_H
    println("s_gen: ", s_out - s_in)
    println("Valid s_gen: ", (s_out - s_in) > 0)
    println("+========================================+\n")

    return m_dot_1, m_dot_9, work, CoP, Ψ, state_vec #, V_1, V_2, V_3
end

function print_table(state_vec)
    println("+===================================+")
    println("         Entropy   Temperature Enthalpy")
    counter = 3
    for state ∈ state_vec
        println("State $counter: ", round(state.s; digits=3), "     ", round(state.T; digits=3), "     ", round(state.h; digits=3))
        counter += 1
    end
    println("+===================================+\n")
end
function print_sgen(sgen_vec)

    name = ["Ψ_gen_total", "Ψ_evaporator", "Ψ_mixer", "Ψ_throttle", "Ψ_condensor"]
    println("+===================================+")
    println("             Exergy")
    counter = 1
    for Ψ ∈ sgen_vec
        println(name[counter], ": ", Ψ)
        counter += 1
    end
    println("+===================================+\n")
end
