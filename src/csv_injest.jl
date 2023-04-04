using CSV
using DataFrames

# Load CSV Files for Gasses

# R-134a (NIST)
R134a = CSV.File("GasData/R134a.csv")

# CO2 (NIST)
CO2 = CSV.File("GasData/CO2.csv")