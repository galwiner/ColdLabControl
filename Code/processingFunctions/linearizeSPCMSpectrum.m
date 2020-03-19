function lincountPerCycle = linearizeSPCMSpectrum(countPerCycle,cycleTime)
%this function linearizes a spectrum, based on the function "spcmLinearize"
countRate = countPerCycle/cycleTime;
lincountPerCycle = spcmLinearize(countRate);
end