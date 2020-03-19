classdef KeithleyPSU <handle
    %
    
    properties
        s
    end
    
    methods
        function obj = KeithleyPSU(comPort)
            obj.s=serial(comPort);
            
            fopen(obj.s);
            fprintf('opened connection to Keithley PSU on %s\n',obj.s.Port); 
            fprintf(obj.s,"SYSTem:REMote"); %SUPER IMPORTANT TOOK ME AGES TO FIND THIS IS A CRUCIAL STEP
        end
        
        function selectChannel(obj,chan)
            fprintf(obj.s,sprintf('INSTrument:SELect CH%d',chan));
        end
        
        function setOutput(obj,state)
            if state==1
                state='ON';
            end
            if state==0
                state='off';
            end
%             [SOURce:]OUTPut[:STATe][:ALL] {0|1|ON|OFF}
%             query(obj.s,"*IDN?")
            fprintf(obj.s,sprintf("OUTPut %s",state));
        end
        
        function setVoltage(obj,chan,volt)
%             if abs(obj.getVoltage(chan)-volt)<1e-3
%                 fprintf('KeithleyPSU set Voltage: Voltage not updated\n')
%                 return
%             end
            obj.selectChannel(chan);
            fprintf(obj.s,sprintf("source:volt:lev %f",volt));
%             pause(1.5)
%             fprintf('KeithleyPSU set Voltage: pausing for 1.5 seconds to let voltage settle\n')
        end
        function V = getVoltage(obj,chan)
            obj.selectChannel(chan);
            V = (query(obj.s,"source:volt:lev?"));
            V(end) = [];
            V = str2double(V);
        end
        
        function delete(obj)
            fclose(obj.s);
            fprintf('closed connection to Keithley PSU on %s\n',obj.s.Port); 
        end
        
    end
end

