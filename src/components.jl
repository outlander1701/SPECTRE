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

    h_f = Gas["Enthalpy (l, kJ/kg)"][1];
    h_v = Gas["Enthalpy (v, kJ/kg)"][1];
    s_f = Gas["Entropy (l, J/g*K)"][1];
    s_v = Gas["Entropy (v, J/g*K)"][1];
    
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

    N = length(Gas["Pressure (MPa)"]) + 1

    search_index_1 = 1
    for i ∈ 1:N
        if (abs(Gas["Pressure (MPa)"] - P) < 0.001)
            search_index_1 = i;
            break
        elseif (i == N)
            return println("Error: Value not found")
        end
    end

    s_f = Gas["Entropy (l, J/g*K)"][i];
    s_v = Gas["Entropy (v, J/g*K)"][i];
    h_f = Gas["Enthalpy (l, kJ/kg)"][i];
    h_v = Gas["Enthalpy (v, kJ/kg)"][i];

    X_i = (s_i - s_f)/(s_v - s_f)
    X_o = (s_o - s_f)/(s_v - s_f)

    h_i = h_f + X_i*(h_v - h_f)
    h_o = h_f + X_o*(h_v - h_f)
    return [h_i, h_o]
end
function diffuser(h_9, h_1, h, Gas)
    P, X, h = Quality_Search(h_9, h_1, h, Gas);

    search_index = 1
    for i ∈ 1:N
        if (abs(Gas["Pressure (MPa)"] - P) < 0.001)
            search_index_1 = i;
            break
        elseif (i == N)
            return println("Error: Value not found")
        end
    end

    T = Gas["Temperature (K)"][search_index];

    s_f = Gas["Entropy (l, J/g*K)"][search_index];
    s_v = Gas["Entropy (v, J/g*K)"][search_index];
    
    s = s_f - X*(s_v - s_f)

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

    X = quality(Gas, s=s) 
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
        elseif (i == N+1)
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



function vapor_seperator(State) # Double check temperature
    """
    Vapor Seperator
    """
    P = State.P
    T = State.T #???

    search_index_l = 1
    for i ∈ eachindex(Gas["Pressure (MPa)"])
        if Gas["Pressure (MPa)"][i] == P
            search_index_l = i
        end
    end

    search_index_v = 1
    for i ∈ eachindex(Gas["Pressure (MPa)"])
        if Gas["Pressure (MPa)"][i] == P
            search_index_v = i
        end
    end

    h_f = Gas["Enthalpy (l, kJ/kg)"][search_index_l];
    s_f = Gas["Entropy (l, J/g*K)"][search_index_l];

    h_v = Gas["Enthalpy (v, kJ/kg)"][search_index_v];
    s_v = Gas["Entropy (v, J/g*K)"][search_index_v];

    return State(T, P, h_f, s_f, 0), State(T, P, h_v, s_v, 1)
end
"""
function diffuser(State) # Check this
    """
    Isentropic diffuser
    """
    s = State.s
    

    search_index = 1
    for i ∈ eachindex(Gas["Pressure (MPa)"])
        if Gas["Pressure (MPa)"][i] == P
            search_index = i
        end
    end

    T = Gas["Temperature (K)"][search_index]
    h = Gas["Enthalpy (v, kJ/kg)"][search_index]
    

    return State(T, P, h, s, X)
end
"""

function Diffuser_Enthalpy(x, v_2i, v_2o, h)
    h_2i = h[1]
    h_2o = h[2]
    v_3 = x*v_2i + (1-x)*v_2o
    h_3 = x*(h_2i + .5*(v_2i^2)) + (1-x)*(h_2o + .5*(v_2o^2)) + .5*v_3^2
    h_4 = h_3 + .5*(v_3^2)
    return h_4
end

function Sat_State(P, Gas)

    n = 0;
    N = length(Gas["Pressure (MPa)"])

    for i ∈ 1:N
        ϵ = abs(P - Gas["Pressure (MPa)"][i])
        if (ϵ < 0.0005)
            n = i;
            break
        end
    end

    h_f = Gas["Enthalpy (l, kJ/kg)"][n];
    h_fg = Gas["Enthalpy (v, kJ/kg)"][n];
    s_f = Gas["Entropy (l, J/g*K)"][n];
    s_fg = Gas["Entropy (v, J/g*K)"][n];

    return h_f, h_fg, s_f, s_fg
end

function Quality_Search(h_9, h_1, h, Gas)
    
    h_2i = h[1]
    h_2o = h[2]

    v_2i = sqrt(2*(h_9 - h_2i))
    v_2o = sqrt(2*(h_1 - h_2o))

    x = 0:0.001:1;

    N = length(x);
    M = length(Gas["Pressure (MPa)"]);

    ϵ = 0.1;
    
    for i ∈ 1:N
        h_4 = Diffuser_Enthalpy(x[i], v_2i, v_2o, h)
        
        for j ∈ 1:M
            P = Gas["Pressure (MPa)"][j];

            h_f = Gas["Enthalpy (l, kJ/kg)"][j];
            h_fg = Gas["Enthalpy (v, kJ/kg)"][j];
            s_f = Gas["Entropy (l, J/g*K)"][j];
            s_fg = Gas["Entropy (v, J/g*K)"][j];
            
            x_ver1 = (h_4 - h_f)/h_fg;
            x_ver2 = (s_4 - s_f)/s_fg;
            
            print(i, " ", j)
            if (abs(x_ver1 - x_ver2) < ϵ && abs(x_ver1 - x) < ϵ)
                return P, x[i], h_4
            end

        end
    end
end