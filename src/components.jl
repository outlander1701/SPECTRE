include("utilities.jl")

function throttle(State)
    """
    """
    h = State.h

    return 42
end

function compressor(State)
    """
    Isentropic compressor
    """
    s = State.s

    return 42
end

function evaporator(State)
    return 42
end

function condensor(State)
    return 42
end

function vapor_seperator(State)
    return 42
end

function diffuser(State)
    """
    Isentropic diffuser
    """
    s = State.s

    return 42
end