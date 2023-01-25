function ReadDataCol!(strfn::String,nMaxRow, ithCol::Int=2)
    #JL202109. 
    #ithCol: the colum index to read
    # return number of row read
    
    io=open(strfn)
    val=readdlm(io;comments=true)       #skipstart=1
    close(io)

    nrow=size(val,1)
    noffset=0
    if val[1,1]=="param" noffset+=1 end
    if val[2,1]==":" noffset+=1 end
    nrow-=noffset

    if nrow>nMaxRow nrow=nMaxRow    end

    V1 = zeros(nrow)
    for i=1:nrow-1
        V1[i]=val[i+noffset,ithCol]
    end
    return V1;
end

function ReadDataCol3!(strfn::String,nMaxRow, ithCol::Int=2)
    #JL202109. 
    #ithCol: the colum index to read
    # return number of row read
    
    io=open(strfn)
    val=readdlm(io;comments=true)       #skipstart=1
    close(io)

    nrow=size(val,1)
    noffset=0
    if val[1,1]=="param" noffset+=1 end
    if val[2,1]==":" noffset+=1 end
    nrow-=noffset

    if nrow>nMaxRow nrow=nMaxRow    end

    V1 = zeros(nrow)
    for i=1:nrow-1
        V1[i]=val[i+noffset,1]
    end
    V3 = zeros(nrow)
    for i=1:nrow-1
        V3[i]=val[i+noffset,3]
    end
    m=Any[]
    for i=1:nrow-1
        push!(m,val[i+noffset,2]) 
    end
    V2 = zeros(nrow,2)
    n=Any[]
    for k = 1:End
        element = findall(isequal(k), V1)
        V2[k,1] = V1[element][1]
        V2[k,2] = V3[element][1]
        push!(n,m[element][1]) 
    end
    return V2, n;
end

function ReadDataCol4!(strfn::String,nMaxRow, ithCol::Int=2)
    #JL202109. 
    #ithCol: the colum index to read
    # return number of row read
    
    io=open(strfn)
    val=readdlm(io;comments=true)       #skipstart=1
    close(io)

    nrow=size(val,1)
    noffset=0
    if val[1,1]=="param" noffset+=1 end
    if val[2,1]==":" noffset+=1 end
    nrow-=noffset

    if nrow>nMaxRow nrow=nMaxRow    end

    V1 = zeros(nrow)
    for i=1:nrow-1
        V1[i]=val[i+noffset,2]
    end
    V3 = zeros(nrow)
    for i=1:nrow-1
        V3[i]=val[i+noffset,4]
    end
    V2 = zeros(nrow,2)
    for k = 1:End
        element = findall(isequal(k), V1)
        V2[k,1] = V1[element][1]
        V2[k,2] = V3[element][1]
    end
    return V2;
end

function ReadDataMat!(strfn::String,nMaxRow, ithCol::Int=2)
    #JL202109. 
    #ithCol: the colum index to read
    # return number of row read
    
    io=open(strfn)
    val=readdlm(io;comments=true)       #skipstart=1
    close(io)

    nrow=size(val,1)
    noffset=0
    if val[1,1]=="param" noffset+=1 end
    if val[2,1]==":" noffset+=1 end
    nrow-=noffset

    if nrow>nMaxRow nrow=nMaxRow    end

    V1 = zeros(nrow,ithCol-1)
    for j = 1:ithCol-1
        for i=1:nrow-1
            V1[i,j]=val[i+noffset,j+1]
        end
    end
    return V1;
end

function ReadDataMat!_2(strfn::String,nMaxRow, ithCol::Int=2)
    #JL202109. 
    #ithCol: the colum index to read
    # return number of row read
    
    io=open(strfn)
    val=readdlm(io;comments=true)       #skipstart=1
    close(io)

    nrow=size(val,1)
    noffset=0
    if val[1,1]=="param" noffset+=1 end
    if val[2,1]==":" noffset+=1 end
    nrow-=noffset

    if nrow>nMaxRow nrow=nMaxRow    end

    dataplant = Any[]
    for row = ARD:REV
        plnt = plant[row]
        kard = 0
        for i=1:nrow+1
            if val[i,1] == plnt
                kard += 1
            end
        end
        dataplnt = zeros(kard,ithCol-1)
        kard = 0
        for i=1:nrow+1
            if val[i,1] == plnt
                kard += 1
                dataplnt[kard,:] = val[i,2:ithCol]
            end
        end
        dataplant = push!(dataplant, dataplnt)
    end

    dataREV = dataplant[REV]
    dataPCN = dataplant[PCN] 
    dataMCA = dataplant[MCA] 
    dataGMS = dataplant[GMS] 
    dataARD = dataplant[ARD] 

    return dataREV, dataPCN, dataMCA, dataGMS, dataARD;
end

function ARDData(strfn::String,nMaxRow, ithCol::Int=2)
    io=open(strfn)
    val=readdlm(io;comments=true)       #skipstart=1
    close(io)
    nrow=size(val,1)
    noffset=0
    if val[1,1]=="param" noffset+=1 end
    if val[2,1]==":" noffset+=1 end
    nrow-=noffset
    if nrow>nMaxRow nrow=nMaxRow    end
    V1 = zeros(41,ithCol-1)
    for j = 1:ithCol-1
        k=0
        for i=6:46
            k=k+1
            V1[k,j]=val[i,j+1]
        end
    end
    return V1
end