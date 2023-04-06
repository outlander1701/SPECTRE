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

function throttle(State_in, Gas, T_min)
    """
    Isoenthalpic throttle
    """
    h = State_in.h
    T = T_min

    P = Float64(Gas["Pressure (MPa)"][1])

    X = quality(Gas, h=h) 
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