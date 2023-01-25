function setTTCalc(data::DATA, strpath::String)
    name = "setTT.dat"
    strfn0 = strpath*name
    # strfn0 = "C:\\Users\\sabdolna\\Documents\\GOM-JULIA\\1973-new\\Inputs\\setTT.dat"
    io=open(strfn0)
    val=readdlm(io;comments=true)       #skipstart=1
    close(io)
    k = 1
    nrow = size(val)[1]
    ncol = size(val)[2]
    TT = zeros(nrow,ncol)
    for i = 1:nrow
        k=1
        for j = 3:ncol-1
            if val[i,j] != ":="
            TT[i,k] = val[i,j]
            k=k+1
            end
        end
    end
    data.TT = TT[:,1:24]
end

