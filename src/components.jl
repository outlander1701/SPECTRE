include("utilities.jl")

function quality(Gas, P; h::Float64=-1.0, s::Float64=-1.0)

    search_index = 1
    for i ∈ eachindex(Gas["Pressure (MPa)"])
        if Gas["Pressure (MPa)"][i] == P
            search_index = i
        end
    end

    h_f = Gas["Enthalpy (l, kJ/kg)"][search_index];
    h_v = Gas["Enthalpy (v, kJ/kg)"][search_index];
    s_f = Gas["Entropy (l, J/g*K)"][search_index];
    s_v = Gas["Entropy (v, J/g*K)"][search_index];
    
    h_fg = h_v - h_f
    s_fg = s_v - s_f

    X = -42
    if h != -1
        X = (h - h_f)/h_fg
    else
        X = (s - s_f)/s_fg
    end

    return X
end


function nozzle(State_in_9, State_in_1, Gas, P_mix)
    s_i = State_in_9.s
    s_o = State_in_1.s
    P = P_mix

    N = length(Gas["Pressure (MPa)"]) + 1

    search_index = 1
    for i ∈ 1:N
        if (abs(Gas["Pressure (MPa)"][i] - P) < 0.001)
            search_index = i;
            break
        elseif (i == N)
            return println("Error: Value not found")
        end
    end

    s_f = Gas["Entropy (l, J/g*K)"][search_index];
    s_v = Gas["Entropy (v, J/g*K)"][search_index];
    h_f = Gas["Enthalpy (l, kJ/kg)"][search_index];
    h_v = Gas["Enthalpy (v, kJ/kg)"][search_index];

    X_i = (s_i - s_f)/(s_v - s_f)
    X_o = (s_o - s_f)/(s_v - s_f)

    h_i = h_f + X_i*(h_v - h_f)
    h_o = h_f + X_o*(h_v - h_f)
    
    
    return [h_i, h_o]
end


function diffuser(h_9, h_1, h, Gas_Mix, Gas_Diff, P_mix)

    P, X, h, s_4, search_index = Quality_Search(h_9, h_1, h, Gas_Mix, Gas_Diff, P_mix);
    
    T = Gas_Diff["Temperature (K)"][search_index];

    s = s_4

    return State(T, P, h, s, X)
end


function throttle(State_in, Gas, T_min)
    """
    Isoenthalpic throttle
    """
    h = State_in.h
    T = T_min

    P = Float64(Gas["Pressure (MPa)"][1])

    X = quality(Gas, P, h=h) 

    s_f = Gas["Entropy (l, J/g*K)"][1];
    s_v = Gas["Entropy (v, J/g*K)"][1];
    
    s = s_f + X*(s_v-s_f);


    return State(T, P, h, s, X)

end


function turbine(State_in, Gas, T_min)
    """
    Isoenthalpic throttle
    """
    s = State_in.s
    T = T_min

    P = Float64(Gas["Pressure (MPa)"][1])

    X = quality(Gas, P, s=s) 
    h_f = Gas["Enthalpy (l, kJ/kg)"][1];
    h_v = Gas["Enthalpy (v, kJ/kg)"][1];
    
    h = h_f + X*(h_v-h_f);


    return State(T, P, h, s, X)

end


function compressor(State_in, Gas, P_max) # Check for superheat
    """
    Isentropic compressor
    """
    s = State_in.s
    P = P_max # Check this
    X = 1

    search_index = 1
    N = length(Gas["Entropy (J/g*K)"]) + 1

    for i ∈ 1:N
        if (abs(Gas["Entropy (J/g*K)"][i] - s) < 0.001)
            search_index = i
            break
        elseif (i == N)
            return println("Error: Value not found")
        end 
    end

    T = Gas["Temperature (K)"][search_index]
    h = Gas["Enthalpy (kJ/kg)"][search_index]


    return State(T, P, h, s, X)
end


function evaporator(State_in, Gas)
    """
    Isobar Evaporator
    """
    P = State_in.P
    T = State_in.T
    X = 1

    search_index = 1
    for i ∈ eachindex(Gas["Pressure (MPa)"])
        if Gas["Pressure (MPa)"][i] == P
            search_index = i
        end
    end

    s = Gas["Entropy (v, J/g*K)"][search_index]
    h = Gas["Enthalpy (v, kJ/kg)"][search_index]

    return State(T, P, h, s, X)
end


function condensor(State_in, Gas, T_cond)
    """
    Isobar condensor
    """
    P = State_in.P
    T = T_cond
    X = 0

    search_index = 1
    for i ∈ eachindex(Gas["Pressure (MPa)"])
        if Gas["Pressure (MPa)"][i] == P
            search_index = i
        end
    end

    s = Gas["Entropy (l, J/g*K)"][search_index]
    h = Gas["Enthalpy (l, kJ/kg)"][search_index]

    return State(T, P, h, s, X)
end


