# Utility Functions and Structs

function interpolate_func(x, x_vec::Vector, y_vec::Vector)
    """
    Interpolates between two points to find the y value given an x

    Inputs:

    * x: desired x value to interpolate

    * x_vec: vector of x to search through

    * y_vec: vector of y to search through

    Output:

    * y: interpolated value
    """

    n::Int8 = 0
    for i ∈ 1:length(x_vec)
        if x_vec[i] > x
            n = i
            break
        end
    end

    return (((y_vec[n] - y_vec[n-1]) / (x_vec[n] - x_vec[n-1])) * (x - x_vec[n-1])) + y_vec[n-1]

end


mutable struct State
    """
    Units: K, Pa, kJ/kg, kJ/kg*K
    """ 

    T::Float64
    P::Float64
    h::Float64
    s::Float64
    X::Float64

end

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

function Quality_Search(h_9, h_2i, h_1, h_2o, Gas)
    
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
                return P, x[i]
            end

        end
    end
end