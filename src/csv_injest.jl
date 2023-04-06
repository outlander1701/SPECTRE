using CSV
using DataFrames

# Load CSV Files for Gasses

# R-134a (NIST)
#R134a = CSV.File("GasData/R134a.csv")
#R134a_Sat = CSV.File("GasData/R134a_Sat_Data.csv")

R134a_Comp = CSV.File("GasData/R134a_Pmax_SH.csv")
R134a_Cond = CSV.File("GasData/R134a_Pmax_Sat.csv")
R134a_Throttle = CSV.File("GasData/R134a_Pmin_Sat.csv")
R134a_Evap = CSV.File("GasData/R134a_Pmin_Sat.csv")
R134a_Mix = CSV.File("GasData/R134a_Mix_Sat.csv")

# CO2 (NIST)
CO2 = CSV.File("GasData/CO2.csv")