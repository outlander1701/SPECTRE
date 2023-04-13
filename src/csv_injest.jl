using CSV
using DataFrames

# Load CSV Files for Gasses

# R-134a (NIST)

R134a_Comp = CSV.File("GasData/R134a/R134a_Pmax_SH.csv")
R134a_Cond = CSV.File("GasData/R134a/R134a_Pmax_Sat.csv")
R134a_Throttle = CSV.File("GasData/R134a/R134a_Pmin_Sat.csv")
R134a_Evap = CSV.File("GasData/R134a/R134a_Pmin_Sat.csv")
R134a_Mix = CSV.File("GasData/R134a/R134a_Mix_Sat.csv")
R134a_Dif = CSV.File("GasData/R134a/R134a_P4_Data.csv")

R134a = Dict("Comp" => R134a_Comp, "Cond" => R134a_Cond, "Throttle" => R134a_Throttle, "Evap" => R134a_Evap, "Mix" => R134a_Mix, "Dif" => R134a_Dif, "name" => "R-134a")

# CO2 (NIST)
CO2_Comp = CSV.File("GasData/CO2/CO2_P_max.csv")
CO2_Cond = CSV.File("GasData/CO2/CO2_P_max.csv")
CO2_Throttle = CSV.File("GasData/CO2/CO2_Evap.csv")
CO2_Evap = CSV.File("GasData/CO2/CO2_Evap.csv")
CO2_Mix = CSV.File("GasData/CO2/CO2_Mix.csv")
CO2_Dif = CSV.File("GasData/CO2/CO2_Sat_Data.csv")

CO2 = Dict("Comp" => CO2_Comp, "Cond" => CO2_Cond, "Throttle" => CO2_Throttle, "Evap" => CO2_Evap, "Mix" => CO2_Mix, "Dif" => CO2_Dif, "name" => "CO_{2}")

Gasses = [R134a]

