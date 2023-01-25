N_GENNODES = 1
# V_pre = data.V_pre
# P_LRBdQT = data.P_LRBdQT
PERIODS = data.MONTHS
StartPeriod = data.StartMonth
EndPeriod = data.EndMonth
FBMAX = data.FBMAX
combo_num = data.combo_num
maxg = data.maxg
maxq = data.maxq 
FB = data.FB
WINDR = data.WINDR
G_ORO = data.G_ORO
QSR = data.QSR
UQS = data.UQS
QTR = data.QTR
UQT = data.UQT
dQTMaxmCoeff = data.dQTMaxmCoeff
dQTMaxcCoeff = data.dQTMaxcCoeff

USExchRate = 1.0
RORR = data.RORR
price_Imp_USH = data.price_Imp_USH
price_Exp_USH = data.price_Exp_USH
price_Imp_ABH = data.price_Imp_ABH
price_Exp_ABH = data.price_Exp_ABH

dQTmCoeff = data.dQTmCoeff
dQTcCoeff = data.dQTcCoeff
dQTPCoeff = data.dQTPCoeff
# Define decision variables

AB_tran_maxH = data.AB_tran_maxH
AB_tran_minH = data.AB_tran_minH
US_tran_maxH = data.US_tran_maxH
US_tran_minH = data.US_tran_minH

ROR_HYSIM = data.ROR_HYSIM
RES_HYDROR = data.RES_HYDROR
#@JuMP.variable(model, WIND_HYSIM[r = 1:length(GENNODES), t = Start:End] == 0) 
BURR = data.BURR
IPPR = data.IPPR
NTS = data.NTS
QP_Max = data.QP_Max
QP_Min = data.QP_Min
ARDFLOW = (QP_Max[:,ARD]+ QP_Min[:,ARD])/2
HKARD = data.HKARD
LOADHR = data.LOADHR[:,2]

hours = ones(End)

QIR = data.QIR
UQT = data.UQT
QTR = data.QTR
UQS = data.UQS
QSR = data.QSR


# V00 = data.V00

PERIODS = data.MONTHS
IPPEnergyBgt_Max = data.IPPEnergyBgt_Max
IPPEnergyBgt_Min = data.IPPEnergyBgt_Min
StartMonth = data.StartMonth
EndMonth = data.EndMonth

IPP_Max = data.IPP_Max
IPP_Min = data.IPP_Min

HKGH = data.HKGH
ARDnum = 1
QTMax = data.QTMax
QP_Min = data.QP_Min

QTIncr = data.QTIncr
QTDecr = data.QTDecr
QSFIncr = data.QSFIncr
QSFDecr = data.QSFDecr
QP_Max = data.QP_Max
QP_Min = data.QP_Min

QSMAX = data.QSMAX
QSMIN = data.QSMIN

P_Min = data.P_Min
QT_Max = data.QT_Max
QTMin = data.QTMin


OPT_Res = 0.03
PIncr = data.PIncr
PDecr = data.PDecr
ROR_MINh = data.ROR_MINh
RORR = data.RORR
WIND_MINh = zeros(length(GENNODES),T)
WINDR = data.WINDR
VMin = data.VMin
VMax = data.VMax
QT_Max = data.QT_Max

UQT = data.UQT
UQS = data.UQS
QSR = data.QSR
QTR = data.QTR
UQT = data.UQT

dP_MaxmCoeff = data.dP_MaxmCoeff
dP_MaxcCoeff = data.dP_MaxcCoeff
# P_Max1 = data.P_Max1 
# P_Max2 = data.P_Max2 
# P_Max = Any[]
# for j=1:N_Plant
#     push!(P_Max, min(P_Max1[j,:],P_Max2[j,:]))
# end
P_Max2 = data.P_Max2

Qbkp = data.Qbkp
Gbkp = data.Gbkp
slope = data.slope
combo_num = data.combo_num
npce = data.nnpce
Gbkp_mi = data.Gbkp_mi
Gbkp_ci = data.Gbkp_ci 
Qbkp_mi = data.Qbkp_mi
Qbkp_ci = data.Qbkp_ci 

QSMAX = data.QSMAX
QSMIN = data.QSMIN

QS_MaxARD = data.QS_MaxARD


VMin = data.VMin
VMax = data.VMax

fcc = data.fcc

QP_Max = data.QP_Max
QP_Min = data.QP_Min

for t=initial:T
    US_tran_minH[t] = US_tran_minH[t] - max(0,NTS[t])
    US_tran_maxH[t] = US_tran_maxH[t] + min(0,NTS[t])
end


QP_MaxO = data.QP_MaxO
QTMax = data.QTMax


# for j = 1: N_Plant
#     VMax[j,End] = V_End_Max[j] # V_End[j]
#     VMin[j,End] = V_End_Min[j]
#     data.V_SIM[j,End] = V_End_SIM[j]
# end

