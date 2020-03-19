function mat=calculateG2Mat(pulses,binNum)
    mat=makeAverageBiVar(pulses,binNum)./makeAverageDetMatrix(pulses,binNum)
end
