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

mutable struct State
    """
    Units: K, Pa, m3/kg, kJ/kg, kJ/kg*K
    """ 

    T::Float64
    P::Float64
    𝓋::Float64
    h::Float64
    s::Float64
    X::FLoat64
end