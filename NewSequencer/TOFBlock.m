classdef TOFBlock < Block
    %time of flight
    
    properties
    end
    
    methods
        function obj=TOFBlock()
            
            global p
            times=p.TOFtimes;
            if isscalar(times)
                obj.b={{'ToF'},{'MOT Load'},{'MOT release'},{'ToF Delay','duration',times},{'Take picture'}};
            else
                obj.b={{'ToF'}};
                for ind=1:length(times)
                    
                    obj.b=[obj.b,{{'MOT Load'},{'MOT release'},{'ToF Delay','duration',times(ind)},{'Take Picture'}}];
                end
            end
            
        end
    end
    
end


