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
P_mix = 0.01;


State_1 = State(T_evap, P_evap, h_evap, s_evap, 1.0)
State_9 = State(T_cond, P_cond, h_cond, s_cond, 0.0)
State_2 = nozzle(State_9, State_1,R134a_Mix, P_mix);
State_4 = diffuser(State_9.h, State_1.h, State_2, R134a_Mix, R134a_Dif, P_mix)
State_5, State_7 = vapor_seperator(State_4, R134a_Dif)
State_6 = throttle(State_5, R134a_Throttle, T_evap)
State_8 = compressor(State_7, R134a_Comp, P_cond)
State_9A = condensor(State_8, R134a_Cond, T_cond)
State_1A = evaporator(State_6, R134a_Evap)


println(["State 1", State_1.P, State_1.T, State_1.s, State_1.h, State_1.X])
println(["State 9", State_9.P, State_9.T, State_9.s, State_9.h, State_9.X])
println(["State 4", State_4.P, State_4.T, State_4.s, State_4.h, State_4.X])
println(["State 5", State_5.P, State_5.T, State_5.s, State_5.h, State_5.X])
println(["State 6", State_6.P, State_6.T, State_6.s, State_6.h, State_6.X])
println(["State 7", State_7.P, State_7.T, State_7.s, State_7.h, State_7.X])
println(["State 8", State_8.P, State_8.T, State_8.s, State_8.h, State_8.X])
println(["State 1A", State_1A.P, State_1A.T, State_1A.s, State_1A.h, State_1A.X])
println(["State 9A", State_9A.P, State_9A.T, State_9A.s, State_9A.h, State_9A.X])

s = [State_1.s State_4.s State_5.s State_6.s State_7.s State_8.s State_9.s];
T = [State_1.T State_4.T State_5.T State_6.T State_7.T State_8.T State_9.T];

"""
states = [1,4,5,6,7,8,9]
for i ∈ eachindex(s)
    pt_label = states[i]
    annotate!((s[i], T[i], "pt_label"))
end
"""

scatter(s, T)

#plot!([0.2, 1.8], [206.29, 206.29]) 
plot!([0.67, 1.8], [T_evap, T_evap], label=false)
plot!([0.67, 1.8], [T_cond, T_cond], label=false)


