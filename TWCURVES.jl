combo_num = COMBO_NUM(data)


function TWCurves(data::DATA)
    FB = data.FB
    QPTEMP = data.QPTEMP
    DSQ_ARD = data.QIRTRL
    # DSQ_GMS = FB[PCN]
    # DSQ_MCA = FB[REV]
    # DSQ_PCN = 460.17 
    # DSQ_REV = FB[ARD]
    # DSQ = Any[]
    # DSQ = [DSQ_ARD, DSQ_GMS, DSQ_MCA, DSQ_PCN, DSQ_REV]

    j=ARD
    col = zeros(T)
    row = zeros(T)
    TWLR1 = zeros(T)
    TWLR2 = zeros(T)
    TWLC = zeros(T)
    for t = Start:End
        snpce = Int(length(DSC_ARD))
        for n = 1:snpce-1
            if DSC_ARD[n+1] >= DSQ_ARD[t] && DSC_ARD[n] <= DSQ_ARD[t]
                col[t] = n-1
                break
            end
        end
        snpce = Int(length(TWQ_ARD))
        for n = 1:snpce-1
            if TWQ_ARD[n+1] >= QPTEMP[j,t] && TWQ_ARD[n] <= QPTEMP[j,t]
                row[t] = n
                break
            end
        end
        # if TWQ_ARD[snpce] <= QPTEMP[j,t]
        #     row[t] = snpce-1
        # end
        rowint = Int(row[t])
        colint = Int(col[t])
        TWLR1[t] = TailWater_ARD[rowint,colint] + ((TailWater_ARD[rowint,colint+1]-TailWater_ARD[rowint,colint])/(DSC_ARD[colint+2]-DSC_ARD[colint+1]))*(DSQ_ARD[t]-DSC_ARD[colint+1])
        TWLR2[t] = TailWater_ARD[rowint+1,colint] + ((TailWater_ARD[rowint+1,colint+1]-TailWater_ARD[rowint+1,colint])/(DSC_ARD[colint+2]-DSC_ARD[colint+1]))*(DSQ_ARD[t]-DSC_ARD[colint+1])
        TWLC[t] = TWLR1[t] + ((TWLR2[t]-TWLR1[t])/(TWQ_ARD[rowint+1] - TWQ_ARD[rowint]))*(QPTEMP[j,t]-TWQ_ARD[rowint])
    end
    

    head_ARD = zeros(T)
    QS_MaxARD = zeros(T)
    j=1
    for t = initial:T
        global head_ARD[t] = FB[t,j] - TWLC[t]
        if head_ARD[t]<17
            QS_MaxARD[t] = (1.4570377E+01*FB[t,j]^2 - 1.1915457E+04*FB[t,j] + 2.4375638E+06)
        else
            QS_MaxARD[t] = (1.6852321E+01*FB[t,j]^2 - 1.4100462E+04*FB[t,j] + 2.9488787E+06)
        end
    end

    data.QS_MaxARD = QS_MaxARD
    HKGH = zeros(T)
    for t = initial:T
        if data.combo_num[1][t]<=2
            GH = data.GH[1:51]
            HKAriGH = data.HKAriGH[1:51]
        else
            GH = data.GH[52:102]
            HKAriGH = data.HKAriGH[52:102]
        end

        snpce = Int(length(GH))
        limit = zeros(snpce)
        rate = zeros(snpce)
        for n = 1:snpce
            limit[n] = GH[n]
        end
        for n = 1:snpce-1
            rate[n] = (HKAriGH[n+1] - HKAriGH[n])/(GH[n+1] - GH[n])
        end
        for n = 1:snpce-1
            HKGH[t] = HKAriGH[n+1]+ rate[n]*(head_ARD[t]-limit[n+1])
            if limit[n+1] >= head_ARD[t] && limit[n] <= head_ARD[t]
                HKGH[t] = HKAriGH[n] + rate[n]*(head_ARD[t]-limit[n])
                HKGH[t] = round(HKGH[t]; digits = 6)
                break
            end
        end
    end
    data.HKGH = HKGH

end
TWCurves(data)
