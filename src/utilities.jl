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

function find_state(Gas; P::Float64=-1.0, T::Float64=-1.0, h::Float64=-1.0, s::Float64=-1.0, X::Float64=-1.0)
    eval_state = [P != -1.0, T != -1.0, 𝓋 != -1.0, h != -1.0, s != -1.0, X != -1.0]

    if (X == 0) || (X == 1)
        if eval_state[1] == true

            search_index = 1
            for i ∈ eachindex(Gas["Pressure (MPa)"])
                if Gas["Pressure (MPa)"][i] == P
                    search_index = i
                end
            end

            T = Gas["Temperature (K)"][search_index]
            s = Gas[][search_index]
            h = Gas[][search_index]

            return State(T, P, h, s, 0)

        elseif eval_state[2] = true

            search_index = 1
            for i ∈ eachindex(Gas["Temperature (K)"])
                if Gas["Temperature (K)"][i] == T
                    search_index = i
                end
            end

            P = Gas["Pressure (MPa)"][search_index]
            s = Gas[][search_index]
            h = Gas[][search_index]

            return State(T, P, h, s, 0)
        else 
            println("You screwed up. Don't do that.")
        end

    else 
        search_index = 1;
        N = length(Gas["Pressure (MPa)"]);
        ϵ = 0.0005
        for i ∈ 1:N
            if (abs(P - Gas["Pressure (MPa)"]) < ϵ)
                search_index = i
                break
            end
        end
        h_f = Gas[""]
    end

end


"""
function create_state(Gas; P::Float64=0.0, T::Float64=0.0, 𝓋::Float64=0.0, h::Float64=0.0, s::Float64=0.0, X::Float64=0.0)
 
    eval_state = [P>0, T>0, 𝓋>0, h>0, s>0]
    
    if (sum(eval_state) < 2)
        error("ill-defined state")
    else
        if (sum(eval_state) == 5)
            return State(T, P, 𝓋, h, s)

        else
            state_input = [P, T, 𝓋, h, s]
            state_name = ["Pressure", "Temperature", "Internal Energy", "Enthalpy", "Entropy"]
            if eval_state[1] == false

                truthy_1 = 0
                truthy_2 = 0
                for i ∈ eachindex(eval_state)
                    if (eval_state[i] == true) && (truthy_1 == 0)
                        truthy_1 = i
                    elseif (eval_state[i] == true)
                        truthy_2 = i
                end

                interp_var_1 = Gas[state_name[truthy_1]]
                interp_var_2 = Gas[state_name[truthy_2]]

                state_vec = Gas[state_name[1]] 

                lower_bound = 0
                for j ∈ eachindex(state_vec)
                    if state_vec[j] <= state_input[1]
                        lower_bound = j
                    end
                end
                
                interp_vec_1 = [interp_var_1[lower_bound], interp_var_1[lower_bound + 1]]
                interp_vec_2 = [interp_var_2[lower_bound], interp_var_2[lower_bound + 1]]



            end

            return State(T, P, 𝓋, h, s)

        end

    end 

end
end
"""

mutable struct State
    """
    Units: K, Pa, kJ/kg, kJ/kg*K
    """ 

    T::Float64
    P::Float64
    h::Float64
    s::Float64
    X::FLoat64

end

function Diffuser_Enthalpy(x, v_2i, v_2o, h_2i, h_2o)
    v_3 = x*v_2i + (1-x)*v_2o
    h_3 = x*(h_2i + .5*(v_2i^2)) + (1-x)*(h_2o + .5*(v_2o^2)) + .5*v_3^2
    h_4 = h_3 + .5*(v_3^2)
    return h_4
end

function Quality_Search(h_9, h_2i, h_1, h_2o, h_f, h_fg, s_f, s_fg)
    
    v_2i = sqrt(2*(h_9 - h_2i))
    v_2o = sqrt(2*(h_1 - h_2o))
    
    x = 0:0.001:1;
    N = length(x);

    ϵ = 0.1;
    
    for i ∈ 1:N
        h_4 = Diffuser_Enthalpy(x[i], v_2i, v_2o, h_2i, h_2o)
        x_ver1 = (h_4 - h_f)/h_fg;
        x_ver2 = (s_4 - s_f)/s_fg;

        if (abs(x_ver1 - x_ver2) <= ϵ)
            return x[i]
        end
    end

end