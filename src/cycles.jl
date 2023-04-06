# Simple throttle cycle
State_1 = State(T_evap, P_evap, h_evap, s_evap, 1.0);
State_2 = compressor(State_1, R134a_Comp, P_cond);
State_3 = condensor(State_2, R134a_Cond, T_cond);
State_4 = throttle(State_3, R134a_Throttle, T_evap);
State_5 = evaporator(State_4, R134a_Evap);

println(["State 1", State_1.P, State_1.T, State_1.s, State_1.h, State_1.X])
println(["State 2", State_2.P, State_2.T, State_2.s, State_2.h, State_2.X])
println(["State 3", State_3.P, State_3.T, State_3.s, State_3.h, State_3.X])
println(["State 4", State_4.P, State_4.T, State_4.s, State_4.h, State_4.X])
println(["State 5", State_5.P, State_5.T, State_5.s, State_5.h, State_5.X])

s = [State_1.s, State_2.s, State_3.s, State_4.s, State_5.s];
T = [State_1.T, State_2.T, State_3.T, State_4.T, State_5.T];

scatter(s, T)

# Simple Turbine Cycle
State_1 = State(T_evap, P_evap, h_evap, s_evap, 1.0);
State_2 = compressor(State_1, R134a_Comp, P_cond);
State_3 = condensor(State_2, R134a_Cond, T_cond);
State_4 = turbine(State_3, R134a_Throttle, T_evap);
State_5 = evaporator(State_4, R134a_Evap);

println(["State 1", State_1.P, State_1.T, State_1.s, State_1.h, State_1.X])
println(["State 2", State_2.P, State_2.T, State_2.s, State_2.h, State_2.X])
println(["State 3", State_3.P, State_3.T, State_3.s, State_3.h, State_3.X])
println(["State 4", State_4.P, State_4.T, State_4.s, State_4.h, State_4.X])
println(["State 5", State_5.P, State_5.T, State_5.s, State_5.h, State_5.X])

s = [State_1.s, State_2.s, State_3.s, State_4.s, State_5.s];
T = [State_1.T, State_2.T, State_3.T, State_4.T, State_5.T];

scatter(s, T)