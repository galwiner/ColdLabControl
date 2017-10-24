classdef ICE <handle
    %this class represent the ICE laser control system
   
    
    properties
        comport
        s %serial communication variable
        lasers={};

    end
    
    methods
        function obj=ICE(comport)
         obj.s=serial(comport,'BaudRate',115200,'StopBits',1,'Parity','none','timeout',0.5,'Terminator','LF');
         fopen(obj.s);

        end
        
        function addLaser(obj,slot,coolingChan)
            obj.lasers{end+1}=ICELaser(obj.s,slot,coolingChan);
        end
        
        
    end
    
end
