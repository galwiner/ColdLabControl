classdef dblLinkedList
    %doubly linked list data structure (nodes point back and forward)
    
    properties
        nodes
    end
    
    methods
        function obj=linkedList(obj)
            nodes={};
            nodes{end+1}=struct();
        end
        
        function addNode(obj,pos)
            if nargin==1
                pos=length(obj.nodes);
            end
            keySet={'back','forward','data'};
            
            obj.nodes{pos+1}=containers.Map();
        end
        
        function remNode(obj,pos)
        
        end
        
    end
    
end