function vapor_seperator(State_in, Gas) # Double check temperature
    """
    Vapor Seperator
    """
    P = State_in.P
    T = State_in.T

    search_index = 1
    for i ∈ eachindex(Gas["Pressure (MPa)"])  # 😸
        if Gas["Pressure (MPa)"][i] == P
            search_index = i
        end
    end

    h_f = Gas["Enthalpy (l, kJ/kg)"][search_index];
    s_f = Gas["Entropy (l, J/g*K)"][search_index];

    h_v = Gas["Enthalpy (v, kJ/kg)"][search_index];
    s_v = Gas["Entropy (v, J/g*K)"][search_index];

    return State(T, P, h_f, s_f, 0), State(T, P, h_v, s_v, 1)
end

function Diffuser_Enthalpy(x, v_2i, v_2o, h)
    """
    x = (m_1 / m_t)
    """
    
    h_2i = h[1]
    h_2o = h[2]

    v_3 = (1-x)*v_2i + (x)*v_2o
    h_3 = (1-x)*(h_2i + 0.5*(v_2i^2)) + (x)*(h_2o + 0.5*(v_2o^2)) - 0.5*v_3^2 
    h_4 = h_3 + 0.5*(v_3^2)
    
    return h_4, h_3
end


function Sat_State(P, Gas, ϵ)

    N = length(Gas["Pressure (MPa)"]) + 1

    search_index = 1
    for k ∈ 1:N

        
        if (abs(Gas["Pressure (MPa)"][k] - P) < ϵ)
            search_index = k;
            break
        elseif (k == N)
            return println("Error: Value not found")
        end
    end
    
    h_f = Gas["Enthalpy (l, kJ/kg)"][search_index];
    h_v = Gas["Enthalpy (v, kJ/kg)"][search_index];
    s_f = Gas["Entropy (l, J/g*K)"][search_index];
    s_v = Gas["Entropy (v, J/g*K)"][search_index];

    return h_f, h_v, s_f, s_v
end


function Quality_Search(h_9, h_1, h, Gas_Mix, Gas_Dif, P_mix)
    # Mixer

    h_2i = h[1]
    h_2o = h[2] 

    v_2i = sqrt(2*(h_9 - h_2i))
    v_2o = sqrt(2*(h_1 - h_2o))

    h_f, h_v, s_f, s_v = Sat_State(P_mix, Gas_Mix, 0.01)

    # Diffuser

    x_in = 1
    x_out = 0
    i = 0
    P = 0
    s_4 = 0;
    h_4 = 0;
    search_index = -42;
    
    x = 0:0.001:1
    N = length(x)
    
    for i ∈ 1:N
        ϵ_1 = 0.001
        ϵ_2 = 0.001

        h_4, h_3 = Diffuser_Enthalpy(x[i], v_2i, v_2o, h)
    
        X_mix = (h_3 - h_f)/(h_v - h_f)
        s_4 = s_f + X_mix * (s_v - s_f)
    
        
        M = length(Gas_Dif["Pressure (MPa)"])
    
        for j ∈ 1:1:M
            
            h_f_i = Gas_Dif["Enthalpy (l, kJ/kg)"][j];
            h_v_i = Gas_Dif["Enthalpy (v, kJ/kg)"][j];
            s_f_i = Gas_Dif["Entropy (l, J/g*K)"][j];
            s_v_i = Gas_Dif["Entropy (v, J/g*K)"][j];
            
            x_ver1 = (h_4 - h_f_i)/(h_v_i - h_f_i);
            x_ver2 = (s_4 - s_f_i)/(s_v_i - s_f_i);

            if (abs(x_ver1 - x_ver2) < ϵ_1) && (abs(x[i] + x_ver1 - 1) < ϵ_2)
                x_out = x_ver1;
                search_index = j;
                break
            end

        end
    end

    P = Gas_Dif["Pressure (MPa)"][search_index]

    return P, x_out, h_4, s_4, search_index
end


function  mass_flow_rate_1(Q_L, State_in, State_out)
    h_in = State_in.h
    h_out = State_out.h

    return Q_L/(h_out - h_in)
end


function mass_flow_rate_9(m_dot_1, State_4)
    x = State_4.X
    return (x * m_dot_1)/(1-x)
end


function work_in(State_in, State_out, m_dot_9)
    h_in = State_in.h
    h_out = State_out.h
        
    return m_dot_9 * (h_out - h_in)
end


function COP(Q_L, work_in)
    return Q_L/work_in
end


function work_in_turb(State_in_c, State_out_c, State_in_t, State_out_t, m_dot)
    h_in_c = State_in_c.h
    h_in_t = State_in_t.h
    h_out_c = State_out_c.h
    h_out_t = State_out_t.h

    return m_dot*((h_out_c - h_in_c) - (h_in_t - h_out_t))
end

function Q_out(State_in, State_out, m_dot)
    h_in = State_in.h
    h_out = State_out.h

    return m_dot*(h_in - h_out)
end