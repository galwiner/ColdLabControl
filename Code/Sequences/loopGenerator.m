function output=loopGenerator(varargin)
    persistent loopCombinations 

    if level>=1
        for ind=1:maxRange
            loopCombinations{end+1}=[ind,level]
            loopGenerator(maxRange,level-1);
        end
    end
    
    
     output=loopCombinations;
end
