classdef NIOPS <handle
    %NIOPS3 LD & GW 3.1.18
    %   NIOPS3 pressure gauge class
    
    properties
        s
    end
    
    methods
        function obj = NIOPS(comPortStr)
            %NIOPS Construct an instance of this class
            %   Detailed explanation goes here
            if nargin==0
                comPortStr='COM3';
            end
            obj.s = serial(comPortStr,'BaudRate',9600,'DataBits',8,'StopBits',1,'Terminator','CR');
            fopen(obj.s);
        end
        
        function pressure = getPressure(obj)
            %This assumes the gauge address is 001. if not, change the
            %second and third bits to the ascii representation, i.e for 005
            %type 48,48,53.(Or change the gauge address)
            pressChar = query(obj.s,char(48,48,49,48,48,55,52,48,48,50,61,63,49,48,54,13)); %REturnes pressure in hpa.
            mantisa = str2double([pressChar(11) '.' pressChar(12:14)]); %get the non exponent part.
            exponent = str2double(pressChar(15:16))-20; %get the order of magnitude.
            pressure = mantisa*10^exponent*0.75; % combine and convert to Torr.
            
        end
        
        
        function delete(obj)
           fclose(obj.s); 
        end
    end
end

