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

        scatter!(1000 .*P_mix, w_in_net, label=latexstring("$name"))

    end
    xlabel!("Mixing Pressure [kPa]")
    ylabel!("Work In [kJ]")

end


function CoP_vs_pmix(cycle_func_1,cycle_func_2,cycle_func_3, State_1,  State_9, Gasses, P, Q_L, T_L, T_H)
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
            m_dot_1[j], m_dot_9[j], w_in_net[j], CoP[j], Ψ[j], = cycle_func_1(State_1, State_9, Gasses[i], P[j], Q_L, T_L, T_H)
        end
        name = Gasses[i]["name"]
        scatter!(1000 .*P, CoP, label=latexstring("$name"))

        m_dot_1_2, work_2, CoP_2, Ψ_2 = cycle_func_2(State_1, State_9, Gasses[1], P, Q_L, T_L, T_H)
        m_dot_1_3, work_3, CoP_3, Ψ_3 = cycle_func_3(State_1, State_9, Gasses[1], P, Q_L, T_L, T_H)
        
        #plot!(1000 .*P, CoP_2 .*ones(length(P)), label = "Turbine")
        #plot!(1000 .*P, CoP_3 .*ones(length(P)), label = "Throttle")

    end

    xlabel!("Mixing Pressure [kPa]")
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
        #V_1 = Array{Float64, 1}(undef, N)
        #V_2 = Array{Float64, 1}(undef, N)
        #V_3 = Array{Float64, 1}(undef, N)


        for j ∈ 1:N
            m_dot_1[j], m_dot_9[j], w_in_net[j], CoP[j], Ψ[j]= cycle_func(State_1, State_9, Gasses[i], P[j], Q_L, T_L, T_H) #m_dot_1[j], m_dot_9[j], w_in_net[j], CoP[j], Ψ[j], V_1[j], V_2[j], V_3[j]
        end
        name = Gasses[i]["name"]
        scatter!(1000 .*P, Ψ, label=name)
        #scatter!(1000 .*P, V_2, label=latexstring("V_{2,o}"), markersize = 3)
        #scatter!(1000 .*P, V_3, label=latexstring("V_{3}"), markersize = 3)

        #scatter!(1000 .*P, 1000 .*V_2, label=latexstring("V_{in}"))
    end

    xlabel!("Mixing Pressure [kPa]")
    ylabel!("Velocity [m/s]")

end

function exergy_destroyed_vs_pmix(cycle_func, State_1, State_9, Gasses, P, Q_L, T_L, T_H)
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
            m_dot_1[j], w_in_net[j], CoP[j], Ψ[j] = cycle_func(State_1, State_9, Gasses[i], P[j], Q_L, T_L, T_H)
            #m_dot_1[j], m_dot_9[j], w_in_net[j], CoP[j], Ψ[j], V_1[j], V_2[j] = cycle_func(State_1, State_9, Gasses[i], P[j], Q_L, T_L, T_H)
        end

        name = Gasses[i]["name"]
        scatter!(1000 .* P, Ψ, label = false)
    end

    xlabel!("Mixing Pressure [kPa]")
    ylabel!("Exergy Destroyed [kW]")

end
