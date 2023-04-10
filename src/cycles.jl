function Simple_Throttle(State_1, State_9, Gas, P_mix, Q_L)
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

    return m_dot_1, work, CoP
end

function Simple_Turbine(State_1, State_9, Gas, P_mix, Q_L)
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

    return m_dot_1, work, CoP
end

function SPECTRE(State_1, State_9, Gas, P_mix, Q_L)
    
    T_evap = State_1.T
    P_evap = State_1.P 
    T_cond = State_9.T
    P_cond = State_9.P


    State_2 = nozzle(State_9, State_1, Gas["Mix"], P_mix);
    State_4 = diffuser(State_9.h, State_1.h, State_2, Gas["Mix"], Gas["Dif"], P_mix)
    State_5, State_7 = vapor_seperator(State_4, Gas["Dif"])
    State_6 = throttle(State_5, Gas["Throttle"], T_evap)
    State_8 = compressor(State_7, Gas["Comp"], P_cond)
    State_9_prime = condensor(State_8, Gas["Cond"], T_cond)
    State_1_prime = evaporator(State_6, Gas["Evap"])

    m_dot_1 = mass_flow_rate_1(Q_L, State_6, State_1_prime)
    m_dot_9 = mass_flow_rate_9(m_dot_1, State_4)
    work = work_in(State_7, State_8, m_dot_9)
    CoP = COP(Q_L, work)

    return m_dot_1, m_dot_9, work, CoP
end