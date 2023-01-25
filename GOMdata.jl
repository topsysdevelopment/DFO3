using CSV, Tables
## combo_fbmax_sets.dat;
# start
function CombosData(strpath::String,plant)
    name = "combo_fbmax_sets.dat"
    strfn0 = strpath*name
    # strfn0 = "C:\\Users\\sabdolna\\Documents\\GOM-JULIA\\1973-new\\Inputs\\combo_fbmax_sets.dat"
    io=open(strfn0)
    val=readdlm(io;comments=true)       #skipstart=1
    close(io)
    
    COMBOS = Any[]
    for row = ARD:REV
        m = Any[]
        plnt = plant[row]
        if val[row,2]=="COMBOS[$plnt]:="
            for j = 3:length(val[row,:])
                if val[row,j] != ""
                    if val[row,j] != ";"
                        push!(m,val[row,j])
                    end
                end
            end
            COMBOS_row = m
        end
        push!(COMBOS,COMBOS_row)
    end
    data.COMBOS = COMBOS
    return COMBOS
end


function ReadSysData(param::PARAM, data::DATA, strpath::String, End)
    # start
    global plant = ["ARD", "GMS", "MCA", "PCN", "REV"]
    # end SetHydroPlant.dat
    ## SetFCCPlant.dat
    # start
    global FCCPLANT = ["ARD", "MCA"]
    # end SetFCCPlant.dat
        ## HPLHR.dat
    # start
    global HPLHR = ones(T)
    # end HPLHR.dat
    ## SetHydroPlant.dat

    ## data SetPSPlant.dat;
    ## data SetThermPlant.dat;
    ## SetRegion.dat
    # start
    global GENNODES = ["BC"]
    # end
    N_Plant = param.N_Plant
    # Input forecast data
    global nMaxRow = param.nStep
    ## mis_info.dat
    # start
    data.QPTEMP = zeros(N_Plant,T)
    global dt = 3600
    global IPP_ORO = 0.14
    global THERM_ORO = 0.14
    global THERM_Cap = 285	#MW, 285 is ICG capacity.
    global DepCap =8640;	#MW, Dependable Capacity of modelled plants. Current setting is for GMS+PCN+MCA5+REV5+ARD.
                #Numbers for reference: M4R5=7640, M5R5=8105,M6R5=8565
                #Dependable Cap: GMS2680, PCN660, M1-4=1710,M5=465,M=460, REV1-4=2000, REV5=470, ARD=120
    global G_Min_BUFFER = 0
    global USExchRate = 1.0
    global	RRESNPOINTS	= 5
    global	RRESBKP	= [-202500 -105000 0 202500 322500]
    global	RRESLOPE = [-8.76E-05 -6.35E-05 -3.14E-05 -1.58E-05]
    #Wind installed capacity and penatration.
    global WIND_IC = 717.2
    ## end mis_info.dat
    ## hplsets.dat
    # start
    # end hplsets.dat
    CombosData(strpath, plant)
    # end combo_fbmax_sets.dat
    ## setTT.dat
    # start
    setTTCalc(data, strpath)
    # end setTT.dat
    ## months.dat
    # start
    global MONTHS = [1202210    1202211    1202212    1202301    1202302    1202303    1202304    1202305    1202306    1202307    1202308    1202309    2202210    2202211    2202212    2202301    2202302    2202303    2202304    2202305    2202306    2202307    2202308    2202309]
    global dayMonth = [31    30    31    31    28    31    30    31    30    31    31    30    31    30    31    31    28    31    30    31    30    31    31    30]
    global StartMonth = [1    745    1465    2209    2953    3625    4369    5089    5833    6553    7297    8041    8761    9505    10225    10969    11713    12385    13129    13849    14593    15313    16057    16801]
    global EndMonth = [744    1464    2208    2952    3624    4368    5088    5832    6552    7296    8040    8760    9504    10224    10968    11712    12384    13128    13848    14592    15312    16056    16800    17520]
    data.MONTHS = MONTHS
    data.dayMonth = dayMonth
    data.StartMonth = StartMonth
    data.EndMonth = EndMonth
    # end months.dat





    ## PlantPar.dat
    # start
    se_npce = [67 34 157 11 25]
    tvbkpTot = [5 5 5 5 5]
    dQTmCoeff = [0 -0.000443386 -0.00197622 -0.508795 -0.00993281]
    dQTcCoeff = [0 986.163 1004.64 1579.82 1578.92]
    dQTPCoeff = [70 1393.99 1433.65 535.148 1835.52]
    Rbch = [27.8069 27.8069 27.8069 27.8069 27.8069]
    DSCSPUC = [0 502.5 572 0 438.3]
    FB_DiffDB = [0 0 0 0 0]
    dP_MaxmCoeff = [0 0 0 0.252505 0.017253]
    dP_MaxcCoeff = [0 0 0 0 0]
    dP_MaxPCoeff = [1 1 1 1 1]
    dQTMaxmCoeff = [0 0 0 0.191139 0.004501]
    dQTMaxcCoeff = [0 0 0 0 0]
    dQTMaxPCoeff = [1 1 1 1 1]
    	
    data.se_npce = se_npce
    data.tvbkpTot = tvbkpTot
    data.dQTmCoeff = dQTmCoeff
    data.dQTcCoeff = dQTcCoeff
    data.dQTPCoeff = dQTPCoeff
    data.Rbch = Rbch
    data.DSCSPUC = DSCSPUC
    data.FB_DiffDB = FB_DiffDB
    data.dP_MaxmCoeff = dP_MaxmCoeff
    data.dP_MaxcCoeff = dP_MaxcCoeff
    data.dP_MaxPCoeff = dP_MaxPCoeff
    data.dQTMaxmCoeff = dQTMaxmCoeff
    data.dQTMaxcCoeff = dQTMaxcCoeff
    data.dQTMaxPCoeff = dQTMaxPCoeff
    # end PlantPar.dat

    ## NewMatrx.dat
    # start 
    UQT = zeros(N_Plant,N_Plant)
    UQT[GMS,PCN] = 1
    UQT[MCA,REV] = 1
    UQT[REV,ARD] = 1
    data.UQT = UQT
    UQS = zeros(N_Plant,N_Plant)
    UQS[GMS,PCN] = 1
    UQS[MCA,REV] = 1
    UQS[REV,ARD] = 1
    data.UQS = UQS
    QTR = zeros(N_Plant,N_Plant)
    QTR[ARD,ARD] = 1
    QTR[GMS,GMS] = 1
    QTR[MCA,MCA] = 1
    QTR[PCN,PCN] = 1
    QTR[REV,REV] = 1
    data.QTR = QTR
    QSR = zeros(N_Plant,N_Plant)
    QSR[ARD,ARD] = 1
    QSR[GMS,GMS] = 1
    QSR[MCA,MCA] = 1
    QSR[PCN,PCN] = 1
    QSR[REV,REV] = 1
    data.QSR = QSR
    UMVW = zeros(N_Plant,N_Plant)
    UMVW[GMS,PCN] = 1
    UMVW[MCA,REV] = 1
    UMVW[REV,ARD] = 1
    data.UMVW = UMVW
    # end NewMatrx.dat

    ## StorElev.dat
    # start
    name = "StorElev.dat"
    strfn = strpath*name
    ithCol = 4
    dataREV, dataPCN, dataMCA, dataGMS, dataARD = ReadDataMat!_2(strfn,nMaxRow, ithCol)
    se_npce = zeros(N_Plant)
    se_npce[1] = length(dataARD[:,1])
    se_npce[2] = length(dataGMS[:,1])
    se_npce[3] = length(dataMCA[:,1])
    se_npce[4] = length(dataPCN[:,1])
    se_npce[5] = length(dataREV[:,1])
    data.se_npce = se_npce
    se_fb_bkp_GMS = dataGMS[:,end-1]
    se_stor_bkp_GMS = dataGMS[:,end]
    se_fb_bkp_PCN = dataPCN[:,end-1]
    se_stor_bkp_PCN = dataPCN[:,end]
    se_fb_bkp_MCA = dataMCA[:,end-1]
    se_stor_bkp_MCA = dataMCA[:,end]
    se_fb_bkp_REV = dataREV[:,end-1]
    se_stor_bkp_REV = dataREV[:,end]
    se_fb_bkp_ARD = dataARD[:,end-1]
    se_stor_bkp_ARD = dataARD[:,end]
    se_fb_bkp = Vector{Vector{Float64}}([se_fb_bkp_ARD,se_fb_bkp_GMS,se_fb_bkp_MCA,se_fb_bkp_PCN,se_fb_bkp_REV])
    se_stor_bkp = Vector{Vector{Float64}}([se_stor_bkp_ARD,se_stor_bkp_GMS,se_stor_bkp_MCA,se_stor_bkp_PCN,se_stor_bkp_REV])
    data.se_fb_bkp = se_fb_bkp
    data.se_stor_bkp = se_stor_bkp


    ## THMcoeff.dat; 
    ## Wind_HYSIM.dat
    ## SetSpillPlant.dat


    ## SetIPPPlant.dat
    # start
    IPPSet = "ALN"
    # end SetIPPPlant.dat

    ## RRES.dat
    # start
    name = "RRES.dat"
    strfn = strpath1*name
    ithCol = 4
    dataREV, dataPCN, dataMCA, dataGMS, dataARD = ReadDataMat!_2(strfn,nMaxRow, ithCol)
    RRESGMS = dataGMS
    RRESMCA = dataMCA
    RRESREV = dataREV
    RRESPCN = dataPCN
    RRESARD = dataARD
    data.RRES = Array{Array{Float64}}([RRESARD, RRESGMS,RRESMCA,RRESPCN,RRESREV])
    data.tfbkpt  = [RRESARD[:,2],RRESGMS[:,2],RRESMCA[:,2],RRESPCN[:,2],RRESREV[:,2]]
    data.RRESbkpt = [RRESARD[:,3],RRESGMS[:,3],RRESMCA[:,3],RRESPCN[:,3],RRESREV[:,3]]
    # end RRES.dat

    ## HPGnpce.dat
    # start
    name = "HPGnpce.dat"
    strfn = strpath*name
    ithCol = 3
    dataREV, dataPCN, dataMCA, dataGMS, dataARD = ReadDataMat!_2(strfn,nMaxRow, ithCol)
    npceGMS = dataGMS
    npceMCA = dataMCA
    npceREV = dataREV
    npcePCN = dataPCN
    data.npce = Array{Array{Int64}}([[],npceGMS,npceMCA,npcePCN,npceREV])
    # end HPGnpce.dat

    ## HPG.dat
    # start
    name = "HPG.dat"
    strfn = strpath*name
    ithCol = 7
    dataREV, dataPCN, dataMCA, dataGMS, dataARD = ReadDataMat!_2(strfn,nMaxRow, ithCol)
    bkpGMS = dataGMS
    bkpMCA = dataMCA
    bkpREV = dataREV
    bkpPCN = dataPCN
    data.bkp = Array{Array{Float64}}([[],bkpGMS,bkpMCA,bkpPCN,bkpREV])
    # end HPG.dat


    ## MAXGQ.dat
    # start
    name = "MAXGQ.dat"
    strfn = strpath*name
    ithCol = 5
    maxGQREV, maxGQPCN, maxGQMCA, maxGQGMS, maxGQARD = ReadDataMat!_2(strfn,nMaxRow, ithCol)
    MaxGQREV = maxGQREV
    MaxGQPCN = maxGQPCN
    MaxGQMCA = maxGQMCA
    MaxGQGMS = maxGQGMS
    MaxGQARD = maxGQARD
    data.MaxGQ = Array{Array{Float64}}([MaxGQARD,MaxGQGMS,MaxGQMCA,MaxGQPCN,MaxGQREV])
    # end MAXGQ.dat

    ## HK.dat
    # start
    name = "HK.dat"
    strfn = strpath*name
    ithCol = 5
    HK = ReadDataMat!(strfn,nMaxRow, ithCol)
    data.GH = HK[:,3]
    data.HKAriGH = HK[:,4]
    # end HK.dat

    ## HKARD.dat
    # start
    name = "HKARD.dat"
    strfn = strpath1*name
    ithCol = 2
    data.HKARD = ReadDataCol!(strfn,nMaxRow, ithCol)  
    # end HKARD.dat

    ## COMBO.dat
    # start
    name = "COMBO.dat"
    strfn = strpath*name
    ithCol = 6
    data.LRBCOMBO = ReadDataMat!(strfn,nMaxRow, ithCol)
    # end COMBO.dat

    ## ComboGas.dat
    GAS_OUTAGE = []

    ## FB.dat
    # start
    name = "FB.dat"
    strfn = strpath1*name
    ithCol = 6
    data.FB = ReadDataMat!(strfn,nMaxRow, ithCol)
    # end FB.dat
    # name = "FB.dat"
    # strfn = strpath*name
    # ithCol = 3 
    # ValueREV, ValuePCN, ValueMCA, ValueGMS, ValueARD = ReadDataMat!_2(strfn,100000, ithCol)
    # data.FB = Array{Array{Float64}}([ValueARD[:,2], ValueGMS[:,2], ValueMCA[:,2], ValuePCN[:,2], ValueREV[:,2]])



    ## FBini.dat
    # start
    name = "FBini.dat"
    strfn = strpath1*name
    ithCol = 2
    data.FB_EI = ReadDataCol!(strfn,nMaxRow, ithCol)  
    # end FBini.dat

    ## FBmax.dat
    # start
    name = "FBmax.dat"
    strfn = strpath1*name
    ithCol = 6
    data.FB_Max = ReadDataMat!(strfn,nMaxRow, ithCol)
    # end FBmax.dat
    # name = "FBmax.dat"
    # strfn = strpath*name
    # ithCol = 3 
    # ValueREV, ValuePCN, ValueMCA, ValueGMS, ValueARD = ReadDataMat!_2(strfn,100000, ithCol)
    # data.FB_Max = Array{Array{Float64}}([ValueARD[:,2], ValueGMS[:,2], ValueMCA[:,2], ValuePCN[:,2], ValueREV[:,2]])


    ## FBmin.dat
    # start
    name = "FBmin.dat"
    strfn = strpath1*name
    ithCol = 6
    data.FB_Min = ReadDataMat!(strfn,nMaxRow, ithCol)
    # end FBmin.dat

    ## FBtarget.dat
    # start
    name = "FBtarget.dat"
    strfn = strpath1*name
    ithCol = 3
    Target = ReadDataMat!(strfn,nMaxRow, ithCol)
    data.Target_FB = Target[:,1]
    data.Target_Hr = Target[:,2]
    # end FBtarget.dat

    ## FCC.dat
    # start
    name = "FCC.dat"
    strfn = strpath1*name
    ithCol = 3
    data.fcc = ReadDataMat!(strfn,nMaxRow, ithCol)
    # end FCC.dat

    ## GDECR.dat
    # start
    name = "GDECR.dat"
    strfn = strpath*name
    ithCol = 3
    PREV, PPCN, PMCA, PGMS, PARD = ReadDataMat!_2(strfn,100000, ithCol)
    data.PDecr = Array{Array{Float64}}([PARD[:,2], PGMS[:,2], PMCA[:,2], PPCN[:,2], PREV[:,2]])
    # data.PDecr = -10000*ones(End,5)
    # end GDECR.dat

    ## Gincr.dat
    # start
    name = "Gincr.dat"
    strfn = strpath*name
    ithCol = 3
    PREV, PPCN, PMCA, PGMS, PARD = ReadDataMat!_2(strfn,100000, ithCol)
    data.PIncr = Array{Array{Float64}}([PARD[:,2], PGMS[:,2], PMCA[:,2], PPCN[:,2], PREV[:,2]])
    # data.PIncr = 10000*ones(End,5)
    # end Gincr.dat


    ## Gmin.dat
    # start
    name = "Gmin.dat"
    strfn = strpath*name
    ithCol = 3 
    P_MinREV, P_MinPCN, P_MinMCA, P_MinGMS, P_MinARD = ReadDataMat!_2(strfn,100000, ithCol)
    data.P_Min = Array{Array{Float64}}([P_MinARD[:,2], P_MinGMS[:,2], P_MinMCA[:,2], P_MinPCN[:,2], P_MinREV[:,2]])
    # end Gmin.dat

    # ## QPmin.dat
    # # start
    # name = "P_Min.dat"
    # strfn = strpath*name
    # ithCol = 6
    # data.P_Min = ReadDataMat!(strfn,nMaxRow, ithCol)
    # # end QPmin.dat


    ## IPP.dat
    # start
    name = "IPP.dat"
    strfn = strpath1*name
    ithCol = 4
    data.IPPR = ReadDataCol!(strfn,nMaxRow, ithCol)  
    # end IPP.dat

    ## IPPGMAX.dat
    # start
    name = "IPPGMAX.dat"
    strfn = strpath*name
    ithCol = 3
    data.IPP_Max = ReadDataCol!(strfn,nMaxRow, ithCol)  
    # end IPPGMAX.dat


    ## IPPGMIN.dat
    # start
    name = "IPPGMIN.dat"
    strfn = strpath*name
    ithCol = 3
    data.IPP_Min = ReadDataCol!(strfn,nMaxRow, ithCol) 
    # end IPPGMIN.dat

    ## IPPenergy.dat
    # start
    name = "IPPenergy.dat"
    strfn = strpath1*name
    ithCol = 4
    data.IPPEnergyBgt_Min = ReadDataCol!(strfn,nMaxRow, ithCol)  
    data.IPPEnergyBgt_Max = ReadDataCol!(strfn,nMaxRow, ithCol)  
    # end IPPenergy.dat


    ## LOAD.dat
    # start
    name = "LOAD.dat"
    strfn = strpath*name
    ithCol = 4
    data.LOADHR = ReadDataCol4!(strfn,nMaxRow, ithCol)  
    # end LOAD.dat

    ## NTS.dat
    # start
    name = "NTS.dat"
    strfn = strpath1*name
    ithCol = 3
    data.NTS = ReadDataCol!(strfn,nMaxRow, ithCol)  
    # end NTS.dat

    ## ORO.dat
    # start
    name = "ORO.dat"
    strfn = strpath*name
    ithCol = 3
    # data.G_ORO = ReadDataCol!(strfn,nMaxRow, ithCol)
    G_OROREV, G_OROPCN, G_OROMCA, G_OROGMS, G_OROARD = ReadDataMat!_2(strfn,nMaxRow, ithCol)
    G_ORO = Array{Array{Float64}}([G_OROARD[:,2],G_OROGMS[:,2],G_OROMCA[:,2],G_OROPCN[:,2],G_OROREV[:,2]])
    data.G_ORO = G_ORO

    ## PExpAB.dat
    # start
    name = "PExpAB.dat"
    strfn = strpath1*name
    ithCol = 3
    V2, n = ReadDataCol3!(strfn,nMaxRow, ithCol)
    price_Exp_ABH = V2[:,2]
    data.price_Exp_ABH = price_Exp_ABH
    # include("PEXPAB69.jl")
    # data.price_Exp_ABH = price_Exp_ABH
    # end PExpAB.dat

    ## PExpUS.dat
    # start
    name = "PExpUS.dat"
    strfn = strpath1*name
    ithCol = 3
    V2, n = ReadDataCol3!(strfn,nMaxRow, ithCol)
    price_Exp_USH = V2[:,2]
    data.price_Exp_USH = price_Exp_USH
    # include("PEXPUS69.jl")
    # data.price_Exp_USH = price_Exp_USH
    # end PExpUS.dat

    # data PGasStn2.dat;
    ## data PGasSumas.dat;
    name = "PGasSumas.dat"
    strfn = strpath*name
    ithCol = 2
    data.GasPriceh = ReadDataCol!(strfn,nMaxRow, ithCol)
    # end 

    ## PImpAB.dat
    # start
    name = "PImpAB.dat"
    strfn = strpath1*name
    ithCol = 3
    V2, n = ReadDataCol3!(strfn,nMaxRow, ithCol)
    price_Imp_ABH = V2[:,2]
    data.price_Imp_ABH = price_Imp_ABH
    # include("PIMPAB69.jl")
    # data.price_Imp_ABH = price_Imp_ABH
    # end PImpAB.dat


    ## PImpUS.dat
    # start
    name = "PImpUS.dat"
    strfn = strpath1*name
    ithCol = 3
    V2, n = ReadDataCol3!(strfn,nMaxRow, ithCol)
    price_Imp_USH = V2[:,2]
    data.price_Imp_USH = price_Imp_USH
    # include("PIMPUS69.jl")
    # data.price_Imp_USH = price_Imp_USH
    # end PImpUS.dat


    ## PREEXPIMP.dat
    # start
    name = "PREEXPIMP.dat"
    strfn = strpath1*name
    ithCol = 3
    data.PREEXPIMP = ReadDataCol!(strfn,nMaxRow, ithCol)
    # end PREEXPIMP.dat

    ## PStep.dat
    # start
    name = "PStep.dat"
    strfn = strpath1*name
    ithCol = 6
    data.P_LRB = ReadDataMat!(strfn,nMaxRow, ithCol)
    # end PStep.dat

    ## QIR.dat
    # start
    name = "QIR.dat"
    strfn = strpath1*name
    ithCol = 6
    data.QIR = ReadDataMat!(strfn,nMaxRow, ithCol)
    # end QIR.dat

    
    ## QIRTRL.dat
    # start
    name = "QIRTRL.dat"
    strfn = strpath1*name
    ithCol = 2
    data.QIRTRL = ReadDataCol!(strfn,nMaxRow, ithCol)
    # end QIRTRL.dat


    ## QPmax.dat
    # start
    name = "QPmax.dat"
    strfn = strpath1*name
    ithCol = 6
    data.QP_Max = ReadDataMat!(strfn,nMaxRow, ithCol)
    # end QPmax.dat

    ## QPmin.dat
    # start
    name = "QPmin.dat"
    strfn = strpath1*name
    ithCol = 6
    data.QP_Min = ReadDataMat!(strfn,nMaxRow, ithCol)
    # end QPmin.dat

    ## QSFREEdecr.dat
    # start
    name = "QSFREEdecr.dat"
    strfn = strpath*name
    ithCol = 3
    QSFDecrREV, QSFDecrPCN, QSFDecrMCA, QSFDecrGMS, QSFDecrARD = ReadDataMat!_2(strfn,100000, ithCol)
    data.QSFDecr = Array{Array{Float64}}([QSFDecrARD[:,2], QSFDecrGMS[:,2], QSFDecrMCA[:,2], QSFDecrPCN[:,2], QSFDecrREV[:,2]])
    # end QSFREEdecr.dat

    ## QSFREEincr.dat
    # start
    name = "QSFREEincr.dat"
    strfn = strpath*name
    ithCol = 3
    QSFIncrREV, QSFIncrPCN, QSFIncrMCA, QSFIncrGMS, QSFIncrARD = ReadDataMat!_2(strfn,100000, ithCol)
    data.QSFIncr = Array{Array{Float64}}([QSFIncrARD[:,2], QSFIncrGMS[:,2], QSFIncrMCA[:,2], QSFIncrPCN[:,2], QSFIncrREV[:,2]])
    # end QSFREEincr.dat


    ## QSSEVmin.dat
    # start
    name = "QSSEVmin.dat"
    strfn = strpath*name
    ithCol = 3
    data.SEVMINGEN = ReadDataCol!(strfn,nMaxRow, ithCol)
    # end QSSEVmin.dat

    ## QSdecr.dat
    # start
    name = "QSdecr.dat"
    strfn = strpath*name
    ithCol = 3
    QSdecrREV, QSdecrPCN, QSdecrMCA, QSdecrGMS, QSdecrARD = ReadDataMat!_2(strfn,100000, ithCol)
    data.QSDecr = Array{Array{Float64}}([QSdecrARD[:,2], QSdecrGMS[:,2], QSdecrMCA[:,2], QSdecrPCN[:,2], QSdecrREV[:,2]])
    # end QSdecr.dat

    ## QSincr.dat
    # start
    name = "QSincr.dat"
    strfn = strpath*name
    ithCol = 3
    QSIncrREV, QSIncrPCN, QSIncrMCA, QSIncrGMS, QSIncrARD = ReadDataMat!_2(strfn,100000, ithCol)
    data.QSIncr = Array{Array{Float64}}([QSIncrARD[:,2], QSIncrGMS[:,2], QSIncrMCA[:,2], QSIncrPCN[:,2], QSIncrREV[:,2]])
    # end QSincr.dat

    ## QSmax.dat
    # start
    name = "QSmax.dat"
    strfn = strpath1*name
    ithCol = 3 
    QSMAXREV, QSMAXPCN, QSMAXMCA, QSMAXGMS, QSMAXARD = ReadDataMat!_2(strfn,100000, ithCol)
    data.QSMAX = Array{Array{Float64}}([QSMAXARD[:,2], QSMAXGMS[:,2], QSMAXMCA[:,2], QSMAXPCN[:,2], QSMAXREV[:,2]])
    # end QSmax.dat

    ## QSmin.dat
    # start
    name = "QSmin.dat"
    strfn = strpath1*name
    ithCol = 3
    QSMINREV, QSMINPCN, QSMINMCA, QSMINGMS, QSMINARD = ReadDataMat!_2(strfn,100000, ithCol)
    data.QSMIN = Array{Array{Float64}}([QSMINARD[:,2], QSMINGMS[:,2], QSMINMCA[:,2], QSMINPCN[:,2], QSMINREV[:,2]])
    # end QSmin.dat


    ## QTWLmax.dat
    # start
    name = "QTWLmax.dat"
    strfn = strpath*name
    ithCol = 3
    maxQREV, maxQPCN, maxQMCA, maxQGMS, maxQARD = ReadDataMat!_2(strfn,100000, ithCol)
    data.QP_MaxO = Array{Array{Float64}}([maxQARD[:,2],maxQGMS[:,2],maxQMCA[:,2],maxQPCN[:,2],maxQREV[:,2]])
    # end QTWLmax.dat


    ## QTdecr.dat
    # start
    name = "QTdecr.dat"
    strfn = strpath*name
    ithCol = 3
    QTDecrREV, QTDecrPCN, QTDecrMCA, QTDecrGMS, QTDecrARD = ReadDataMat!_2(strfn,100000, ithCol)
    data.QTDecr = Array{Array{Float64}}([QTDecrARD[:,2], QTDecrGMS[:,2], QTDecrMCA[:,2], QTDecrPCN[:,2], QTDecrREV[:,2]])
    # end QTdecr.dat

    ## QTincr.dat
    # start 
    name = "QTincr.dat"
    strfn = strpath*name
    ithCol = 3
    QTIncrREV, QTIncrPCN, QTIncrMCA, QTIncrGMS, QTIncrARD = ReadDataMat!_2(strfn,100000, ithCol)
    data.QTIncr = Array{Array{Float64}}([QTIncrARD[:,2], QTIncrGMS[:,2], QTIncrMCA[:,2], QTIncrPCN[:,2], QTIncrREV[:,2]])
    # end QTincr.dat


    ## QTmin.dat
    # start
    nMaxRow = 1e6
    name = "QTmin.dat"
    strfn = strpath*name
    ithCol = 3
    QTMinREV, QTMinPCN, QTMinMCA, QTMinGMS, QTMinARD = ReadDataMat!_2(strfn,100000, ithCol)
    data.QTMin = Array{Array{Float64}}([QTMinARD[:,2], QTMinGMS[:,2], QTMinMCA[:,2], QTMinPCN[:,2], QTMinREV[:,2]])
    # end QTmin.dat
    

    ## ROR.dat
    # start
    name = "ROR.dat"
    strfn = strpath1*name
    ithCol = 4
    data.RORR = ReadDataCol!(strfn,nMaxRow, ithCol)
    # end ROR.dat

    ## ROR_HYSIM.dat
    # start
    name = "ROR_HYSIM.dat"
    strfn = strpath1*name
    ithCol = 4
    data.ROR_HYSIM = ReadDataCol!(strfn,nMaxRow, ithCol)
    # end ROR_HYSIM.dat


    ## RORmin.dat
    # start
    name = "RORmin.dat"
    strfn = strpath*name
    ithCol = 3
    data.ROR_MIN = ReadDataCol!(strfn,nMaxRow, ithCol)
    # end RORmin.dat


    ## SEVGEN.dat
    # start
    name = "SEVGEN.dat"
    strfn = strpath1*name
    ithCol = 2
    data.SEVGEN = ReadDataCol!(strfn,nMaxRow, ithCol)
    # end SEVGEN.dat


    ## SHYDRO.dat
    # start
    name = "SHYDRO.dat"
    strfn = strpath1*name
    ithCol = 4
    data.RES_HYDROR = ReadDataCol!(strfn,nMaxRow, ithCol)
    # end SHYDRO.dat


    ## SH_RES.dat
    # start
    name = "SH_RES.dat"
    strfn = strpath1*name
    ithCol = 4
    data.SH_Reserve = ReadDataCol!(strfn,nMaxRow, ithCol)
    # end SH_RES.dat


    ## THERMAL.dat
    # start
    name = "THERMAL.dat"
    strfn = strpath1*name
    ithCol = 4
    data.BURR = ReadDataCol!(strfn,nMaxRow, ithCol)
    # end THERMAL.dat

    ## Vdecr.dat
    # start
    name = "Vdecr.dat"
    strfn = strpath*name
    ithCol = 6
    data.VDecr = ReadDataMat!(strfn,nMaxRow, ithCol)
    # end Vdecr.dat

    ## Vincr.dat
    # start
    name = "Vincr.dat"
    strfn = strpath*name
    ithCol = 6
    data.VIncr = ReadDataMat!(strfn,nMaxRow, ithCol)
    # end Vincr.dat

    ## WIND0.dat
    # start
    name = "WIND0.dat"
    strfn = strpath1*name
    ithCol = 2
    data.WIND0 = ReadDataCol!(strfn,nMaxRow, ithCol)
    # end WIND0.dat

    ## WINDmin.dat
    # start
    name = "WINDmin.dat"
    strfn = strpath1*name
    ithCol = 3
    data.WIND_MIN = ReadDataCol!(strfn,nMaxRow, ithCol)
    # end WINDmin.dat


    ## Wind.dat
    # start
    name = "Wind.dat"
    strfn = strpath1*name
    ithCol = 4
    data.WINDR = ReadDataCol!(strfn,nMaxRow, ithCol)
    # end Wind.dat


    ## TLKMAXAB.dat
    # start
    name = "TLKMAXAB.dat"
    strfn = strpath*name
    ithCol = 3
    data.TLKMAXAB = ReadDataCol!(strfn,nMaxRow, ithCol)

    name = "TLKMAXAB.dat"
    strfn = strpath*name
    ithCol = 3
    V2, n = ReadDataCol3!(strfn,nMaxRow, ithCol)
    data.AB_tran_maxH = V2[:,2]
    # include("TLKMAXAB.jl")
    # data.AB_tran_maxH = AB_tran_maxH
    # end TLKMAXAB.dat

    ## TLKMAXUS.dat
    # start
    name = "TLKMAXUS.dat"
    strfn = strpath*name
    ithCol = 3
    data.TLKMAXUS = ReadDataCol!(strfn,nMaxRow, ithCol)

    name = "TLKMAXUS.dat"
    strfn = strpath*name
    ithCol = 3
    V2, n = ReadDataCol3!(strfn,nMaxRow, ithCol)
    data.US_tran_maxH = V2[:,2]
    # include("TLKMAXUS.jl")
    # data.US_tran_maxH = US_tran_maxH
    # end TLKMAXUS.dat

    ## TLKMINAB.dat
    # start
    name = "TLKMINAB.dat"
    strfn = strpath*name
    ithCol = 3
    data.TLKMINAB = ReadDataCol!(strfn,nMaxRow, ithCol)

    name = "TLKMINAB.dat"
    strfn = strpath*name
    ithCol = 3
    V2, n = ReadDataCol3!(strfn,nMaxRow, ithCol)
    data.AB_tran_minH = V2[:,2]
    # include("TLKMINAB.jl")
    # data.AB_tran_minH = AB_tran_minH
    # end TLKMINAB.dat

    ## TLKMINUS.dat
    # start
    name = "TLKMINUS.dat"
    strfn = strpath*name
    ithCol = 3
    data.TLKMINUS = ReadDataCol!(strfn,nMaxRow, ithCol)

    nMaxRow = 1e6
    name = "TLKMINUS.dat"
    strfn = strpath*name
    ithCol = 3
    V2, n = ReadDataCol3!(strfn,nMaxRow, ithCol)
    data.US_tran_minH = V2[:,2]
    # include("TLKMINUS.jl")
    # data.US_tran_minH = US_tran_minH
    # end TLKMINUS.dat




    ## ardtw1.dat
    # start
    name = "ardtw1.dat"
    strfn = strpath*name
    ithCol = 4
    ARDQTNPCE = 45
    ARDQINTRCPT = -4.9036696E+04
    ARDFBINTCPT = 424.64
    ARDGINTCPT = 4.25E+02
    V1 = ARDData(strfn,100, ithCol)
    ARDQTMaxBKP = V1[:,1]
    ARDQTMAXSLP = V1[:,2]
    ARDGMAXSLP = V1[:,3]

    ARDGMaxY = [0    0    0    5.23    6.95    8.41    10.09    11.94    13.73    15.66    17.91    20.3    22.58    24.97    27.66    30.48    33.27    36.17    39.26    42.41    45.88    49.38    52.97    56.68    60.52    64.5    68.68    72.85    77.1    81.44    85.95    90.56    95.21    99.99    104.95    110    115.21    120.52    125.75    131.06    136.78    142.59    148.15    153.81    181.81]
    ARDQTMaxY = [0    0    41.57    141.58    174.6    199.66    224.65    249.63    274.56    299.61    324.62    349.64    374.63    399.63    424.65    449.56    474.67    499.64    524.55    549.62    574.59    599.57    624.66    649.6    674.64    699.67    724.69    749.62    774.7    799.62    824.7    849.62    874.62    899.62    924.7    949.62    974.7    999.62    1024.71    1049.62    1074.7    1099.62    1124.62    1149.62    1149.62]
    ARDQTMaxBKP = [420    424.64    425    425.866    426.152    426.369    426.63    426.891    427.084    427.28    427.525    427.764    427.943    428.122    428.33    428.537    428.712    428.886    429.07    429.24    429.436    429.617    429.791    429.964    430.136    430.308    430.486    430.65    430.808    430.965    431.123    431.28    431.43    431.58    431.733    431.885    432.038    432.19    432.328    432.465    432.618    432.77    432.9    433.03    440.131]
    data.ARDQTNPCE = ARDQTNPCE
    data.ARDQINTRCPT = ARDQINTRCPT
    data.ARDFBINTCPT = ARDFBINTCPT
    data.ARDGINTCPT = ARDGINTCPT
    data.ARDQTMaxBKP = ARDQTMaxBKP
    data.ARDQTMaxY = ARDQTMaxY
    data.ARDGMaxY = ARDGMaxY
    # end ardtw1.dat



    Start = param.Start
    End = param.End
    GENNODES = param.GENNODES



    RDTHERMP = 32.5*4*ones(length(plant),End)
    data.RDTHERMP = RDTHERMP

    SEVGENh = zeros(End)
    SEVMINGENh = zeros(End)

    name = "SEVGENh.dat"
    strfn = strpath*name
    ithCol = 3
    data.SEVGENh = ReadDataCol!(strfn,nMaxRow, ithCol)

    name = "SEVMINGENh.dat"
    strfn = strpath*name
    ithCol = 3
    data.SEVMINGENh = ReadDataCol!(strfn,nMaxRow, ithCol)

    ROR_MINh = zeros(length(GENNODES),End)
    data.ROR_MINh = ROR_MINh
    


    name = "SpillCont.dat"
    global nSpill = [0 4 4 2 3]
    global No_Spillways = [[],[0 3 9 4],[0 2 1 2],[0 6],[0 2 2]]
    global sd_npce = [[], [2 5 6 5], [2 5 5 5], [2 5], [2 5 5]]
    global stor_spill = [
        [], 
        [[0 900165], [0 0.0001 139621.059 298068.995 477711.6592], [0 32689.2244 104682.684 231981.14 387380.804 542691.3616], [0 165079.42 218783.8 281734.6 561196.08]], 
        [[0 384672], [0 80746.52375 135558.8355 193573.623 314584.13], [0 229639.3672 239818 258155.5967 304624.93], [0 229639.3672 239818 258155.5967 304624.93]], 
        [[0 4706.65], [0 1577.136936 1817.339812 2256.735318 3015.898]], 
        [[0 87762.2], [0 7209.731024 25016.57167 42730.1528 65034.6672], [0 41195.836 45308.48368 50878.30864 63397.76928]]]
    global spill = [
        [], 
        [[0 0.00001], [0 128.5304 133.2437 136.8561 139.6568], [0 0.00001 36.8119 67.3941 86.9327 96.2773], [0 0.00001 182.7 579.3 3170.3]], 
        [[0 0.00001], [0 0.00001 291.0814 416.3413 552.313], [0 0.00001 74.1913 383.294 1566.9048], [0 0.00001 75.4755 384.958 1524.6837]], 
        [[0 0.00001], [0 0.00001 109.8614843 598.3349221 1917.464244]], 
        [[0 0.00001], [0 0.00001 607.6216146 938.536052 1161.559607], [0 0.00001 174.9685887 658.1443516 2363.511757]]]
			
                                                        					
                                                        				
    name = "ORO.dat"
    strfn = strpath*name
    ithCol = 3
    # data.G_ORO = ReadDataCol!(strfn,nMaxRow, ithCol)
    G_OROREV, G_OROPCN, G_OROMCA, G_OROGMS, G_OROARD = ReadDataMat!_2(strfn,nMaxRow, ithCol)
    G_ORO = Array{Array{Float64}}([G_OROARD[:,2],G_OROGMS[:,2],G_OROMCA[:,2],G_OROPCN[:,2],G_OROREV[:,2]])
    data.G_ORO = G_ORO                                            
                 
    
    name = "SH_RES_noR.dat"
    strfn = strpath1*name
    ithCol = 3
    global SH_Reserve_noR = ReadDataCol!(strfn,nMaxRow, ithCol)  






end

# ReadSysData(param, data, strpath)

