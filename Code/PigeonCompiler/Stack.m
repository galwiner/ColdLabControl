classdef Stack  < handle
    properties
        stackarray=zeros(100,1);
        stackpointer=1; 
    end
    methods
        function s = Stack
        end
        
        function Push(obj,element)
            obj.stackarray(obj.stackpointer)=element;
            obj.stackpointer=obj.stackpointer+1;
        end

        function element=Pop(obj)
            if ~obj.IsEmpty
                obj.stackpointer=obj.stackpointer-1;
                element=obj.stackarray(obj.stackpointer);              
            else
                error('can not pop,stack is empty');
            end
        end
        
        function r=IsEmpty(obj)
            r=(obj.stackpointer==1);
        end
    end % methods 
end% class
