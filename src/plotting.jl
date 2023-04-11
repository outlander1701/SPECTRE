using Plots
using LaTeXStrings


function work_in_net_vs_pmix(cycle_func, State_1, State_9, Gasses, P_mix, Q_L, T_L, T_H)
    N = length(P_mix)
    M = length(Gasses)

    plot()

    for i ∈ 1:M
        w_in_net = Array{Float64, 1}(undef, N)
        
        CoP = Array{Float64, 1}(undef, N)
        m_dot_1 = Array{Float64, 1}(undef, N)
        m_dot_9 = Array{Float64, 1}(undef, N)
        Ψ = Array{Float64, 1}(undef, N)

        for j ∈ 1:N
            m_dot_1[j], m_dot_9[j], w_in_net[j], CoP[j], Ψ[j] = cycle_func(State_1, State_9, Gasses[i], P_mix[j], Q_L, T_L, T_H)
        end
        name = Gasses[i]["name"]

        scatter!(P_mix, w_in_net, label=latexstring("$name"))

    end

    xlabel!("Mixing Pressure [MPa]")
    ylabel!("Work In [kJ]")

end


function CoP_vs_pmix(cycle_func, State_1, State_9, Gasses, P, Q_L, T_L, T_H)
    N = length(P)
    M = length(Gasses)

    plot()

    for i ∈ 1:M
        w_in_net = Array{Float64, 1}(undef, N)
        CoP = Array{Float64, 1}(undef, N)
        m_dot_1 = Array{Float64, 1}(undef, N)
        m_dot_9 = Array{Float64, 1}(undef, N)
        Ψ = Array{Float64, 1}(undef, N)

        for j ∈ 1:N
            m_dot_1[j], m_dot_9[j], w_in_net[j], CoP[j], Ψ[j] = cycle_func(State_1, State_9, Gasses[i], P[j], Q_L, T_L, T_H)
        end
        name = Gasses[i]["name"]
        scatter!(P, CoP, label=latexstring("$name"))
    end

    xlabel!("Mixing Pressure [MPa]")
    ylabel!("CoP")

end

function V_vs_pmix(cycle_func, State_1, State_9, Gasses, P, Q_L, T_L, T_H)
    N = length(P)
    M = length(Gasses)

    plot()

    for i ∈ 1:M
        w_in_net = Array{Float64, 1}(undef, N)
        CoP = Array{Float64, 1}(undef, N)
        m_dot_1 = Array{Float64, 1}(undef, N)
        m_dot_9 = Array{Float64, 1}(undef, N)
        Ψ = Array{Float64, 1}(undef, N)
        V_1 = Array{Float64, 1}(undef, N)
        V_2 = Array{Float64, 1}(undef, N)


        for j ∈ 1:N
            m_dot_1[j], m_dot_9[j], w_in_net[j], CoP[j], Ψ[j], V_1[j], V_2[j] = cycle_func(State_1, State_9, Gasses[i], P[j], Q_L, T_L, T_H)
        end
        name = Gasses[i]["name"]
        scatter!(P, V_1, label=latexstring("V_{out}"))
        scatter!(P, V_2, label=latexstring("V_{in}"))
    end

    xlabel!("Mixing Pressure [MPa]")
    ylabel!("Inlet Velocity Difference [m/s]")

end
