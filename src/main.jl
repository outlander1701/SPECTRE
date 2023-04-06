using Plots

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


State_1 = State(T_evap, P_evap, h_evap, s_evap, 1.0)
State_9 = State(T_cond, P_cond, h_cond, s_cond, 0.0)

