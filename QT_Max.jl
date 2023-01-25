function LimitPQ(param, data)
combo_num = COMBO_NUM(data)
npce = data.nnpce
Gbkp_mi = data.Gbkp_mi
Gbkp_ci = data.Gbkp_ci 
Qbkp_mi = data.Qbkp_mi
Qbkp_ci = data.Qbkp_ci 
QT_Max = zeros(N_Plant,T)
P_Max1 = zeros(N_Plant,T)
P_Max2 = zeros(N_Plant,T)
P_Max = zeros(N_Plant,T)
FB = data.FB
FB_EI = data.FB_EI
FBMAX = data.FBMAX
QP_MaxO = data.QP_MaxO
maxq = data.maxq
maxg = data.maxg
ARDQTMaxBKP = data.ARDQTMaxBKP 
ARDQTMaxY = data.ARDQTMaxY 
ARDGMaxY = data.ARDGMaxY 
ARDFBINTCPT = 424.64;
ARDGINTCPT = 425;
plntNum = 1
snpce = Int(length(ARDQTMaxY))
limit = zeros(snpce)
rate = zeros(snpce-1)
for n = 1:snpce
    limit[n] = ARDQTMaxBKP[n]
end
for n = 1:snpce-1
    rate[n] = (ARDQTMaxY[n+1] - ARDQTMaxY[n])/(ARDQTMaxBKP[n+1] - ARDQTMaxBKP[n])
end
for t = initial:T
    # Pintercept = -ARDFBINTCPT*rate[1]
    for n = 1:snpce-1
        QT_Max[plntNum,t] = max(0,ARDQTMaxY[n+1] + rate[n]*(FB[t,plntNum]-limit[n+1]))
        if FB[t,plntNum] < 425 
            QT_Max[plntNum,t] = 0
            break    
        elseif limit[n+1] >= FB[t,plntNum] && limit[n] <= FB[t,plntNum]
            QT_Max[plntNum,t] = max(0,ARDQTMaxY[n] + rate[n]*(FB[t,plntNum]-limit[n]))
            break
        end
    end
    #QT_Max[plntNum,t] = data.QTMax[t,plntNum]
end
for n = 1:snpce-1
    rate[n] = (ARDGMaxY[n+1] - ARDGMaxY[n])/(ARDQTMaxBKP[n+1] - ARDQTMaxBKP[n])
end
for t = initial:T
    # Pintercept = -ARDFBINTCPT*rate[1]
    for n = 1:snpce-1
        if FB[t,plntNum] < 100 
            P_Max[plntNum,t] = 0
            break    
        elseif limit[n+1] >= FB[t,plntNum] && limit[n] <= FB[t,plntNum]
            P_Max[plntNum,t] = max(0,ARDGMaxY[n] + rate[n]*(FB[t,plntNum]-limit[n]))
            break
        end
    end
end

for j = 2:N_Plant
    for t = initial:T
        local k = Int(combo_num[j][t])
        snpce = Int(length(FBMAX[j]))
        limit = zeros(snpce)
        rate = zeros(snpce)
        for n = 1:snpce
            limit[n] = FBMAX[j][n]
        end
        for n = 1:snpce-1
            rate[n] = (maxq[j][k,:][n+1] - maxq[j][k,:][n])/(limit[n+1] - limit[n])
        end

        Pintercept = -QP_MaxO[j][t] * rate[1]

        for n = 1:snpce-1
            QT_Max[j,t] = maxq[j][k,:][n+1] + rate[n]*(FB[t,j]-limit[n+1])
            if limit[n+1] >= FB[t,j] && limit[n] <= FB[t,j]
                QT_Max[j,t] = maxq[j][k,:][n] + rate[n]*(FB[t,j]-limit[n])
                break
            end
        end
        QT_Max[j,t] = min(QT_Max[j,t],data.QP_MaxO[j][t])
    end
end
for j = 2:N_Plant
    for t = initial:T
        k = Int(combo_num[j][t])
        snpce = Int(length(FBMAX[j]))
        limit = zeros(snpce)
        rate = zeros(snpce)
        for n = 1:snpce
            limit[n] = FBMAX[j][n]
        end
        for n = 1:snpce-1
            rate[n] = (maxg[j][k,:][n+1] - maxg[j][k,:][n])/(limit[n+1] - limit[n])
        end

        for n = 1:snpce-1
            P_Max1[j,t] = maxg[j][k,:][n+1] + rate[n]*(FB[t,j]-limit[n+1])
            if limit[n+1] >= FB[t,j] && limit[n] <= FB[t,j]
                P_Max1[j,t] = maxg[j][k,:][n] + rate[n]*(FB[t,j]-limit[n])
                break
            end
        end
    end

    for t = initial:T
        local k = Int(combo_num[j][t])
        local Qbkp = zeros(Int(npce[j][k])+1)
        local Gbkp = zeros(Int(npce[j][k])+1)
        local slope = zeros(Int(npce[j][k]))

        if t>1
            for n = 1:Int(npce[j][k])+1
                Qbkp[n] = Qbkp_mi[j][k][n]*FB[t,j] + Qbkp_ci[j][k][n]
            end
            
            for n = 1:Int(npce[j][k])+1
                Gbkp[n] = Gbkp_mi[j][k][n]*FB[t,j] + Gbkp_ci[j][k][n]
            end
        else
            for n = 1:Int(npce[j][k])+1
                Qbkp[n] = Qbkp_mi[j][k][n]*FB_EI[j] + Qbkp_ci[j][k][n]
            end
            
            for n = 1:Int(npce[j][k])+1
                Gbkp[n] = Gbkp_mi[j][k][n]*FB_EI[j] + Gbkp_ci[j][k][n]
            end
        end

        for n = 1:Int(npce[j][k])
            slope[n] = (Gbkp[n+1]-Gbkp[n])/(Qbkp[n+1]-Qbkp[n])
        end
                
        Pintercept = Gbkp[2] - slope[1]*Qbkp[2]
        Qintercept = -Pintercept/slope[1]


        for n = 1:Int(npce[j][k])
            if Qbkp[n+1] >= QP_MaxO[j][t] && Qbkp[n] <= QP_MaxO[j][t]
                P_Max2[j,t] = Gbkp[n] + slope[n]*(QP_MaxO[j][t]-Qbkp[n])
            else
                P_Max2[j,t] = Gbkp[Int(npce[j][k])] + slope[Int(npce[j][k])]*(QP_MaxO[j][t]-Qbkp[Int(npce[j][k])])
            end
        end

        P_Max[j,t] = min(P_Max1[j,t],P_Max2[j,t])

    end



end

data.P_Max1 = P_Max1
data.P_Max2 = P_Max2
data.P_Max = P_Max

data.QT_Max = QT_Max

# CSV.write("Outputs/QT_Max.csv",  Tables.table(QT_Max), writeheader=false)
# CSV.write("Outputs/P_Max.csv",  Tables.table(P_Max), writeheader=false)
end