function MAXGQCalc(data::DATA)
    FBMAX = data.FBMAX
    COMBOS = data.COMBOS
    combo_num = data.combo_num

    maxg = Any[]
    maxq = Any[]
    for j = 1:N_Plant
        MaxG = data.MaxGQ[j][:,3]
        MaxQ = data.MaxGQ[j][:,4]
        xxx = zeros(length(COMBOS[j]),length(FBMAX[j]))
        yyy = zeros(length(COMBOS[j]),length(FBMAX[j]))
        k=0
        for c = 1:length(COMBOS[j])  
            for g = 1:length(FBMAX[j])
                k=k+1
                xxx[c,g] = MaxQ[k]
                yyy[c,g] = MaxG[k]
            end
        end
        push!(maxg,yyy) 
        push!(maxq,xxx) 
    end
    data.maxg = maxg
    data.maxq = maxq

end
MAXGQCalc(data)


