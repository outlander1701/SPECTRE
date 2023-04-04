include("utilities.jl")

function quality(Gas, P; h::FLoat64=-1, s::FLoat64=-1)

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

    return X
end

function throttle(State, Gas, sys_params)
    """
    Isoenthalpic throttle
    """
    h = State.h
    T = sys_params["Temp"]

    search_index = 1
    for i ∈ eachindex(Gas["Temperature (K)"])
        if Gas["Temperature (K)"][i] == T
            search_index = i
        end
    end

    P = Gas["Pressure (MPa)"][search_index]
    s = Gas["Entropy (v, J/g*K)"][search_index]

    X = quality(Gas, P, h=h)

    return State(T, P, h, s, X)

end

function compressor(State, Gas, sys_params) # Check for superheat
    """
    Isentropic compressor
    """
    s = State.s
    P = sys_params["P_max"] # Check this
    X = 1

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

function evaporator(State)
    """
    Isobar Evaporator
    """
    P = State.P
    T = State.T
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

function condensor(State)
    """
    Isobar condensor
    """
    P = State.P
    T = State.T
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