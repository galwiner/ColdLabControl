function mat=makeAverageBiVar(pulses,binNum)
    pulseNum=length(pulses{1});
    mat=zeros(binNum,binNum);
        for jnd=1:pulseNum
            currMat=histcounts([pulses{1}{jnd}],binNum)'*histcounts([pulses{2}{jnd}],binNum);
            mat=mat+currMat;
        end
        
end
