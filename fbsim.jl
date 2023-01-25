function FBSim(data,param)
se_fb_bkp = data.se_fb_bkp
se_stor_bkp = data.se_stor_bkp
FB_Max = data.FB_Max
FB_Min = data.FB_Min
VMin = data.VMin
VMax = data.VMax
V_pre = data.V_pre
for j = 1:N_Plant
    snpce = Int(length(se_stor_bkp[j]))
    limit = zeros(snpce)
    y = zeros(snpce)
    for n = 1:snpce
        limit[n] = se_stor_bkp[j][n]
    end
    for n = 1:snpce
        y[n] = se_fb_bkp[j][n]
    end
    for t = Start:End
        for n = 1:snpce-1
            FB[t,j] = y[n+1] + (y[n+1] - y[n])/(limit[n+1] - limit[n])*(V_pre[j,t]-limit[n+1])
            if limit[n+1] >= V_pre[j,t] && limit[n] <= V_pre[j,t]
                FB[t,j] = y[n] + (y[n+1] - y[n])/(limit[n+1] - limit[n])*(V_pre[j,t]-limit[n])
                break
            end
        end
        FB[t,j] = min(FB_Max[t,j],max(FB_Min[t,j],FB[t,j]))
        FB[t,j]= round(FB[t,j]; digits = 3)
    end
end

data.FB = FB

end
