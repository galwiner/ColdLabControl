classdef TitanGauge <handle
    %ion pump gauge and controller
    
    properties
        s
    end
    
    methods
        function obj = TitanGauge(portString)
            if nargin==0
                portString='COM13';
            end
            
            CR=char(13);
            
            obj.s=serial(portString,'BaudRate',9600,'DataBits',8,'StopBits',1,'Parity','None','terminator',CR);
            
            fopen(obj.s);
            
        end
        
        function pressure = getPressure(obj)
            command=['~ 05 0B 00',char(13)]; % get pressure      
            fprintf(obj.s,'%s',command);
            resp=fscanf(obj.s,'%s');
            pressure=str2double(resp(7:13));
        end
        
        function delete(obj)
           fclose(obj.s); 
        end
    end
end

