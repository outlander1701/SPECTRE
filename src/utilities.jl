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

function S_gen(State_out, State_in; Q=0, T=0)
    S_gen = 0
    if Q != 0
        S_gen = (State_out.s - State_in.s) + (Q/T)
    else
        S_gen = State_out.s - State_in.s
    end

    return S_gen
end