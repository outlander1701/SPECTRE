using Plots
gr()

include("./csv_injest.jl")
include("./utilities.jl")
include("./components.jl")
include("./cycles.jl")
include("./plotting.jl")

# Constants
T_L = -25.0 + 273 # C
T_H = 25.0 + 273 # C
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
#P_mix = 0.05:0.001:0.106;
P_mix = 0.08;
"""


P_cond = 7.3783; # MPa
T_cond = 308.15; # K
h_cond = 403.36; # kJ/kg
s_cond = 1.6668; # kJ/kgK

T_evap = 249.01 # K Need to look at this value
P_evap = 1.7297 # MPa this is just for R-134a
h_evap = 437.05 # kJ/kg
s_evap = 1.9739 # kJ/kgK
#P_mix = 0.05:0.001:0.106;
P_mix = 1.6746;


State_1 = State(T_evap, P_evap, h_evap, s_evap, 1.0)
State_9 = State(T_cond, P_cond, h_cond, s_cond, 0.0)

#m_dot_1, m_dot_9, work, CoP, Ψ, state_vec = SPECTRE(State_1, State_9, Gasses[1], P_mix, Q_L, T_L, T_H)
#m_dot_1, work, CoP, Ψ = Simple_Throttle(State_1, State_9, Gasses[1], P_mix, Q_L, T_L, T_H)
m_dot_1, work, CoP, Ψ, state_vec = Simple_Turbine(State_1, State_9, Gasses[1], P_mix, Q_L, T_L, T_H)

println(" ")
println("m_1: ", m_dot_1)
#println("m_9: ", m_dot_9)
println("W: ", work)
println("CoP: ", CoP)
println("Exergy: ", Ψ)
println(" ")

#work_in_net_vs_pmix(SPECTRE, State_1, State_9, Gasses, P_mix, Q_L,T_L, T_H)
#CoP_vs_pmix(SPECTRE, Simple_Turbine, Simple_Throttle,  State_1, State_9, Gasses, P_mix, Q_L, T_L, T_H)
#V_vs_pmix(SPECTRE, State_1, State_9, Gasses, P_mix, Q_L, T_L, T_H)


#s_vec = [state_vec[i].s for i ∈ eachindex(state_vec)]
#T_vec = [state_vec[i].T for i ∈ eachindex(state_vec)]

#scatter(s_vec, T_vec)
