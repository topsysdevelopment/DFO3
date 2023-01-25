using JuMP, Clp
using CSV, Tables
using DataFrames
using Random, Distributions

function clc()
    if Sys.iswindows()
        return read(run(`powershell cls`), String)
    elseif Sys.isunix()
        return read(run(`clear`), String)
    elseif Sys.islinux()
        return read(run(`printf "\033c"`), String)
    end
end


include("setconst.jl")
SetStorage(param, data)
include("TWCURVES.jl")
include("Parameters.jl")
include("GENMODZ3.jl")
include("QT_Max.jl")
include("fbsim.jl")
niter = 4
timevector = zeros(niter)
for it = 1:niter
    SetStorage(param, data)
    start = time()
    global model, iter
    iter = it
    TWCurves(data)
    LimitPQ(param, data)
    # model = Model(with_optimizer(Clp.Optimizer, LogLevel=1, SolveType=3))
    model = Model(Clp.Optimizer)
    # m = Model(HiGHS.Optimizer)
    set_optimizer_attribute(model, "SolveType", 3)
    # set_optimizer_attribute(model, "LogLevel", 1)
    # set_optimizer_attribute(model, "PrimalTolerance", 1e-4)
    # set_optimizer_attribute(model, "DualTolerance", 1e-4)
    # model = Model(with_optimizer(Clp.Optimizer))
    global counter = 0
    model = DefineModel(model,data,param)
    status = optimize!(model)
    fval = objective_value(model)
    println(fval)
    global objfun = fval
    
    local QTTEMPdQT = model[:QTTEMPdQT]
    local V = model[:V]
    local P = model[:P]
    P_vals = JuMP.value.(P)
    QTTEMPdQT_pre = JuMP.value.(QTTEMPdQT)
    V_pre = JuMP.value.(V)
    P_LRBdQT = data.P_LRBdQT
    QP = model[:QP]
    QP_pre = JuMP.value.(QP)
    data.P_LRBdQT = P_LRBdQT
    data.V_pre = V_pre
    data.QPTEMP = QP_pre
    V_SIM = V_pre
    FBSim(data,param)
    elapsed = time() - start
    global timevector[iter] = elapsed
end
include("Output.jl")
