# problem MASTER_CURRENT :
###### VARIABLES ######
function DefineVariable(model)
    # Define decision variables
    @JuMP.variable(model, minVar <= CURTAILFRA[r = 1:length(GENNODES), t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= VDiff[j = 1:N_Plant] <= maxVar) 
    @JuMP.variable(model, minVar <= MVW1[j = 1:N_Plant]  <= maxVar) 
    @JuMP.variable(model, minVar <= RRES1[j = 1:N_Plant]  <= maxVar) 
    @JuMP.variable(model, minVar <= V_Average[j = 1:N_Plant] <= maxVar) 
    @JuMP.variable(model, minVar <= QTTEMPdQT[j = 1:N_Plant, t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= P_all[j = 1:N_Plant, t = Start:End] <= maxVar)
    @JuMP.variable(model, minVar <= V[j = 1:N_Plant, t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= dQT[j = 1:N_Plant, t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= VDiffQT[j = 1:N_Plant, t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= VTEMP[j = 1:N_Plant, t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= P[j = 1:N_Plant, t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= RQSR[j = 1:N_Plant, k = 1:N_Plant, t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= US[j = 1:N_Plant, k = 1:N_Plant, t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= QS[j = 1:N_Plant, t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= QP[j = 1:N_Plant, t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= RQTR[j = 1:N_Plant, k = 1:N_Plant, t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= UT[j = 1:N_Plant, k = 1:N_Plant, t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= QT[j = 1:N_Plant, t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= G_RM_BUFFER[j = 1:N_Plant, t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= Spot_Exp_ABH[t = Start:End] <= maxVar)
    @JuMP.variable(model, minVar <= Spot_Imp_ABH[t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= Spot_Exp_USH[t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= Spot_Imp_USH[t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= IPP_Gen[t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= QSF[j = 1:N_Plant, t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= RORRV[r = 1:length(GENNODES), t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= RQSRF[j = 1:N_Plant, k = 1:N_Plant, t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= SEVSPILL[t = Start:End] <= maxVar) 
    @JuMP.variable(model, 0 <= THERMG[j = 1:N_Plant, t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= THERMGP[j = 1:N_Plant, t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= THERMQ[j = 1:N_Plant, t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= USF[j = 1:N_Plant, k = 1:N_Plant, t = Start:End] <= maxVar) 
    @JuMP.variable(model, 0 <= WINDRV[r = 1:length(GENNODES), t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= dP_Max[j = 1:N_Plant, t = Start:End] <= maxVar) 
    @JuMP.variable(model, minVar <= dQTMax[j = 1:N_Plant, t = Start:End] <= maxVar) 
    
    return model
end

# VDiff,
# MVW1,
# RRES1,
# V_Average,
# QTTEMPdQT,
# P_all,
# V,
# dQT,
# VDiffQT,
# VTEMP,
# P,
# RQSR,
# US,
# QS,
# QP,
# RQTR,
# UT,
# QT,
# G_RM_BUFFER,
# Spot_Exp_ABH,
# Spot_Imp_ABH,
# Spot_Exp_USH,
# Spot_Imp_USH,
# IPP_Gen,
# QSF,
# RORRV,
# RQSRF,
# SEVSPILL,
# THERMG,
# THERMGP,
# THERMQ,
# USF,
# WINDRV,
# dP_Max,
# dQTMax,