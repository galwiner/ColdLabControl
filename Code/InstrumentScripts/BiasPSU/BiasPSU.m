classdef BiasPSU < handle
    %BIASPSU keysight psu driving the mot bias coils
   
    
   properties
        conn
        resourcename
        easyname %human readble name
    end
    
    methods
        function obj = BiasPSU(resourcename,easyname)
            %KEYSIGHTSCOPE Construct an instance of this class
            if nargin==1
                obj.easyname=resourcename;
            else 
                obj.easyname=easyname;
            end
            
            obj.resourcename=resourcename;
            obj.conn = visa('agilent',obj.resourcename);
            fopen(obj.conn);
            fprintf(obj.conn, sprintf(':SOURce1:FUNCtion:MODE %s', 'CURRent'));
            fprintf(obj.conn, sprintf(':SOURce2:FUNCtion:MODE %s', 'CURRent'));
            fprintf(obj.conn, sprintf(':SENSe%d:VOLTage:DC:PROTection:LEVel:BOTH %g', 1,20));
            fprintf(obj.conn, sprintf(':SENSe%d:VOLTage:DC:PROTection:LEVel:BOTH %g', 2,20));
        end
        
        function setCurrent(obj,chan,current)
            fprintf(obj.conn, sprintf(':SOURce%d:FUNCtion:MODE %s',chan,'CURRent'));
            fprintf(obj.conn, sprintf(':SOURce%d:CURRent:LEVel:IMMediate:AMPLitude %g',chan,current));            
        end
        
        function setOutput(obj,chan,mode)
            if ~mode==1 && ~mode==0
                error('mode should only be 1 or 0');
            end
            fprintf(obj.conn, sprintf(':OUTPut%d:STATe %d',chan,mode));
        end
        
        function setVoltageLimit(obj,chan,limit)
            fprintf(obj.conn, sprintf(':SENSe%d:VOLTage:DC:PROTection:LEVel:BOTH %g', chan,limit));
        end
        
        
        function delete(obj)
            fclose(obj.conn);
            fprintf('connection closed %s \n',obj.resourcename);
        end
            
        
        
    end
end

