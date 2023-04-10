using Plots
gr()

include("./csv_injest.jl")
include("./utilities.jl")
include("./components.jl")
include("./cycles.jl")

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
P_mix = 0.10;

State_1 = State(T_evap, P_evap, h_evap, s_evap, 1.0)
State_9 = State(T_cond, P_cond, h_cond, s_cond, 0.0)

m_dot_1, m_dot_9, work, CoP = SPECTRE(State_1, State_9, R134a_Mix, R134a_Dif, R134a_Throttle, R134a_Comp, R134a_Evap, P_mix, Q_L)
#m_dot_1, work, CoP = Simple_Throttle(State_1, State_9, R134a_Mix, R134a_Dif, R134a_Throttle, R134a_Comp, R134a_Evap, P_mix, Q_L)
#m_dot_1, work, CoP = Simple_Turbine(State_1, State_9, R134a_Mix, R134a_Dif, R134a_Throttle, R134a_Comp, R134a_Evap, P_mix, Q_L)

println(" ")
println(m_dot_1)
println(m_dot_9)
println(work)
println(CoP)

println(" ")

"""
println(["State 1", State_1.P, State_1.T, State_1.s, State_1.h, State_1.X])
println(["State 9", State_9.P, State_9.T, State_9.s, State_9.h, State_9.X])
println(["State 4", State_4.P, State_4.T, State_4.s, State_4.h, State_4.X])
println(["State 5", State_5.P, State_5.T, State_5.s, State_5.h, State_5.X])
println(["State 6", State_6.P, State_6.T, State_6.s, State_6.h, State_6.X])
println(["State 7", State_7.P, State_7.T, State_7.s, State_7.h, State_7.X])
println(["State 8", State_8.P, State_8.T, State_8.s, State_8.h, State_8.X])
println(["State 1A", State_1_prime.P, State_1_prime.T, State_1_prime.s, State_1_prime.h, State_1_prime.X])
println(["State 9A", State_9_prime.P, State_9_prime.T, State_9_prime.s, State_9_prime.h, State_9_prime.X])


s = [State_1.s State_4.s State_5.s State_6.s State_7.s State_8.s State_9.s];
T = [State_1.T State_4.T State_5.T State_6.T State_7.T State_8.T State_9.T];

scatter(s, T)

#plot!([0.2, 1.8], [206.29, 206.29]) 
plot!([0.67, 1.8], [T_evap, T_evap], label=false)
plot!([0.67, 1.8], [T_cond, T_cond], label=false)
"""
