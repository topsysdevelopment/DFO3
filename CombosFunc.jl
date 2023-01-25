

function COMBO_NUM(data::DATA)

    COMBOS = data.COMBOS
    LRBCOMBO = data.LRBCOMBO
    combo_num = []
    for plntNum = 1:5
        combo_num_P = Any[]
        for t = initial:T
            k=0
            for c = 1:length(COMBOS[plntNum]) 
                k=k+1
                if Int(COMBOS[plntNum][k]) == Int(LRBCOMBO[t,plntNum])
                    push!(combo_num_P,k)
                    break
                end
            end
        end
        push!(combo_num,combo_num_P)
    end
    data.combo_num = combo_num
    return combo_num
end
combo_num = COMBO_NUM(data)

function FBmaxData(strpath::String)
    name = "combo_fbmax_sets.dat"
    strfn0 = strpath*name
    # strfn0 = "C:\\Users\\sabdolna\\Documents\\GOM-JULIA\\1973-new\\Inputs\\combo_fbmax_sets.dat"
    io=open(strfn0)
    val=readdlm(io;comments=true)       #skipstart=1
    close(io)
    row = 5
    plant = ["ARD", "GMS", "MCA", "PCN", "REV"]
    FBMAX = []
    for plntNum = 1:5
        m = Any[]
        row +=1
        plantname = plant[plntNum]
        if val[row,2]=="FBMAX[$plantname]:="
            for j = 3:length(val[row,:])
                if val[row,j] != ""
                    if val[row,j] != ";"
                        push!(m,val[row,j])
                    end
                end
            end
            FBMAX_P = m
        end
        push!(FBMAX,FBMAX_P)
    end

    return FBMAX
end


function CombosFunction(data::DATA, strpath::String)
    #JL202109. 
    nMaxRow = nStep
    #ithCol: the colum index to read
    # return number of row read
    ARD = 1
    GMS = 2
    MCA = 3
    PCN = 4
    REV = 5
    
    COMBOS = data.COMBOS
    FBMAX = FBmaxData(strpath)
    data.COMBOS = COMBOS
    data.FBMAX = FBMAX

    name = "HPGnpce.dat"
    strfnpce = strpath*name
    # strfnpce = "C:\\Users\\sabdolna\\Documents\\GOM-JULIA\\1973-new\\Inputs\\HPGnpce.dat"


    io=open(strfnpce)
    valnpce=readdlm(io;comments=true)       #skipstart=1
    close(io)
    nrowpce=size(valnpce,1)
    noffset=0
    if valnpce[1,1]=="param" noffset+=1 end
    if valnpce[2,1]==":" noffset+=1 end
    nrowpce-=noffset

    name = "HPG.dat"
    strfn = strpath*name
    # strfn = "C:\\Users\\sabdolna\\Documents\\GOM-JULIA\\1973-new\\Inputs\\HPG.dat"
    

    io=open(strfn)
    valt=readdlm(io;comments=true)       #skipstart=1
    close(io)

    ithColt = size(valt,2)
    nrowt=size(valt,1)
    noffset=0
    if valt[1,1]=="param" noffset+=1 end
    if valt[2,1]==":" noffset+=1 end
    nrowt-=noffset

    if nrowt>nMaxRow nrowt=nMaxRow    end
    
    npce = Any[]
    Gbkp_mi = Any[]
    Gbkp_ci = Any[]
    Qbkp_mi = Any[]
    Qbkp_ci = Any[]

    count = 1
    for row =ARD:REV
        if row == ARD
            npce = push!(npce,[]) 
            Gbkp_mi = push!(Gbkp_mi, []) 
            Gbkp_ci = push!(Gbkp_ci, []) 
            Qbkp_mi = push!(Qbkp_mi, []) 
            Qbkp_ci = push!(Qbkp_ci, []) 
        else
            kard = 0
            plnt = plant[row]
            for i=1:nrowt+1
                if valt[i,1] == plnt
                    kard += 1
                end
            end
            dataplnt = zeros(kard,ithColt-1)
            kard = 0
            for i=1:nrowt+1
                if valt[i,1] == plnt
                    kard += 1
                    dataplnt[kard,:] = valt[i,2:end]
                end
            end
        
        
            val = dataplnt
            nrow=size(val,1)
            ithCol = size(val,2)
        
        
            
            npce_plnt = Any[]
            Gbkp_mi_plnt = Any[]
            Gbkp_ci_plnt = Any[]
            Qbkp_ci_plnt = Any[]
            Qbkp_mi_plnt = Any[]
        
            
            for j = 1:length(COMBOS[row])
                count = count +1
                push!(npce_plnt,valnpce[count,3])
                # eval(:($(Symbol(string("npce_","GMS_$j"))) = $(valnpce[count,3])))
                kard = 0
                for i=1:nrow
                    if val[i,1] == COMBOS[row][j]
                        kard += 1
                    end
                end
                datastorage = zeros(kard,ithCol-1)
                kard = 0
                for i=1:nrow
                    if val[i,1] == COMBOS[row][j]
                        kard += 1
                        datastorage[kard,:] = val[i,2:ithCol]
                    end
                end
                push!(Gbkp_mi_plnt,datastorage[:,2])
                push!(Gbkp_ci_plnt,datastorage[:,3])
                push!(Qbkp_ci_plnt,datastorage[:,4])
                push!(Qbkp_mi_plnt,datastorage[:,5])
        
            end

            npce = push!(npce,npce_plnt) 
            Gbkp_mi = push!(Gbkp_mi, Gbkp_mi_plnt) 
            Gbkp_ci = push!(Gbkp_ci, Gbkp_ci_plnt) 
            Qbkp_mi = push!(Qbkp_mi, Qbkp_mi_plnt) 
            Qbkp_ci = push!(Qbkp_ci, Qbkp_ci_plnt) 
        end

    end

    data.nnpce = npce

    data.Gbkp_mi = Gbkp_mi
    data.Gbkp_ci = Gbkp_ci
    data.Qbkp_mi = Qbkp_mi
    data.Qbkp_ci = Qbkp_ci

end
CombosFunction(data, strpath)
