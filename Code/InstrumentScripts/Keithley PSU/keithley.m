classdef keithley
    %KEITHLEY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        conn
    end
    
    methods
        function obj = keithley(comPort)
            %KEITHLEY supply
            obj.conn = serial(comPort);
            fopen(obj.conn);
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

