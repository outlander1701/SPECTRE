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

function calc_cp(T, Gas::Dict)
    """
    Calculates the pressure specific heat given a temperature and the gas 

    * Units: K, kJ/kg*K
    """

    T_vec = Gas["T"]
    cp_vec = Gas["cp"]

    return interpolate_func(T, T_vec, cp_vec)

end

function calc_cv(T, Gas::Dict)
    """
    Calculates the volume specific heat given a temperature and the gas 

    * Units: K, kJ/kg*K
    """

    T_vec = Gas["T"]
    cv_vec = Gas["cv"]

    return interpolate_func(T, T_vec, cv_vec)

end

function calc_k(T, Gas::Dict)
    """
    Calculates the specific heat ratio given a temperature and the gas 

    * Units: K, None
    """

    T_vec = Gas["T"]
    k_vec = Gas["k"]

    return interpolate_func(T, T_vec, k_vec)

end


function calc_P(𝓋, T, Gas::Dict)
    """
    Calculates the pressure at a given state

    * Units: K, Pa, m3/kg
    """

    R = calc_R(T, Gas)

    return (R*T)/𝓋

end

function calc_𝓋(P, T, Gas::Dict)
    """
    Calculates the specific volume at a given state

    * Units: K, Pa, m3/kg
    """

    R = calc_R(T, Gas)

    return (R*T)/P

end

function calc_T(P, 𝓋, Gas::Dict; T_prev=300)
    """
    Calculates the temperature at a given state

    * Units: K, Pa, m3/kg

    * Must assume a close temperature to get an accurate R value
    """

    R = calc_R(T_prev, Gas)

    return (P*𝓋)/R

end

function calc_Δu(Gas::Dict, State, State_prev)
    """
    Calculates the change in internal energy

    * Units: K, kJ/kg*K, kJ/kg
    """

    return calc_cv(State.T, Gas) * (State.T - State_prev.T)

end

function calc_Δh(Gas::Dict, State, State_prev)
    """
    Calculates the change in enthalpy

    * Units: K, kJ/kg*K, kJ/kg
    """

    T_avg = (State.T + State_prev.T) / 2

    return -1*calc_cp(T_avg, Gas) * (State.T - State_prev.T)

end

function calc_Δs(Gas::Dict, State, State_prev)
    """
    Calculates the change in entropy

    * Units: K, kJ/kg*K, kJ/kg
    """

    return calc_cp(State.T, Gas["cp"]) * log(State.T / State_prev.T) - calc_R((State.T + State_prev.T)/2, Gas) * log(State.P / State_prev.P)

end

function create_state(Gas, State_prev; P::Float64=0.0, T::Float64=0.0, 𝓋::Float64=0.0, h::Float64=0.0, s::Float64=0.0)
 
    eval_state = [P>0, T>0, 𝓋>0, h>0, s>0]
    
    if (sum(eval_state) < 2)
        error("ill-defined state")
    else
        if (sum(eval_state) == 5)
            return State(T, P, 𝓋, h, s)

        else
            state_name = ["Pressure", "Temperature", "Internal Energy", "Enthalpy", "Entropy"]
            if eval_state[1] == false
                #𝓋 = calc_𝓋(P, T, Gas)
                truthy_1 = 0
                truthy_2 = 0
                for i ∈ eachindex(eval_state)
                    if (eval_state[i] == true) && (truthy_1 == 0)
                        truthy_1 = i
                    elseif (eval_state[i] == true)
                        truthy_2 = i

                interp_var_1 = Gas[state_name[truthy_1]]
                interp_var_2 = Gas[state_name[truthy_2]]
                
                end

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
end