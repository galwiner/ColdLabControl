classdef Block < matlab.mixin.CustomDisplay &handle
    %parent class for a block
    
    properties
        b
        atomic={'pause','setDigitalChannel','setAnalogChannel'}
        compound={'Load MOT','Release MOT','ToF','Take Picture'}
    end
    
    methods
        function obj=Block(inputSeq)
            if nargin==0
                obj.b={};
                
            else
                
                if iscell(inputSeq)
                    if size(inputSeq,1)~=1
                        inputSeq=inputSeq';
                    end
                    
                    obj.b{end+1}=inputSeq;
                    
                    %                     obj.b=inputSeq;
                    
                else
                    obj.b{end+1}={inputSeq};
                end
            end
            %             for ii=1:length(obj.b)
            %                 obj.isAtomic(obj.b(ii))
            %             end
        end
        
        function bool=isAtomic(obj,action)
            if strcmpi('cell',class(action))
                if size(action,1)==1
                    if any(strcmpi(action{1},obj.atomic))
                        bool=1;
                    else
                        bool=0;
                    end
                else
                    for ii=1:size(action,2)
                        bool(ii)= obj.isAtomic(action{ii});
                    end
                    bool=all(bool);
                end
            elseif strcmpi('char',class(action))
                if any(strcmpi(action,obj.atomic))
                    bool=1;
                else
                    bool=0;
                end
            end
            
            
        end
        
        function addAction(obj,action,pos)
            if nargin==2
                if isempty(obj.b)
                    obj.b={action};
                else
                    obj.b{end+1,:}=action;
                end
            else
                obj.b={obj.b{1:pos-1};action;obj.b{pos+1:end}};
            end
        end
        function atomizeAll(obj,seq)
            if nargin==1
                seq=obj.b;
            end
            if strcmpi('Block',class(seq))
                seq=seq.b{1};
            end
            %             seq=seq{:};
            newseq={};
            for ii=1:size(seq,1)
                temp=obj.atomizer(seq{ii});
                if isempty(newseq)
                    newseq=temp;
                else
                    newseq={newseq{:},temp{:}}';
                end
            end
            obj.b=newseq;
            if ~any(obj.isAtomic(newseq))
                
                
                obj.atomizeAll(newseq);
            end
        end
        
        function atomizedAction=atomizer(obj,action)
            global p;
            
            if obj.isAtomic(action)
                atomizedAction={action};
            else
                switch action{1}
                    case 'Load MOT'
                        atomizedAction={
                            {'setDigitalChannel','channel','IGBT','duration',0,'value','high'};...
                            {'setAnalogChannel','channel','CIRCAHH','duration',0,'value',p.circCurrent};...
                            {'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'};...
                            {'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'}
                            };
                    case 'Release MOT'
                        atomizedAction={
                            {'setDigitalChannel','channel','IGBT','duration',0,'value','low'};...
                            {'setAnalogChannel','channel','CIRCAHH','duration',0,'value',0};...
                            {'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low'};...
                            {'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'}
                            };
                    case 'ToF'
                        atomizedAction={
                            {'Load MOT'};...
                            };
                    otherwise
                        error('No such action found: %s',action{1});
                end
                %                 atomizedAction=Block(atomizedAction);
            end
        end
    end
    methods (Access = protected)
        function displayScalarObject(obj)
            if isempty(obj.b)
                fprintf('empty block\n');
            else
                fprintf('Block:\n')
                fprintf('______\n');
                block=obj.b;
                for ii =1:size(block,1)
                    fprintf('%d:%-10s\t\t',ii,block{ii}{1});
                    if size(block{ii},2)>1
                        for jj=2:2:size(block{ii},2)
                            fprintf("%s:%s|",block{ii}{jj},num2str(block{ii}{jj+1}));
                        end
                        
                    end
                    fprintf('\n');
                    %
                end
            end
        end
    end
end



