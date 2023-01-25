function NPWL(model,d,rate, counter)
    counter +=1
    n = length(rate)
    δ = JuMP.@variable(model, [1:n], lower_bound=0, base_name="δ_$counter")
    z1 = JuMP.@variable(model, base_name="z1_$counter")
    z2 = JuMP.@variable(model, base_name="z2_$counter")
    JuMP.@constraint(model, z1 ==  sum(δ[i]*rate[i] for i = 1:n))
    JuMP.@constraint(model, z2 ==  sum(δ[i] for i = 1:n))
    for i = 1:n-1
        if i==1
            JuMP.@constraint(model, δ[i] ≤ d[i])
        else
            JuMP.@constraint(model, δ[i] ≤ d[i]- d[i-1])
        end
    end
    return z1 , z2
end

###### VARIABLES ######
function DefineModel(model,data,param)
    Start = param.Start
    End = param.End
    GENNODES = param.GENNODES
    nStep = param.nStep
    N_Plant = param.N_Plant
    USExchRate = param.USExchRate
    BC = param.BC
    ARD = param.ARD
    GMS = param.GMS
    MCA = param.MCA
    PCN = param.PCN
    REV = param.REV

    initial = param.initial
    T = param.T
    empty!(model)
    V_pre = data.V_pre
    P_LRBdQT = data.P_LRBdQT
    HKGH = data.HKGH
    V_Target = data.V_Target
    UMVW = data.UMVW
    RORR = data.RORR
    ROR_MINh = data.ROR_MINh
    P_Max = data.P_Max
    QT_Max = data.QT_Max

    @JuMP.variable(model, V[j = 1:N_Plant, t = Start:End]) 
    @JuMP.variable(model, VDiff[j = 1:N_Plant]) 
    @constraint(model,[j=1:N_Plant], VDiff[j] == V[j,End] - V_Target[j])
    @JuMP.variable(model, V_Average[j = 1:N_Plant])
    @constraint(model,[j=1:N_Plant], V_Average[j] == (V[j,End] + V_Target[j])/2)
    @JuMP.variable(model, QTTEMPdQT[j = 1:N_Plant, t = Start:End])#, start = QTTEMPdQT_pre[j,t])
    @JuMP.variable(model, dQT[j = 1:N_Plant, t = Start:End]) 
    @JuMP.variable(model, QT[j = 1:N_Plant, t = Start:End]) 
    println("QTTEMPdQT[j,t] == QT[j,t] + dQT[j,t]")
    @constraint(model,[j=1:N_Plant, t = Start:End], QTTEMPdQT[j,t] == QT[j,t] + dQT[j,t])
    @JuMP.variable(model, P_all[j = 1:N_Plant, t = Start:End]) 
    @JuMP.variable(model, 0 <= G_RM_BUFFER[j = 1:N_Plant, t = Start:End]) 
    @JuMP.variable(model, P[j = 1:N_Plant, t = Start:End]) 
    @constraint(model,[j=1:N_Plant, t = Start:End], P_all[j,t] == P[j,t] + G_RM_BUFFER[j,t] + (P[j,t] * G_ORO[j][t]))

    @JuMP.variable(model, CURTAILFRA[t = Start:End])
    @JuMP.variable(model, VDiffQT[j = 1:N_Plant, t = Start:End])

    @JuMP.variable(model, VTEMP[j = 1:N_Plant, t = Start:End])#, start = V_pre[j,t]) 
    @JuMP.variable(model, RQSR[j = 1:N_Plant, k = 1:N_Plant, t = Start:End] ) 
    @JuMP.variable(model, US[j = 1:N_Plant, k = 1:N_Plant, t = Start:End] ) 
    @JuMP.variable(model, QS[j = 1:N_Plant, t = Start:End]>=0)
    @JuMP.variable(model, QP[j = 1:N_Plant, t = Start:End]) 
    @JuMP.variable(model, RQTR[j = 1:N_Plant, k = 1:N_Plant, t = Start:End] ) 
    @JuMP.variable(model, UT[j = 1:N_Plant, k = 1:N_Plant, t = Start:End] ) 

    @JuMP.variable(model, Spot_Exp_ABH[t = Start:End])
    @JuMP.variable(model, Spot_Imp_ABH[t = Start:End]) 
    @JuMP.variable(model, Spot_Exp_USH[t = Start:End]) 
    @JuMP.variable(model, Spot_Imp_USH[t = Start:End]) 
    @JuMP.variable(model, IPP_Gen[t = initial:T])
    @JuMP.variable(model, QSF[j = 1:N_Plant, t = Start:End]>=0) 
    @JuMP.variable(model, RORRV[t = Start:End]) 
    @JuMP.variable(model, RQSRF[j = 1:N_Plant, k = 1:N_Plant, t = Start:End] ) 
    @JuMP.variable(model, 0 <= SEVSPILL[t = Start:End]) 
    @JuMP.variable(model, USF[j = 1:N_Plant, k = 1:N_Plant, t = Start:End] ) 
    @JuMP.variable(model, 0 <= WINDRV[t = Start:End]) 
    @JuMP.variable(model, dQTMax[j = 1:N_Plant, t = Start:End]) 
    @JuMP.variable(model, dP_Max[j = 1:N_Plant, t = Start:End]) 
    @constraint(model,[t = Start:End], CURTAILFRA[t] == (1-WINDRV[t]/max(1,WINDR[t])))

    @constraint(model,[j=1:N_Plant, k=1:N_Plant, t = Start:End], UT[j,k,t] == QT[j,t] * UQT[j,k])
    @constraint(model,[j=1:N_Plant, k=1:N_Plant, t = Start:End], RQTR[j,k,t] == QT[j,t] * QTR[j,k])
    @constraint(model,[j=1:N_Plant, k=1:N_Plant, t = Start:End], US[j,k,t] == QS[j,t] * UQS[j,k])
    @constraint(model,[j=1:N_Plant, k=1:N_Plant, t = Start:End], RQSR[j,k,t] == QS[j,t] * QSR[j,k])
    @constraint(model,[j=1:N_Plant, k=1:N_Plant, t = Start:End], USF[j,k,t] == QSF[j,t] * UQS[j,k])
    @constraint(model,[j=1:N_Plant, k=1:N_Plant, t = Start:End], RQSRF[j,k,t] == QSF[j,t] * QSR[j,k])


    println("EXTRA_POWER_AB_US2WINDV_THERM")
    @JuMP.objective(model, Max,
    + sum(Spot_Imp_USH[t]*price_Imp_USH[t]*USExchRate for t = Start:End)
    + sum(Spot_Exp_USH[t]*price_Exp_USH[t]*USExchRate for t = Start:End)
    + sum(Spot_Imp_ABH[t]*price_Imp_ABH[t] for t = Start:End)
    + sum(Spot_Exp_ABH[t]*price_Exp_ABH[t] for t = Start:End)
    - sum((WINDR[t]-WINDRV[t]+RORR[t]-RORRV[t])*((14 + price_Exp_USH[t]))*USExchRate for t = Start:End)
    #- sum(THERMQ[k,t] * GasPriceh[t] for k in THERMplants, t = Start:End)
    - sum(SEVSPILL[t]*price_Exp_USH[t]*USExchRate for t = Start:End)
    - sum(QSF[p,t]*0.0001 for p = 2:N_Plant , t = Start:End)
    )

    # println("VDiffQT CALCULATION")
    # @constraint(model,[j=1:N_Plant, t = Start:End], VDiffQT[j,t] == -((VTEMP[j,t]*dQTmCoeff[j] + dQTcCoeff[j])*P_LRBdQT[j,t]/dQTPCoeff[j])/24 + ((V_pre[j,t]*dQTmCoeff[j] + dQTcCoeff[j])*P_LRBdQT[j,t]/dQTPCoeff[j])/24) 


    # println("V[j,t] == VTEMP[j,t] + VDiffQT[j,t]")
    # @constraint(model,[j=1:N_Plant, t = Start:End], V[j,t] == VTEMP[j,t] + VDiffQT[j,t])

    println("VDiffQT CALCULATION")
    @constraint(model,[j=1:N_Plant, t = Start:End], VDiffQT[j,t] == -((VTEMP[j,t]*dQTmCoeff[j] + dQTcCoeff[j])*P_LRBdQT[j,t]/dQTPCoeff[j])/24 + ((V_pre[j,t]*dQTmCoeff[j] + dQTcCoeff[j])*P_LRBdQT[j,t]/dQTPCoeff[j])/24) 

    println("dQT CALCULATION")
    @constraint(model,[j=1:N_Plant, t = Start:End], dQT[j,t] == -((VTEMP[j,t]*dQTmCoeff[j] + dQTcCoeff[j])*P_LRBdQT[j,t]/dQTPCoeff[j]) + ((V_pre[j,t]*dQTmCoeff[j] + dQTcCoeff[j])*P_LRBdQT[j,t]/dQTPCoeff[j])) 

    println("dQTMax CALCULATION")
    # @constraint(model,[j=1:N_Plant, t = Start:End], dQTMax[j,t] == (VTEMP[j,t]*dQTMaxmCoeff[j]+dQTMaxcCoeff[j]) - (V_pre[j,t]*dQTMaxmCoeff[j]+dQTMaxcCoeff[j]))
    for j = 1:N_Plant
        for t = Start:End
            if QT_Max[j,t] == 0 
                @constraint(model, dQTMax[j,t] == 0) 
            else
                @constraint(model, dQTMax[j,t] == (VTEMP[j,t]*dQTMaxmCoeff[j]+dQTMaxcCoeff[j]) - (V_pre[j,t]*dQTMaxmCoeff[j]+dQTMaxcCoeff[j]))
            end
        end
    end 

    P_Max = data.P_Max
    QT_Max = data.QT_Max
    println("dP_Max CALCULATION")
    for j = 1:N_Plant
        for t = Start:End
            if P_Max[j,t] == 0 
                @constraint(model, dP_Max[j,t] == 0) 
            else
                @constraint(model, dP_Max[j,t] == (VTEMP[j,t]*dP_MaxmCoeff[j]+dP_MaxcCoeff[j]) - (V_pre[j,t]*dP_MaxmCoeff[j]+dP_MaxcCoeff[j]))
            end
        end
    end 


    println("V[j,t] == VTEMP[j,t] + VDiffQT[j,t]")
    @constraint(model,[j=1:N_Plant, t = Start:End], V[j,t] == VTEMP[j,t]+ VDiffQT[j,t])

    VSim = V_pre #:= (<<{n in 2..se_npce[j]-1} se_fb_bkp [j,n]; {n in 1..se_npce[j]-1} se_slope[j,n] >> ( FB[j,t], se_fb_intrcpt[j])); #default VMax[j,t];
    Spill_MaxQ = Any[]
    push!(Spill_MaxQ,[1])
    for j = 2:N_Plant
        m=Any[]
        for i = 1:length(sd_npce[j])
            s = sd_npce[j]
            snpce = s
            limit = zeros(snpce[i])
            y = zeros(snpce[i])
            for n = 1:snpce[i]
                limit[n] = stor_spill[j][i][n]
            end
            for n = 1:snpce[i]
                y[n] = spill[j][i][n]
            end
            sd_slope = (y[2] - y[1])/(limit[2] - limit[1])
            sd_dis_intrcpt = -(stor_spill[j][i][2]-spill[j][i][2]/sd_slope)*sd_slope
            nn = zeros(T)
            for t = initial:T
                Val = VSim[j,t] + sd_dis_intrcpt
                for n = 1:snpce[i]-1
                    nn[t] = y[n+1] + (y[n+1] - y[n])/(limit[n+1] - limit[n])*(Val-limit[n+1])
                    if limit[n+1] >= Val && limit[n] <= Val
                        nn[t] = y[n] + (y[n+1] - y[n])/(limit[n+1] - limit[n])*(Val-limit[n])
                        break
                    end
                end
            end
            push!(m,nn)
        end
        push!(Spill_MaxQ,m)
    end

    println("ControlledSpill_Max")
    ControlledSpill_Max = @constraint(model,[j=2:N_Plant, t = Start:End], sum(max(0,Spill_MaxQ[j][s][t] * No_Spillways[j][s]) for s = 2:nSpill[j]) >= QS[j,t])
    #     subj to ControlledSpill_Max {j in SpillPlants inter SpillPlantsData, t in Start..End, h in HPLT[t]}:
    #         sum{s in 2..nSpill[j]} max(0,(Spill_MaxQ[j,s,t]*No_Spillways[j,s])) >= (QS[j,t,h]); 

    println("CONT_SPILL_RAMP_Incr")
    QSIncr = data.QSIncr
    CONT_SPILL_RAMP_Incr = @constraint(model,[j=2:N_Plant, t = Start+1:End], QS[j,t]-QS[j,t-1] <= QSIncr[j][t]) # need to fix
    # subj to CONT_SPILL_RAMP_Incr{j in SpillPlants inter SpillPlantsData, t in Start..End: t > Start}:
    # 	((sum{h in HPLT[t]} QS[j,t,h]*HPLHR[t,h]) / hours[t] - (sum{g in HPLT[t-1]} QS[j,t-1,g]*HPLHR[t-1,g]) / hours[t-1]) <= QSIncr[j,t];
    QSDecr = data.QSDecr
    println("CONT_SPILL_RAMP_Decr")
    CONT_SPILL_RAMP_Decr = @constraint(model,[j=2:N_Plant, t = Start+1:End], QS[j,t]-QS[j,t-1] >= QSDecr[j][t]) # need to fix
    # subj to CONT_SPILL_RAMP_Decr{j in SpillPlants inter SpillPlantsData, t in Start..End: t > Start}:
    # 	((sum{h in HPLT[t]} QS[j,t,h]*HPLHR[t,h]) / hours[t] - (sum{g in HPLT[t-1]} QS[j,t-1,g]*HPLHR[t-1,g]) / hours[t-1]) >= QSDecr[j,t];


    println("POWER GENERATION HK (ARD)")
    POWER_GENERATION_HK = @constraint(model,[t = Start:End], QTTEMPdQT[ARD,t] * HKGH[t] == P[ARD,t])
    # POWER_GENERATION_HK = @constraint(model,[t = Start:End], QTTEMPdQT[ARD,t] * 0.017 == P[ARD,t])

    println("POWER_GENERATION_ARD1")
    POWER_GENERATION_ARD1 = @constraint(model,[t = Start:End], P[ARD,t] >= min(QP_Min[t,ARD]*HKGH[t],QT_Max[ARD,t]*HKGH[t],P_Max[ARD,t])) 
    # # # POWER_GENERATION_ARD1 = @constraint(model,[t = Start:End], P[ARD,t] >= min(QP_Min[t,ARD]*0.17,QT_Max[ARD,t]*HKGH[t],P_Max[ARD,t])) 

    println("PLANT_SPILL_LIMIT")
    PLANT_SPILL_LIMIT = @constraint(model,[j=1:N_Plant, t = Start:End], 0 <= QS[j,t] <= data.QSMAX[j][t]) 
    @constraint(model,[t = Start:End], QS[1,t] <= QS_MaxARD[t]) 

    println("TURBINE_BOUNDS_a")
    TURBINE_BOUNDS_a = @constraint(model,[j=1:N_Plant, t = Start:End], (QT[j,t] + dQT[j,t]) >= QTMin[j][t])

    println("TURBINE_BOUNDS_b")
    TURBINE_BOUNDS_b = @constraint(model,[j=1:N_Plant, t = Start:End], (QT[j,t] + dQT[j,t] - dQTMax[j,t]) <= QT_Max[j,t])

    println("TURBINE_BOUNDS_c")
    TURBINE_BOUNDS_c = @constraint(model,[j=1:N_Plant, t = Start:End], (QT[j,t] + dQT[j,t]) <= QP_MaxO[j][t])


    println("STORAGE_BOUNDS_MINS")
    STORAGE_BOUNDS_MINS = @constraint(model,[j=1:N_Plant, t = Start:End], V[j,t] >= VMin[j,t]) 
    # STORAGE_BOUNDS_MINS = @constraint(model,[j=1:N_Plant, t = Start:End], V[j,t] >= VMin1[t,j]) 

    println("STORAGE_BOUNDS_MAXS")
    @constraint(model,[t = Start:End-1], V[ARD,t] <= fcc[t,1]) 
    @constraint(model,[t = Start:End-1], V[MCA,t] <= fcc[t,2]) 
    STORAGE_BOUNDS_MAXS = @constraint(model,[j=1:N_Plant, t = Start:End], V[j,t] <= VMax[j,t]) #max(VMin[j,t],VMax[j,t])) 
    # STORAGE_BOUNDS_MAXS = @constraint(model,[j=1:N_Plant, t = Start:End], V[j,t] <= VMax1[t,j]) #max(VMin[j,t],VMax[j,t])) 


    # OK
    println("SPOT_US_TRANS_Min")
    SPOT_US_TRANS_Min = @constraint(model,[t = Start:End], Spot_Imp_USH[t] >= -US_tran_minH[t]) 
    println("SPOT_US_TRANS_Max")
    SPOT_US_TRANS_Max = @constraint(model,[t = Start:End], US_tran_maxH[t] >= Spot_Exp_USH[t]) 
    println("SPOT_AB_TRANS_Min")
    SPOT_AB_TRANS_Min = @constraint(model,[t = Start:End], Spot_Imp_ABH[t] >= -AB_tran_minH[t]) 
    println("SPOT_AB_TRANS_Max")
    SPOT_AB_TRANS_Max = @constraint(model,[t = Start:End], AB_tran_maxH[t] >= Spot_Exp_ABH[t]) 

    @constraint(model,[t = Start:End], Spot_Imp_USH[t] <= 0) 
    @constraint(model,[t = Start:End], Spot_Exp_USH[t] >= 0) 
    @constraint(model,[t = Start:End], Spot_Imp_ABH[t] <= 0) 
    @constraint(model,[t = Start:End], Spot_Exp_ABH[t] >= 0) 

    # r in (Start+23)/card(TT[1])..End/card(TT[1])
    println("SPILL_DECINCR")
    # card(x) is the number of members ~ length(x)
    ## GOM JULIA ##
    TT = data.TT 
    ARDnum = 1
    for r = Int(floor((Start+23)/24)):Int(floor(End/24))
        local endTT = 24
        local q0 = Int(TT[r,1])
        for i = 1:endTT
            local q = Int(TT[r,i])   
            if q!= 0
                @constraint(model, QP[ARDnum,q] == QP[ARDnum,q0])
            end
        end
    end


    # OK
    G_Min_BUFFER = 0
    println("RM_BUFFER")
    RM_BUFFER = @constraint(model,[t = Start:End], sum(G_RM_BUFFER[j,t] for j = 1: N_Plant) >= G_Min_BUFFER) 



    println("POWER GENERATION HPG")
    for j = 2:N_Plant
        for t = Start:End
            local k = Int(combo_num[j][t])
            local Qbkp = zeros(Int(npce[j][k])+1)
            local Gbkp = zeros(Int(npce[j][k])+1)
            local slope = zeros(Int(npce[j][k]))
            # FB[t,j] = round(FB[t,j]; digits = 2)
            if t==1
                for n = 1:Int(npce[j][k])+1
                    Qbkp[n] = Qbkp_mi[j][k][n]*data.FB_EI[j] + Qbkp_ci[j][k][n]
                    Qbkp[n] = round(Qbkp[n]; digits = 3)
                end
                
                for n = 1:Int(npce[j][k])+1
                    Gbkp[n] = Gbkp_mi[j][k][n]*data.FB_EI[j] + Gbkp_ci[j][k][n]
                    Gbkp[n] = round(Gbkp[n]; digits = 3)
                end
            else
                for n = 1:Int(npce[j][k])+1
                    Qbkp[n] = Qbkp_mi[j][k][n]*data.FB[t,j] + Qbkp_ci[j][k][n]
                    Qbkp[n] = round(Qbkp[n]; digits = 3)
                end
                
                for n = 1:Int(npce[j][k])+1
                    Gbkp[n] = Gbkp_mi[j][k][n]*data.FB[t,j] + Gbkp_ci[j][k][n]
                    Gbkp[n] = round(Gbkp[n]; digits = 3)
                end
            end

            for n = 1:Int(npce[j][k])
                slope[n] = (Gbkp[n+1]-Gbkp[n])/(Qbkp[n+1]-Qbkp[n])
            end
            # n = Int(npce[j][k])
            # slope[n+1] = (Gbkp[n+1]-Gbkp[n])/(Qbkp[n+1]-Qbkp[n])

            Pintercept = Gbkp[2] - slope[1]*Qbkp[2]
            Qintercept = -Pintercept/slope[1]
            Pintercept = round(Pintercept; digits = 3)
            local z1
            local z2
            z1 , z2 = NPWL(model,Qbkp[2:Int(npce[j][k])+1],slope,counter)
            
            @constraint(model, z1 + Pintercept >= P[j,t]) 
            @constraint(model, QTTEMPdQT[j,t] == z2)

            # for i=1:Int(npce[j][k])
            #     @constraint(model, P[j,t] <= slope[i]*(QTTEMPdQT[j,t]-Qbkp[i]) + Gbkp[i] + Pintercept) 
            # end
        end
        
    end
    # for j = 2:N_Plant
    #     for t = Start:End
    #         @constraint(model, QTTEMPdQT[j,t] *0.5 == P[j,t])
    #     end
        
    # end


    # OK makes negative rol 2
    println("PLANT_DISCHARGE_BOUNDS")
    PLANT_DISCHARGE_BOUNDS1 = @constraint(model,[j = 1:N_Plant, t = Start:End], QP_Min[t,j] <= QP[j,t])
    PLANT_DISCHARGE_BOUNDS2 = @constraint(model,[j = 1:N_Plant, t = Start:End], QP[j,t] <= QP_Max[t,j])


    # OK
    println("GENERATION_LIMITS_1")
    OPT_Res = 0.03
    P_Max = data.P_Max
    P_Min = data.P_Min
    GENERATION_LIMITS_1 = @constraint(model,[j=2:N_Plant, t = Start:End], (1+OPT_Res)*P[j,t] - dP_Max[j,t] <= P_Max[j,t]) # need to fix
    # OK
    println("GENERATION_LIMITS_a")
    GENERATION_LIMITS_a = @constraint(model,[j = 1:N_Plant, t = Start:End], P[j,t] >= P_Min[j][t])
    # GENERATION_LIMITS_a = @constraint(model,[j = 1:N_Plant, t = Start:End], P[j,t] >= 0)
    # OK
    println("GENERATION_LIMITS_b")
    GENERATION_LIMITS_b = @constraint(model,[j = 1:N_Plant, t = Start:End], P[j,t] - dP_Max[j,t] <= P_Max[j,t])


    # # OK
    # println("GEN_INCREMENT") 
    # GEN_INCREMENT = @constraint(model,[j = 1:N_Plant, t = Start+1:End], P[j,t] - P[j,t-1] <= PIncr[j][t])
    # # OK
    # println("GEN_DECREMENT") 
    # GEN_DECREMENT = @constraint(model,[j = 1:N_Plant, t = Start+1:End], P[j,t] - P[j,t-1] >= PDecr[j][t]) 


    println("IPP_ENERGY_BUDGET")
    IPP_ENERGY_BUDGET = @constraint(model,[p = 1:length(PERIODS)], data.IPPEnergyBgt_Min[p] <= sum(IPP_Gen[t] for t = StartPeriod[p]:EndPeriod[p]) <= data.IPPEnergyBgt_Max[p] ) 

    # OK
    println("IPP_LIMITS")
    IPP_LIMITS = @constraint(model,[t = Start:End], IPP_Min[t] <= IPP_Gen[t] <= IPP_Max[t])


    # OK
    QTIncr = data.QTIncr
    QTDecr = data.QTDecr
    println("QT_INCREMENT_TS")
    QT_INCREMENT_TS = @constraint(model,[j = 1:N_Plant, t = Start+1:End], (QT[j,t] + dQT[j,t]) - (QT[j,t-1] + dQT[j,t-1]) <= QTIncr[j][t]) 
    # OK
    println("QT_DECREMENT_TS")
    QT_DECREMENT_TS = @constraint(model,[j = 1:N_Plant, t = Start+1:End], (QT[j,t] + dQT[j,t]) - (QT[j,t-1] + dQT[j,t-1]) >= QTDecr[j][t]) 


    println("CONT_SPILL_DECINCR")
    # card(x) is the number of members ~ length(x)
    ## GOM JULIA ##
    TT = data.TT 
    for j = 2:N_Plant
        for r = Int(floor((Start+23)/24)):Int(floor(End/24))
            local endTT = length(TT[r,:])
            local q0 = Int(TT[r,1])
            for i = 1:endTT
                local q = Int(TT[r,i])   
                if q!= 0
                    @constraint(model, QS[j,q] == QS[j,q0])
                end
            end
        end
    end


    # OK
    println("FREE_SPILL_RAMP_Incr")
    FREE_SPILL_RAMP_Incr = @constraint(model,[j = 1:N_Plant, t = Start+1:End], QSF[j,t] - QSF[j,t-1] <= QSFIncr[j][t])
    # OK
    println("FREE_SPILL_RAMP_Decr")
    FREE_SPILL_RAMP_Incr = @constraint(model,[j = 1:N_Plant, t = Start+1:End], QSF[j,t] - QSF[j,t-1] >= QSFDecr[j][t])



    println("GENERATION_DOWN_RESERVES")
    GENERATION_DOWN_RESERVES = @constraint(model,[t = Start:End], sum(P[j,t] for j = 2: N_Plant) >=  sum(P_Min[j][t] for j = 2: N_Plant) + LTotalDNResT[t] + (1-CURTAILFRA[t])*WTotalDNResT[t]) 
    # GENERATION_DOWN_RESERVES = @constraint(model,[t = Start:End], sum(P[j,t] for j = 2: N_Plant) >= LTotalDNResT[t] + (1-CURTAILFRA[t])*WTotalDNResT[t]) 

    println("GENERATION_UP_RESERVES_Temp")
    GENERATION_UP_RESERVES_Temp = @constraint(model,[t = Start:End], sum(P[j,t] for j = 2: N_Plant) <= 
        + sum(P_Max[j,t]+dP_Max[j,t] for j = 2: N_Plant)
        - sum(P[j,t] * G_ORO[j][t] for j = 1: N_Plant)
        + SH_Reserve_noR[t] - (IPP_ORO*IPPR[t]) 
        + max(THERM_Cap, BURR[t]) - BURR[t]
        - THERM_ORO*BURR[t]
        # + sum{k in THERMplants} (THERMGMax[k,t]*GAS_OUTAGE[k,t]) - sum {k in THERMplants} THERMG[k,t,h]
        # - sum{k in THERMplants} (THERM_ORO*THERMG[k,t,h])
        - (1-CURTAILFRA[t])* WTotalUpResT[t]
        )


    # OK
    P_Imports = zeros(End)
    P_Exports = zeros(End)
    ARDFLOW = zeros(End)
    PREEXPIMP = data.PREEXPIMP
    for t = Start:End
        P_Imports[t] = max(0,PREEXPIMP[t])
        P_Exports[t] = -min(0,PREEXPIMP[t])
        ARDFLOW[t] = (QP_Max[t,ARD]+ QP_Min[t,ARD])/2
    end
    println("LOAD_BALANCE_SPOT_IPPWV_THERM")
    ROR_HYSIM = data.ROR_HYSIM
    LOAD_BALANCE_SPOT_IPPWV_THERM = @constraint(model,[t = Start:End], sum(P[j,t] for j = 1:N_Plant)
    + IPP_Gen[t] 
    + RORRV[t] - ROR_HYSIM[t] + WINDRV[t] + RES_HYDROR[t]
    + IPPR[t] + BURR[t]
    + NTS[t] + P_Imports[t] - P_Exports[t] - SEVSPILL[t]
    - Spot_Imp_USH[t] - Spot_Exp_USH[t] - Spot_Imp_ABH[t] - Spot_Exp_ABH[t]
    + (QP[ARD,t] - ARDFLOW[t])/0.3048^3/1000* HKARD[t]/2
    == LOADHR[t]) #

    # OK
    println("PLANT_DISCHARGE_QSF")
    PLANT_DISCHARGE_QSF = @constraint(model,[j = 1:N_Plant, t = Start:End], (QT[j,t]+ dQT[j,t]) + QS[j,t] + QSF[j,t] == QP[j,t])


    # OK
    println("ROR_CURTAIL")
    ROR_CURTAIL= @constraint(model,[t = Start:End],ROR_MINh[t] <= RORRV[t] <= RORR[t]) 
    # subject to ROR_CURTAIL{r in GENNODES, t in Start..End, h in HPLT[t]}:
    # ROR_MINh[r,t,h] <= RORRV[r,t,h] <= RORR[r,t,h];

    # OK
    println("SEVSPILLMAX")
    SEVSPILLMAX = @constraint(model,[t = Start:End], data.SEVMINGENh[t] <= SEVSPILL[t] <= data.SEVGENh[t]) 


    # OK
    VDecr = data.VDecr
    println("STORAGE_DECREMENT")
    STORAGE_DECREMENT = @constraint(model,[j = 1:N_Plant, t = Start+1:End], (V[j,t] - V[j,t-1]) >= VDecr[t,j]) 

    # OK
    VIncr = data.VIncr
    println("STORAGE_INCREMENT")
    STORAGE_INCREMENT = @constraint(model,[j = 1:N_Plant, t = Start+1:End], (V[j,t] - V[j,t-1]) <= VIncr[t,j]) 


    println("STORAGE_QSF")
    # OK
    V00 = data.V00
    for k = 1:N_Plant
        V00[k] = round(V00[k]; digits = 1)
    end
    STORAGE_QSF_0 = @constraint(model,[k = 1:N_Plant, t = [Start]],  V00[k] #V_pre[k, t-1]
    + (-sum(RQTR[j,k,t] for j = 1:N_Plant)
        -sum(RQSR[j,k,t] for j = 1:N_Plant)
        -sum(RQSRF[j,k,t] for j = 1:N_Plant)
        +sum(UT[j,k,t] for j = 1:N_Plant)
        +sum(US[j,k,t] for j = 1:N_Plant)
        +sum(USF[j,k,t] for j = 1:N_Plant)
        +QIR[t,k]) / 24 == VTEMP[k,t])

    STORAGE_QSF = @constraint(model,[k = 1:N_Plant, t = Start+1:End], VTEMP[k, t-1] 
    + (-sum(RQTR[j,k,t] for j = 1:N_Plant)
        -sum(RQSR[j,k,t] for j = 1:N_Plant)
        -sum(RQSRF[j,k,t] for j = 1:N_Plant)
        +sum(UT[j,k,t] for j = 1:N_Plant)
        +sum(US[j,k,t] for j = 1:N_Plant)
        +sum(USF[j,k,t] for j = 1:N_Plant)
        +QIR[t,k]) / 24 == VTEMP[k,t])


    # OK
    println("UNCONT_SPILL_DECINCR")
    # card(x) is the number of members ~ length(x)
    # SpillPlants is empty
    TT = data.TT 
    for j = 2:N_Plant
        for r = Int(floor((Start+23)/24)):Int(floor(End/24))
            local endTT = length(TT[r,:])
            local q0 = Int(TT[r,1])
            for i = 1:endTT
                local q = Int(TT[r,i])   
                if q!= 0
                    @constraint(model, QSF[j,q] == QSF[j,q0])
                end
            end
        end
    end



    println("UnControlledSpill_NonSpill")
    UnControlledSpill_NonSpill = @constraint(model,[t = Start:End], QSF[ARD,t] == 0 )
    #     subj to UnControlledSpill_NonSpill {j in plant, t in Start..End, h in HPLT[t]: j not in SpillPlants}:
    #         (QSF[j,t,h]) = 0;


    # OK
    println("WINDCURTAIL")
    WINDCURTAIL = @constraint(model,[t = Start:End], WIND_MINh[t] <= WINDRV[t] <= data.WINDR[t])


    println("ICE_CONTROL")
    nDayIce = 21
    iPltIce = 6
    itsIce = 2209
    nTSPerDay = 24
    QPIce = 1472
    for i=1:nDayIce
        @constraint(model, sum(QP[PCN,j] for j=itsIce:itsIce+nTSPerDay-1)== QPIce *nTSPerDay)
        itsIce+=nTSPerDay
    end


return model

end





































