using CSV
using DataFrames

# Load CSV Files for Gasses

# R-134a (NIST)
R134a_Comp = CSV.File("GasData/R134a_Pmax_SH.csv")
R134a_Cond = CSV.File("GasData/R134a_Pmax_Sat.csv")
R134a_Throttle = CSV.File("GasData/R134a_Pmin_Sat.csv")
R134a_Evap = CSV.File("GasData/R134a_Pmin_Sat.csv")
R134a_Mix = CSV.File("GasData/R134a_Mix_Sat.csv")
R134a_Dif = CSV.File("GasData/R134a_P4_Data.csv")

R134a = Dict("Comp" => R134a_Comp, "Cond" => R134a_Cond, "Throttle" => R134a_Throttle, "Evap" => R134a_Evap, "Mix" => R134a_Mix, "Dif" => R134a_Dif, "name" => "R134a")

# CO2 (NIST)
CO2 = CSV.File("GasData/CO2.csv")


Gasses = [R134a]