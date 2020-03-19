classdef MOTBlock < Block
    % a mot loading block
    
    properties
    end
    
    methods
        function obj=MOTBlock()
            global p;
            obj.b={{'MOT Load'},{'IGBT ON'},...
                {'SET CIRC AHH','current',p.circCurrent},...
                {'COOLING ON'},...
                {'REPUMP ON'},...
                {'MOT Load Pause'}
                };
        end
        
    end
    
end

