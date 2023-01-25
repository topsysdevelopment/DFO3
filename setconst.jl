
function SetStorage(param, data)
    ARD = param.ARD
    GMS = param.GMS
    MCA = param.MCA
    PCN = param.PCN
    REV = param.REV
    End = param.End
    Start = param.Start
    N_Plant = param.N_Plant
    T = param.T
    initial = param.initial
    PERIODS = data.MONTHS
    StartPeriod = data.StartMonth
    EndPeriod = data.EndMonth
    FB = data.FB
    FB_Max = data.FB_Max
    FB_Min = data.FB_Min
    FB_EI = data.FB_EI
    FB_HYSIM = zeros(T,N_Plant)
    # for j = 1:N_Plant
    #     for t = initial:T
    #         FB[t,j] = max(FB_Min[t,j],FB[t,j])
    #     end
    # end
    for j = 1:length(plant)
        for t = initial:T
            FB[t,j] = min(FB_Max[t,j],FB[t,j])
            FB[t,j] = max(FB_Min[t,j],FB[t,j])
            FB_HYSIM[t,j] = FB[t,j]
        end
    end

    for j = 1:length(plant)
        FB_Max[End,j] = FB_HYSIM[End,j]
        FB_Min[End,j] = FB_HYSIM[End,j]
        if Start == 1
            FB_EI[j] = FB_EI[j]
        else
            FB_EI[j] = FB_HYSIM[Start-1,j]
        end
    end
    data.FB = FB
    data.FB_Max = FB_Max
    data.FB_Min = FB_Min
    data.FB_EI = FB_EI


    QTTEMPdQT_pre = zeros(N_Plant,T)
    QTTEMPdQT_pre_pre = zeros(N_Plant,T)
    V_pre = zeros(N_Plant,T)
    P_LRBdQT = zeros(N_Plant,T)
    V_pre_pre = zeros(N_Plant,T)
    P_pre = zeros(N_Plant,T)
    V00 = zeros(length(plant))
    FB = data.FB
    FB_EI = data.FB_EI 
    Gbkp_mi = data.Gbkp_mi
    Gbkp_ci = data.Gbkp_ci 
    Qbkp_mi = data.Qbkp_mi
    Qbkp_ci = data.Qbkp_ci 
    for j = 1:N_Plant
        for t = initial:T
            QTTEMPdQT_pre[j,t] = data.QP_Min[t,j]
            P_LRBdQT[j,t] = data.P_LRB[t,j]
        end
    end
    data.P_LRBdQT = P_LRBdQT
    V_SIM= data.V_SIM
    se_fb_bkp = data.se_fb_bkp
    se_stor_bkp = data.se_stor_bkp
    VMin = data.VMin
    VMax = data.VMax

    for j = 1:N_Plant
        snpce = Int(length(se_stor_bkp[j]))
        limit = zeros(snpce)
        y = zeros(snpce)
        for n = 1:snpce
            limit[n] = se_fb_bkp[j][n]
        end
        for n = 1:snpce
            y[n] = se_stor_bkp[j][n]
        end
        for t = initial:T
            for n = 1:snpce-1
                if limit[n+1] >= FB[t,j] && limit[n] <= FB[t,j]
                    V_pre[j,t] = y[n] + (y[n+1] - y[n])/(limit[n+1] - limit[n])*(FB[t,j]-limit[n])
                    break
                end
            end
        end
        for t = initial:T
            for n = 1:snpce-1
                if limit[n+1] >= FB_Min[t,j] && limit[n] <= FB_Min[t,j]
                    VMin[j,t] = se_stor_bkp[j][n] + (se_stor_bkp[j][n+1] - se_stor_bkp[j][n])/(limit[n+1] - limit[n])*(FB_Min[t,j]-limit[n])
                    break
                end
            end
        end
        for t = initial:T
            for n = 1:snpce-1
                if limit[n+1] >= FB_Max[t,j] && limit[n] <= FB_Max[t,j]
                    VMax[j,t] = se_stor_bkp[j][n] + (se_stor_bkp[j][n+1] - se_stor_bkp[j][n])/(limit[n+1] - limit[n])*(FB_Max[t,j]-limit[n])
                    break
                end
            end
        end


        for n = 1:snpce-1
            if limit[n+1] >= FB_EI[j] && limit[n] <= FB_EI[j]
                V00[j] = se_stor_bkp[j][n] + (se_stor_bkp[j][n+1] - se_stor_bkp[j][n])/(limit[n+1] - limit[n])*(FB_EI[j]-limit[n])
                break
            end
        end
        
    end
    # for j = 1:N_Plant
    #     VMin[j,End] = VMin1[End,j]
    #     VMax[j,End] = VMax1[End,j]
    #     V_pre[j,End] = VMax1[End,j]
    # end
    data.V_pre = V_pre
    data.VMin = VMin
    data.VMax = VMax
    data.V00 = V00


end

