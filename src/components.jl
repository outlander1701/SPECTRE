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
    

   
"""
    N = length(Gas_Diff["Pressure (MPa)"])

    for i ∈ 1:N
        if (abs(Gas_Diff["Pressure (MPa)"][i] - P) < 0.1) # 0.001
            search_index = i;
            break
        elseif (i == N)
            return println("Error: Value not found")
        end
    end
"""
    T = Gas_Diff["Temperature (K)"][search_index];

    #s_f = Gas["Entropy (l, J/g*K)"][search_index];
    
    #s_v = Gas["Entropy (v, J/g*K)"][search_index];
    
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


function vapor_seperator(State_in, Gas) # Double check temperature
    """
    Vapor Seperator
    """
    P = State_in.P
    T = State_in.T

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

function Diffuser_Enthalpy(x, v_2i, v_2o, h)
    """
    x = (m_1 / m_t)
    """
    h_2i = h[1]
    h_2o = h[2]
    v_3 = (1-x)*v_2i + (x)*v_2o
    h_3 = (1-x)*(h_2i + .5*(v_2i^2)) + (x)*(h_2o + .5*(v_2o^2)) - .5*v_3^2 # x*(h_2i + .5*(v_2i^2)) + (1-x)*(h_2o + .5*(v_2o^2)) + .5*v_3^2
    h_4 = h_3 + .5*(v_3^2)
    return h_4, h_3
end


function Sat_State(P, Gas, ϵ)

    N = length(Gas["Pressure (MPa)"]) + 1

    search_index = 1
    for k ∈ 1:N

        #println(Gas["Pressure (MPa)"][k], " ", P, " ", abs(Gas["Pressure (MPa)"][k] - P), " ", ϵ)
        
        if (abs(Gas["Pressure (MPa)"][k] - P) < ϵ)
            #println("Code monkey village")
            search_index = k;
            break
        elseif (k == N)
            return println("Error: Value not found")
        end
    end
    #println("Code monkey village")
    
    h_f = Gas["Enthalpy (l, kJ/kg)"][search_index];
    h_v = Gas["Enthalpy (v, kJ/kg)"][search_index];
    s_f = Gas["Entropy (l, J/g*K)"][search_index];
    s_v = Gas["Entropy (v, J/g*K)"][search_index];

    #println([h_f, h_v, s_f, s_v])

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
    search_index = 1;

    while (abs(x_in - x_out) > 0.01)
        i = i+1;
        ϵ = 0.1;

        #println(abs(x_in - x_out))

        x_in = .5*(x_in + x_out)

        #println(x_in)

        h_4, h_3 = Diffuser_Enthalpy(x_in, v_2i, v_2o, h)
        
        X_mix = (h_3 - h_f)/(h_v - h_f)
        s_4 = s_f + X_mix * (s_v - s_f)
        
        M = length(Gas_Dif["Pressure (MPa)"])
        
        for j ∈ 1:1:M
            #println(i, " ", j)
            P_dif = Gas_Dif["Pressure (MPa)"][j];

            h_f_i = Gas_Dif["Enthalpy (l, kJ/kg)"][j];
            h_v_i = Gas_Dif["Enthalpy (v, kJ/kg)"][j];
            s_f_i = Gas_Dif["Entropy (l, J/g*K)"][j];
            s_v_i = Gas_Dif["Entropy (v, J/g*K)"][j];
            
            x_ver1 = (h_4 - h_f_i)/(h_v_i - h_f_i);
            x_ver2 = (s_4 - s_f_i)/(s_v_i - s_f_i);

            #println(x_ver1, " ", x_ver2, " ", abs(x_ver1 - x_ver2), " ", abs(x_ver1 + x[i] - 1), " ", s_4)
            #println(ϵ, " ", abs(x_ver1 - x_ver2), " ", i, " ", j)
            
            if (abs(x_ver1 - x_ver2) < ϵ)
                #println("Code monkeys eating bananas")
                x_out = x_ver1;
                search_index = j;
                #println(search_index)

            end
        end

       # println(x_out)
        """
        if (i >= 1000)
            break
        end
        """
    end

    P = Gas_Dif["Pressure (MPa)"][search_index]

    return P, x_out, h_4, s_4, search_index
end



"""
function Quality_Search(h_9, h_1, h, Gas_Mix, Gas_Dif, P_mix)
    
    h_2i = h[1]
    h_2o = h[2]

    v_2i = sqrt(2*(h_9 - h_2i))
    v_2o = sqrt(2*(h_1 - h_2o))

    x = 0:0.001:1;

    N = length(x);
    M = length(Gas_Mix["Pressure (MPa)"]);

    ϵ = 0.01;
    
    h_f, h_v, s_f, s_v = Sat_State(P_mix, Gas_Mix, 0.01)

    for i ∈ 1:N
        h_4, h_3 = Diffuser_Enthalpy(x[i], v_2i, v_2o, h)
        X_mix = (h_3 - h_f)/(h_v - h_f)
        s_4 = s_f + X_mix * (s_v - s_f)

        for j ∈ 1:M
            P = Gas_Dif["Pressure (MPa)"][j];

            h_f_i = Gas_Dif["Enthalpy (l, kJ/kg)"][j];
            h_v_i = Gas_Dif["Enthalpy (v, kJ/kg)"][j];
            s_f_i = Gas_Dif["Entropy (l, J/g*K)"][j];
            s_v_i = Gas_Dif["Entropy (v, J/g*K)"][j];
            
            x_ver1 = (h_4 - h_f_i)/(h_v_i - h_f_i);
            x_ver2 = (s_4 - s_f_i)/(s_v_i - s_f_i);

            println(x_ver1, " ", x_ver2, " ", abs(x_ver1 - x_ver2), " ", abs(x_ver1 + x[i] - 1), " ", s_4)
            
            if (abs(x_ver1 - x_ver2) < ϵ) && (abs(x_ver1 + x[i] - 1) < ϵ)
                println([P, x[i], h_4, s_4])
                return P, x[i], h_4, s_4
            end
        
        end



    end
end
"""