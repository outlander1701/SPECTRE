using Plots
gr()

include("./csv_injest.jl")
include("./utilities.jl")
include("./components.jl")
include("./cycles.jl")
include("./plotting.jl")

# Constants
T_L = -15.0 # C
T_H = 25.0 # C
Q_L = 500.0 # kW

#Initial State (R-134a)
P_cond = 0.88698; # MPa
T_cond = 308.15; # K
h_cond = 249.01; # kJ/kg
s_cond = 1.167; # kJ/kgK

T_evap = 248.0 # K Need to look at this value
P_evap = 0.10655 # MPa this is just for R-134a
h_evap = 383.4 # kJ/kg
s_evap = 1.7461 # kJ/kgK
P_mix = 0.05:0.0001:0.106;

State_1 = State(T_evap, P_evap, h_evap, s_evap, 1.0)
State_9 = State(T_cond, P_cond, h_cond, s_cond, 0.0)

#m_dot_1, m_dot_9, work, CoP = SPECTRE(State_1, State_9, Gasses[1], P_mix, Q_L)
#m_dot_1, work, CoP = Simple_Throttle(State_1, State_9, Gasses[1], P_mix, Q_L)
#m_dot_1, work, CoP = Simple_Turbine(State_1, State_9, Gasses[1], P_mix, Q_L)

"""
println(" ")
println(m_dot_1)
println(m_dot_9)
println(work)
println(CoP)
println(" ")
"""

#work_out_net_vs_pmix(SPECTRE, State_1, State_9, Gasses, P_mix, Q_L)
CoP_vs_pmix(SPECTRE, State_1, State_9, Gasses, P_mix, Q_L)
