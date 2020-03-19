classdef Experiment
    %The experiment class collects all the required properties for an
    %experiment. It then updates p with this proferties.
    properties
        ExpDescription;
        loopVars;
        loopVals;
        hasPicturesResults;
        picsPerStep;
    end
    
    methods
        function obj= Experiment(ExpName,loopVars,loopVals,hasPicturesResults,picsPerStep)
            global p;
            if nargin==0
                error('An experiment must have a description!\n');
            end
            if nargin==1
                error('An experiment must have loopVars!\n');
            end
            if nargin==2
                error('An experiment must have loopVals!\n');
            end
            if nargin==3
                error('You must spesify if the experiment has a picture result!\n');
            end
            if nargin==4
                error('You must spesify the number of pictures per step!\n');
            end
%             if ~ischar(ExpDescription)
%                 ExpDescription='ExpDescription';
%             end
%             
            load([ExpName '.m'],'p');
            
%             if ~iscell(loopVars)
%                 loopVars={loopVars};
%             end
% 
%             if ~iscell(loopVals)
%                 loopVals={loopVals};
%             end
%             
%             if hasPicturesResults ~=1 || hasPicturesResults ~=0
%                 error('hasPicturesResults must be 1 or 0!\n');
%             end
%             
%             if strcmpi(class(picsPerStep),'double')
%                 ExpDescription='ExpDescription';
%             end
%             obj.ExpDescription = ExpDescription;
%             p.ExpDescription = ExpDescription;
%             
%             obj.loopVars = loopVars;
%             p.loopVars = loopVars;
%             
%             obj.loopVals = loopVals;
            
            
%             obj.hasPicturesResults = hasPicturesResults;
%             obj.picsPerStep = picsPerStep;
        end
        
    end
    
end

