using Plots
using LaTeXStrings


function work_out_net_vs_pmix(cycle_func, State_1, State_9, Gasses, P_mix, Q_L)
    N = length(P_mix)
    M = length(Gasses)

    plot()

    for i ∈ 1:M
        w_out_net = Array{Float64, 1}(undef, N)
        
        CoP = Array{Float64, 1}(undef, N)
        m_dot_1 = Array{Float64, 1}(undef, N)
        m_dot_9 = Array{Float64, 1}(undef, N)

        for j ∈ 1:N
            m_dot_1[j], m_dot_9[j], w_out_net[j], CoP[j] = cycle_func(State_1, State_9, Gasses[i], P_mix[j], Q_L)
        end
        name = Gasses[i]["name"]

        scatter!(P_mix, w_out_net, label=latexstring("$name"))

    end

    xlabel!("Pressure Ratio")
    ylabel!("Net Work Out [kJ/kg]")

end
function CoP_vs_pmix(cycle_func, State_1, State_9, Gasses, P_mix, Q_L)
    N = length(P_mix)
    M = length(Gasses)

    plot()

    for i ∈ 1:M
        w_out_net = Array{Float64, 1}(undef, N)
        CoP = Array{Float64, 1}(undef, N)
        m_dot_1 = Array{Float64, 1}(undef, N)
        m_dot_9 = Array{Float64, 1}(undef, N)

        for j ∈ 1:N
            m_dot_1[j], m_dot_9[j], w_out_net[j], CoP[j] = cycle_func(State_1, State_9, Gasses[i], P_mix[j], Q_L)
        end
        name = Gasses[i]["name"]
        scatter!(P_mix, CoP, label=latexstring("$name"))
    end

    xlabel!("Pressure Ratio")
    ylabel!("CoP")

end
