classdef Action
    %representing a single action in a block
    
    properties
        name
        body
        hasINNNER
        hasOUTER
    end
    
    methods
        function obj = Action(body,name)
            if nargin==2
                obj.name=name;
                obj.body=body;
            end
            
            if nargin==1    
                obj.name = '';
                obj.body=body;
            end
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

