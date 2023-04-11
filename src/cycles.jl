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

    m_dot_1 = mass_flow_rate_1(Q_L, State_4, State_1_prime)
    work = work_in(State_1, State_2, m_dot_1)
    CoP = COP(Q_L, work)
    Q_H = Q_out(State_2, State_3, m_dot_1)

    S_throttle = m_dot_1 * S_gen(State_4, State_3)
    S_condensor = m_dot_1 * S_gen(State_3, State_2, Q=Q_H, T=T_H)
    S_evaporator = m_dot_1 * S_gen(State_1_prime, State_4, Q=-Q_L, T=T_L)

    S_gen_total = S_throttle + S_condensor + S_evaporator
    
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

    m_dot_1 = mass_flow_rate_1(Q_L, State_4, State_1_Prime)
    work = work_in_turb(State_1, State_2, State_3, State_4, m_dot_1)
    CoP = COP(Q_L, work)
    Q_H = Q_out(State_2, State_3, m_dot_1)

    S_condensor = m_dot_1 * S_gen(State_3, State_2, Q=Q_H, T=T_H)
    S_evaporator = m_dot_1 * S_gen(State_1_Prime, State_4, Q=-Q_L, T=T_L)

    S_gen_total = S_condensor + S_evaporator
    
    Ψ = T_H * S_gen_total
    
    return m_dot_1, work, CoP, Ψ
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

    m_dot_1 = mass_flow_rate_1(Q_L, State_6, State_1_prime)
    m_dot_9 = mass_flow_rate_9(m_dot_1, State_4)
    work = work_in(State_7, State_8, m_dot_9)
    CoP = COP(Q_L, work)
    Q_H = Q_out(State_8, State_9_prime, m_dot_9)

    S_throttle = m_dot_1 * S_gen(State_6, State_5)
    S_condensor = m_dot_9 * S_gen(State_9_prime, State_8, Q=Q_H, T=T_H)
    S_evaporator = m_dot_1 * S_gen(State_1_prime, State_6, Q=-Q_L, T=T_L)
    S_mixer = ((m_dot_1 + m_dot_9) * State_4.s) - (m_dot_9 * State_9.s) - (m_dot_1 * State_1.s)

    S_gen_total = S_throttle + S_condensor + S_evaporator + S_mixer

    
    Ψ = T_H * S_gen_total

    V_1 = V[2]
    V_2 = V[1]
    #println("Velocity: ", V[2], " ", V[1])

    return m_dot_1, m_dot_9, work, CoP, Ψ, V_1, V_2
end