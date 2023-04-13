using Plots
#gr()

include("./csv_injest.jl")
include("./utilities.jl")
include("./components.jl")
include("./cycles.jl")
include("./plotting.jl")

# Constants
T_L = 258.0 # K
T_H = 298.0 # K
Q_L = 500.0 # kW

"""
#Initial State (R-134a)
P_cond = 0.88698; # MPa
T_cond = 308.15; # K
h_cond = 249.01; # kJ/kg
s_cond = 1.167; # kJ/kgK

T_evap = 248.0 # K Need to look at this value
P_evap = 0.10655 # MPa this is just for R-134a
h_evap = 383.4 # kJ/kg
s_evap = 1.7461 # kJ/kgK
#P_mix = 0.001:0.001:0.106;
P_mix = 0.10;
"""



P_cond = 7.3783; # MPa
T_cond = 304.0 # 308.00; # K | prev: 304.00
h_cond = 309.43 #402.59; # kJ/kg | prev: 309.43	
s_cond = 1.3586 #1.6643; # kJ/kgK | 1.3586

T_evap = 248.0 # K Need to look at this value
P_evap = 1.7297 # MPa this is just for R-134a
h_evap = 437.05 # kJ/kg
s_evap = 1.9739 # kJ/kgK
#P_mix = 0.5179:0.01:1.675;
P_mix = 0.52


State_1 = State(T_evap, P_evap, h_evap, s_evap, 1.0)
State_9 = State(T_cond, P_cond, h_cond, s_cond, 0.0)

"""
println(" ")
println("m_1: ", m_dot_1)
#println("m_9: ", m_dot_9)
println("W: ", work)
println("CoP: ", CoP)
println("Exergy: ", Ψ)
println(" ")
"""


m_dot_1, m_dot_9, work, CoP, Ψ, state_vec = SPECTRE(State_1, State_9, Gasses[1], P_mix, Q_L, T_L, T_H)
#m_dot_1, work, CoP, Ψ = Simple_Throttle(State_1, State_9, Gasses[1], P_mix, Q_L, T_L, T_H)
#m_dot_1, work, CoP, Ψ, state_vec = Simple_Turbine(State_1, State_9, Gasses[1], P_mix, Q_L, T_L, T_H)

println("Finished\n\n")

#work_in_net_vs_pmix(SPECTRE, State_1, State_9, Gasses, P_mix, Q_L, T_L, T_H)
#CoP_vs_pmix(SPECTRE, Simple_Turbine, Simple_Throttle,  State_1, State_9, Gasses, P_mix, Q_L, T_L, T_H)
V_vs_pmix(SPECTRE, State_1, State_9, Gasses, P_mix, Q_L, T_L, T_H)


#s_vec = [state_vec[i].s for i ∈ eachindex(state_vec)]
#T_vec = [state_vec[i].T for i ∈ eachindex(state_vec)]

#scatter(s_vec, T_vec)
#plot!(s_vec, T_vec)
#work_in_net_vs_pmix(SPECTRE, State_1, State_9, Gasses, P_mix, Q_L, T_L, T_H)
