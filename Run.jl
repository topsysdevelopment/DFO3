#  Copyright 2021, Naser Moosavian, Ph.D., University of British Columbia
#  This Source Code Form is subject to the terms of the BC Hydro Co.
#  A copy of the code is available at J Drive (***the address***).
#############################################################################
# Application of LP-GOM for the Optimization of Reservoir Operations 
# Source: Naser Moosavian
#############################################################################

using Base: String
using DelimitedFiles
using Printf

Run_Number = 1
Year = "S4042S5904A92915_L2022W1965\\"
Study = "S4042S5904A92915_L2022CD\\"
strpath1= "C:\\Users\\sabdolna\\Documents\\GOM-JULIA\\JuliaCode\\CleanCode2\\TestData\\"*Year
strpath2= "C:\\Users\\sabdolna\\Documents\\GOM-JULIA\\JuliaCode\\CleanCode2\\TestData\\"*Study

# str1= "C:\\Users\\sabdolna\\Documents\\GOM-JULIA\\MyCodes\\"
# str2 = str1*Year
cd("C:/Users/sabdolna/Documents/GOM-JULIA/JuliaCode/CleanCode2/CoreCode")
#Global modeling parameters
strpath= "C:\\Users\\sabdolna\\Documents\\GOM-JULIA\\JuliaCode\\CleanCode2\\CoreCode\\Inputs\\"



initial = 1
T =17520
RUNS = [1 2 3 4]

objfunctions = zeros(length(RUNS))
totaltime = zeros(length(RUNS))
# Initialization of Parameters
include("ReadData.jl")
# Function Definition for reading the .data
include("ReadDataFunc.jl")
# Timestep list of each day in the study
include("setTT.jl")
# calling Julia code for loading .data using "ReadDataFunc.jl"
include("GOMdata.jl")
# Tailwater curves and tailrace curves for selected hydro plant.Pre-Processor
include("TWL.jl")
# loading .data using "ReadDataFunc.jl" and ""GOMdata.jl"
ReadSysData(param,data,strpath,End)
# Performing WINDRES.run in AMPL-GOM
include("Wind.jl")
# HPG calculations based on COMBO
include("CombosFunc.jl")
# Storage calculations based on FB
include("StoreElev.jl")
# Calculation of maxg and maxq, these coefs will be using in QT_Max.jl for P_Max and QT_Max
include("MAXGQ.jl")
include("MASTER_CURRENT.jl")
objfunctions[Run_Number] = objfun
totaltime[Run_Number] = sum(timevector)


