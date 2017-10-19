classdef expRunner
    %class to represent the experiment
    
    properties
        ICEbox
        pixelfly
    end
    
    methods
        function obj=expRunner()
            imaqreset
            ICEbox=ICE('com4');
%             cam1=pixelfly();
        end
        
        
        
    end
    
end


