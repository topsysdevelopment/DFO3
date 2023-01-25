function StoreElevFunction(data::DATA)
   
    se_fb_bkp = data.se_fb_bkp
    se_stor_bkp = data.se_stor_bkp

    FB_EI = data.FB_EI
    FB_Min = data.FB_Min
    FB_Max = data.FB_Max
    FB = data.FB
    Target_FB = data.Target_FB
    tfbkpt = data.tfbkpt
    RRESbkpt = data.RRESbkpt

    V_SIM = zeros(length(plant),T)
    VMin = zeros(length(plant),T)
    VMax = zeros(length(plant),T)
    tvbkpt = zeros(length(plant),length(tfbkpt[1]))
    V00 = zeros(length(plant))
    V_Target = zeros(length(plant))
    for j = 1: N_Plant
        plntNum = j
        snpce = Int(length(se_stor_bkp[plntNum]))
        limit = zeros(snpce)
        rate = zeros(snpce)
        # se_slope = zeros(snpce)
        for n = 1:snpce
            limit[n] = se_fb_bkp[plntNum][n]
        end
        for n = 1:snpce-1
            rate[n] = (se_stor_bkp[plntNum][n+1] - se_stor_bkp[plntNum][n])/(se_fb_bkp[plntNum][n+1] - se_fb_bkp[plntNum][n])
        end
        # param se_stor_intrcpt {j in plant}:= se_stor_bkp[j,2] - se_slope[j,1] * se_fb_bkp[j,2] ;
        se_stor_intrcpt = se_stor_bkp[plntNum][2] - rate[1] * se_fb_bkp[plntNum][2]
        # param se_fb_intrcpt {j in plant}:= -se_stor_intrcpt[j] / se_slope[j,1] ;				# Intercept of the f(S) with the FB axis
        se_fb_intrcpt = -se_stor_intrcpt / rate[1]

        for n = 1:snpce-1
            if limit[n+1] >= FB_EI[plntNum] && limit[n] <= FB_EI[plntNum]
                V00[plntNum] = se_stor_bkp[plntNum][n] + (se_stor_bkp[plntNum][n+1] - se_stor_bkp[plntNum][n])/(limit[n+1] - limit[n])*(FB_EI[plntNum]-limit[n])
                break
            end
        end

        for n = 1:snpce-1
            if limit[n+1] >= Target_FB[plntNum] && limit[n] <= Target_FB[plntNum]
                V_Target[plntNum] = se_stor_bkp[plntNum][n] + (se_stor_bkp[plntNum][n+1] - se_stor_bkp[plntNum][n])/(limit[n+1] - limit[n])*(Target_FB[plntNum]-limit[n])
                break
            end
        end
        for k = 1:length(tfbkpt[1])
            val = tfbkpt[plntNum][k]
            for n = 1:snpce-1
                if limit[n+1] >= val && limit[n] <= val
                    tvbkpt[plntNum,k] = se_stor_bkp[plntNum][n] + (se_stor_bkp[plntNum][n+1] - se_stor_bkp[plntNum][n])/(limit[n+1] - limit[n])*(val-limit[n])
                    break
                else
                    tvbkpt[plntNum,k] = se_stor_bkp[plntNum][n] + (se_stor_bkp[plntNum][n+1] - se_stor_bkp[plntNum][n])/(limit[n+1] - limit[n])*(val-limit[n])
                end
            end
        end
        for t = initial:T
            for n = 1:snpce-1
                if limit[n+1] >= FB_Min[t,plntNum] && limit[n] <= FB_Min[t,plntNum]
                    VMin[plntNum,t] = se_stor_bkp[plntNum][n] + (se_stor_bkp[plntNum][n+1] - se_stor_bkp[plntNum][n])/(limit[n+1] - limit[n])*(FB_Min[t,plntNum]-limit[n])
                    break
                end
            end
            for n = 1:snpce-1
                VMax[plntNum,t] = se_stor_bkp[plntNum][n+1]
                if limit[n+1] >= FB_Max[t,plntNum] && limit[n] <= FB_Max[t,plntNum]
                    VMax[plntNum,t] = max(0,se_stor_bkp[plntNum][n] + (se_stor_bkp[plntNum][n+1] - se_stor_bkp[plntNum][n])/(limit[n+1] - limit[n])*(FB_Max[t,plntNum]-limit[n]))
                    VMax[plntNum,t] = round(VMax[plntNum,t]; digits = 1)
                    break
                end
            end
            for n = 1:snpce-1
                if limit[n+1] >= FB[t,plntNum] && limit[n] <= FB[t,plntNum]
                    V_SIM[plntNum,t] = max(0,se_stor_bkp[plntNum][n] + (se_stor_bkp[plntNum][n+1] - se_stor_bkp[plntNum][n])/(limit[n+1] - limit[n])*(FB[t,plntNum]-limit[n]))
                    break
                end
            end
        end
        V_SIM[plntNum,End] = VMax[plntNum,End]
    end
    
    FB_Min = data.FB_Min
    FB_Max = data.FB_Max


    global Spill_MaxQ = zeros(N_Plant,4,End)

    for j = 2:N_Plant
        snpce = nSpill[j]
        for s = 1:snpce
            sdnpce = sd_npce[j][s]
            limit = zeros(sdnpce)
            for n = 1:sdnpce
                limit[n] = stor_spill[j][s][n]
            end
            for t = Start:End
                for n = 1:sdnpce-1
                    if limit[n+1] >= V_SIM[j,t] && limit[n] <= V_SIM[j,t]
                        Spill_MaxQ[j,s,t] = spill[j][s][n] + (spill[j][s][n+1] - spill[j][s][n])/(limit[n+1] - limit[n])*(V_SIM[j,t]-limit[n])
                        break
                    end
                end
            end
        end
    end

    data.V_SIM = V_SIM
    data.VMin = VMin
    data.VMax = VMax
    data.tvbkpt = tvbkpt
    data.V00 = V00
    data.V_Target = V_Target


end

StoreElevFunction(data)