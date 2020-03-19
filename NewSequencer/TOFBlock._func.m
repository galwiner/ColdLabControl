function b=TOFBlock()
global p
times=p.TOFtimes;
if isscalar(times)
    b={{'ToF'},{'MOT Load'},{'MOT release'},{'ToF Delay','duration',times},{'Take picture'}};
else
    b={'ToF'};
    for ind=1:length(times)
        b{end+1}={{'MOT Load'},{'MOT release'},{'ToF Delay','duration',times(ind)},{'Take Picture'}};
    end
end

end