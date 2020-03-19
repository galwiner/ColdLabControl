classdef sqncr < handle & matlab.mixin.CustomDisplay
    %sequence generator
    
    properties
        seq
    end
    
    
    
    
    methods (Access = protected)
        function displayScalarObject(obj)
            fprintf('Sequence:\n')
            fprintf('_________\n');
            if isempty(obj.seq)
                fprintf('Empty sequence\n');
            else
                for ind=1:length(obj.seq)
                    fprintf('Block %d: %s\n',ind,obj.seq{ind}.name) %TODO: add a block getName func
                end
            end
        end
    end
    
    methods
        function obj=sqncr(block)
            global p
            if nargin==1
                obj.addBlock(block,1);
            else
                obj.seq={};
            end
            
        end
        
        function addBlock(obj,block,pos)
            
            if nargin==2
                pos=size(obj.seq,1)+1;
            end
            %
            if ~strcmpi(class(block),'Block')
                block=Block(block);
            end
            
            if isempty(obj.seq)
                obj.seq{end+1}=block;
            else
                if pos>(size(obj.seq,1)+1)
                    error('pos longer than seq');
                end
                obj.seq={obj.seq{1:pos-1},block,obj.seq{pos:end}}';
            end
        end
        
        function remBlock(obj,pos)
            
            if isempty(obj.seq)
                error('cannot remove from empty list');
            else
                if pos>length(obj.seq)
                    error('pos longer than seq');
                end
                obj.seq={obj.seq{1:pos-1},obj.seq{pos+1:end}}';
            end
        end
        
        function [syncSeq,asyncSeq]=atomizeAndMerge(obj)
            if isempty(obj.seq)
                error('sequence is empty, cannot perform action');
            end
            for ii=1:size(obj.seq,1)
                
                if ii==1
                    obj.seq{ii}.atomizeAll;
                    fullseq = obj.seq{ii}.b;
                else
                    obj.seq{ii}.atomizeAll;
                    fullseq=[fullseq;obj.seq{ii}.b];
                end
                
                
            end
            %             syncSeq=fullseq
            %now move all asynchronous actions to the top of the sequence
            %             fullseq=Block(fullseq);
            [syncSeq,asyncSeq]=obj.sortAsync(fullseq);
            
        end
        
        function [syncSeq,asyncSeq]=sortAsync(obj,seq)
            %put all async actions in the top of the sequence
            tBlock=Block(); %empty block so we can use isAsync func
            if size(seq,1)==1 && tBlock.isAsync(seq)
                asyncSeq=seq;
                syncSeq={};
                return
            elseif size(seq,1)==1 && ~tBlock.isAsync(seq)
                syncSeq=seq;
                asyncSeq={};
                return
            end
            
            [~,listBool]=tBlock.isAsync(seq);
            
            asyncIdx=find(listBool);
            syncIdx=find(~listBool);
            %
            
            %             sortedSeq=[asyncSeq';seq];
            
            syncSeq=seq(syncIdx);
            asyncSeq=seq(asyncIdx);
            
        end
        
        function stepRes=runStep(obj,innerLoopVal,outerLoopVal)
            global p
            if nargin==1
                innerLoopVal=NaN;
                outerLoopVal=NaN;
            end
            if nargin==2
                outerLoopVal=NaN;
            end
            
            [syncSeq,asyncSeq]=obj.atomizeAndMerge; %generate full sequqence
            fullseq=[asyncSeq;syncSeq];
            populatedSeq=obj.populateVars(fullseq,innerLoopVal,outerLoopVal); %populate value
%             Block(populatedSeq)
            stepRes=obj.execute(populatedSeq); % and collect results
%             k=keys(p.loopVars);
            if isnan(innerLoopVal) && isnan(outerLoopVal)
                fprintf('completed step with no values\n');
            elseif isnan(outerLoopVal)
                fprintf('Completed step %s = %.2f\n',p.loopVars{1},innerLoopVal);
            elseif isnan(innerLoopVal)
                error('Cannot have outer loop with no inner loop');
            elseif ~isnan(outerLoopVal) && ~isnan(innerLoopVal)
                fprintf('Completed step %s = %.2f, %s = %.2f\n',p.loopVars{1},innerLoopVal,p.loopVars{2},outerLoopVal);
            else
                error('error in sqncr function runStep\n');
            end
            
            
        end
        
        function populatedSeq=populateVars(obj,fullSeq,innerLoopVal,outerLoopVal)
            global p
            found=[0,0];
            for ii=1:size(fullSeq,1)
                innerloopInd = find(strcmp(cellfun(@(x) num2str(x),fullSeq{ii},'UniformOutput',false),num2str(p.INNERLOOPVAR)));
                
                if ~isempty(innerloopInd)
                    if isnan(innerLoopVal)
                        error('No inner loop parameter passed but INNERLOOPVAR placeholder exists in sequence');
                    end
                    if length(innerloopInd)>1
                        error('There can be only one InnerLoopVar per line!')
                    end
                    found(1)=1;
                    fullSeq{ii}{innerloopInd}=innerLoopVal;
%                     k=keys(p.loopVars);
%   This next part was removed in 21.1.18 because we now change only the valeus in the sequence, not p.varname                    
%                     if isfield(p,p.loopVars{1})
%                         p.(p.loopVars{1})=innerLoopVal;
%                     else
%                         error('No such variable in p: %s',p.loopVars{1})
%                     end
                end
                %                     fullSeq{ii}
                      
            outerloopInd = find(strcmp(cellfun(@(x) num2str(x),fullSeq{ii},'UniformOutput',false),num2str(p.OUTERLOOPVAR)));
            if ~isempty(outerloopInd)
                if isnan(outerLoopVal)
                    error('No outer loop parameter passed but OUTERLOOPVAR placeholder exists in sequence');
                end
                if length(outerloopInd)>1
                    error('There can be only one OuterLoopVar per line!')
                end
                found(2)=1;
                fullSeq{ii}{outerloopInd}=outerLoopVal;
%                 k=keys(p.loopVars);
%   This next part was removed in 21.1.18 because we now change only the valeus in the sequence, not p.varname                    
%                 if isfield(p,p.loopVars{2})
%                     p.(p.loopVars{2})=outerLoopVal;
%                 else
%                     error('No such variable in p: %s',p.loopVars{2})
%                 end
            end
            end
            
            if (found(1)==0 && ~isnan(innerLoopVal)) 
                error('Inner loop values passed but no placeholder value found!. check sequence');
            elseif (found(2)==0 && ~isnan(outerLoopVal)) 
                error('Outer loop values passed but no placeholder value found!. check sequence');
            end
            
            populatedSeq=fullSeq;
            
            
        end
        function asyncRes=executeAsync(obj,seq)
            global inst
            global p
            
            %prepare scope (set to single shot)
            if p.hasScopResults==1
                inst.scopes{1}.setState('single');
            end
            
            tBlock=Block();
            if isempty(seq)
                asyncRes=NaN;
                return
            end
            if ~all(tBlock.isAsync(seq))
                error('Error! can''t asyncronously execute syncronous action(s)');
            end
            %             {'setDDSfreq','setHH','setICEfreq','getWLMdata'}
            for ii=1:size(seq,1)
                switch seq{ii}{1}
                    case 'setDDSfreq'
                        disp('setDDSfreq')
                        asyncRes=1;
                    case 'setICEDetuning'
                        laserNameInd=find(strcmpi('Laser Name',seq{ii}));
                        if isempty(laserNameInd)
                            error('Laser name missing in setICEDetuning');
                        end
                        laserName = seq{ii}{laserNameInd+1};
                        detInd=find(strcmpi('Detuning',seq{ii}));
                        if isempty(detInd)
                            error('Detuning missing in setICEDetuning');
                        end
                        Detuning = seq{ii}{detInd+1}; %in MHz
                        N=inst.Lasers(lower(laserName)).getMultiplyer;
                        if strcmpi(inst.Lasers(lower(laserName)).getIntRefStatus,'on') %check if locking to internal vco.                          
                            if strcmpi(laserName,'cooling')
                                freq = coolingDetToFreq(Detuning,N);
                                inst.Lasers(lower(laserName)).setIntFreq(freq);
                                inst.Lasers(lower(laserName)).setEventData(freq,1,1); %cooling uses mode 1, i.e invert off and int vco on
                            elseif strcmpi(laserName,'repump')
                                freq = repumpDetToFreq(Detuning,N);
                                inst.Lasers(lower(laserName)).setIntFreq(freq);
                                inst.Lasers(lower(laserName)).setEventData(freq,1,15); %cooling uses mode 15, i.e invert on and int vco on
                            else
                                error('Only cooling and repump are implemented. If using a deferent laser, implement it.\n')
                            end
                        else
                            error('Exturnal reference jump is not implemented yet')
                        end
                        asyncRes=1;
                    case 'getWLMdata'
                        disp('getWLMdata')
                        asyncRes=1;
                    case 'updateCams'
                        asyncRes.pixelFlyStatus=updatePixelfly(p.cameraParams('pixelfly'));
%                         updateThorcam(p.cameraParams('thorcam'));
                    case 'Live Cameras'
                        if exist('inst.cameras(''pixelfly'')')
                            stop(inst.cameras('pixelfly'));
                            clear inst.cameras('pixelfly');
                        end
                        imaqreset;
                        asyncRes=1;
                    case 'matlabPause'
                        delayInd=find(strcmpi(seq{ii},'duration'));
                        delayTime=seq{ii}{delayInd+1}*1e-6;
                        fprintf('MATLAB delay for %.2e seconds\n',delayTime);
                        asyncRes=1;
                        pause(delayTime);
                    case 'setHH'
                         directionInd=find(strcmpi(seq{ii},'direction'));
                         directionVal=seq{ii}{directionInd+1};
                         currentInd=find(strcmpi(seq{ii},'value'));
                         currentVal=seq{ii}{currentInd+1};
                    switch lower(directionVal)
                        case 'x'
                            inst.BiasCoils{2}.setCurrent(2,currentVal);
                        case 'y'
                            inst.BiasCoils{1}.setCurrent(1,currentVal);
                        case 'z'
                            inst.BiasCoils{1}.setCurrent(2,currentVal);
                    end
                        asyncRes=1;
                    otherwise
                        error('no such async action')
                end
            end
%             disp('done executeAsync');
        end
        
        function [syncRes]=executeSync(obj,seq)
            global p
            if isempty(seq)
                syncRes=NaN;
                return
            end
            tBlock=Block();
            block=Block(seq);
            block.setTimeline(0);
            seq=block.b;
            
            if any(tBlock.isAsync(seq))
                error('Error! can''t syncronously execute asyncronous action(s)');
            end
            if ~tBlock.isAtomic(seq)
                error('Error! Only atomic actions can execute');
            end
            %                     atomic={'pause','setDigitalChannel','setAnalogChannel'}
            
            for ii=1:size(seq,1)
                if strcmpi(seq{ii}{1},'pause')
                    continue
                end
                
                chanIdx=find(strcmpi(seq{ii},'channel'));
                if isempty(chanIdx)
                    error('Error: No channel name in action %s',seq{ii}{1});
                end
                channelName=seq{ii}{chanIdx+1};
                if strcmpi(channelName,'coolvvan')
                    seq{ii}=[seq{ii},'value'];
                    try
                        seq{ii}=[seq{ii},CoolingPower2AO(seq{ii}{find(strcmpi(seq{ii},'CoolingPower'))+1})];
                    catch
                        error('No CoolingPower found in set CoolingPower')
                    end
                end
                widthInd = find(strcmpi(seq{ii},'duration'));
                if isempty(widthInd)
                    error('Error: No duration in action %s',seq{ii}{1});
                end
                width=seq{ii}{widthInd+1};
                
                startTimeInd = find(strcmpi(seq{ii},'start time'));
                if isempty(startTimeInd)
                    error('Error: No startTime in action %s',seq{ii}{1});
                end
                startTime=seq{ii}{startTimeInd+1};
                
                ValueInd = find(strcmpi(seq{ii},'value'));
                if isempty(ValueInd)
                    error('Error: No value in action %s',seq{ii}{1});
                end
                Value=seq{ii}{ValueInd+1};
                
                
                switch seq{ii}{1}
                    %                     case 'pause'
                    %                         disp('pause');
                    case 'GenPause'
                        if ii==size(seq,1)
                        currentPulse=seq{ii};
                        else
                            error('GenPause can only be used at the and of a sequence!\n');
                        end
                                                
                    case 'setDigitalChannel'
                        %disp(sprintf('%s\n-----------------\n',channelName));
                        if strcmpi(Value,'Low')
                            width=-1;                        
                        end
                        currentPulse=Pulse(p.ct.PhysicalName{channelName},startTime,width);
                    case 'setAnalogChannel'
                        currentPulse=AnalogPulse(p.ct.PhysicalName{channelName},startTime,width,Value);
                    otherwise
                        error('Error! no such syncronic action!');
                end
                if ~exist('FPGASeq','var')
                    FPGASeq={currentPulse};
                else
                    FPGASeq = [FPGASeq,{currentPulse}];
                end
                
            end
            delayInd=find(strcmpi(seq{end},'start time'));
            if isempty(delayInd) && strcmpi(seq{end}{1},'pause')
                pauseInd=find(strcmpi(seq{end},'duration'));
                delayInd=find(strcmpi(seq{end-1},'start time'));
                pauseTime=(seq{end}{pauseInd+1}+seq{end-1}{delayInd+1})*1e-6;
            end
            
            if exist('FPGASeq','var')
                seqUpload(FPGASeq,p.DEBUG);
                if exist('pauseTime','var')
                    fprintf('Pausing for %.2f s for FPGA execution\n',pauseTime);
                    pause(pauseTime);
                else
                    pauseTime=seq{end}{delayInd+1}*1e-6+3;
                    fprintf('Pausing for %.2f s for FPGA execution\n',pauseTime);
                    pause(pauseTime);
                end

                %             p.cg.GenSeq(FPGASeq);
                %             p.cg.GenFinish;
                %             p.cg.DisplayCode
%                 disp('done executeSync');
            
            syncRes=1;
                
            else
                disp('done executeSync, with no actions. only pause?');
                syncRes=NaN;
            end
%             find(strcmpi(seq{end},'StartTime')
            
        end
        function stepRes=execute(obj,seq)
            global p
            if ~p.DEBUG
            [syncSeq,asyncSeq]=obj.sortAsync(seq);
            
            asyncRes=obj.executeAsync(asyncSeq);
            syncRes=obj.executeSync(syncSeq);
            
            stepRes=[asyncRes;syncRes];
            else 
                stepRes=0;
            end
            
        end
        function getbgImg(obj)
            global p
            global r
            global inst
            origS=p.s;
            p.s=sqncr();
            
            p.s.addBlock(Block({'bgimg'}));
            updatePixelfly();
            p.s.runStep();
            r.bgImg{1}=inst.cameras('pixelfly').getImages(1);
            p.s=origS;
        end
            
%         function loopingStop(
        function run(obj)
            global p
            global r
            global inst
%             loopVars=p.loopVars;
%             loopKeys=p.loopVars
            if nargin==1
                picsPerStep=p.picsPerStep;
            end
            loopVals=p.loopVals;
            tAll=tic;
            if isempty(p.loopVals) && isempty(p.loopVars)
                for ii = 1:p.NAverage
                    if p.NAverage
                        fprintf('Single step, parameterless run starting\n');
                    else
                        fprintf('Step %d out of %d, parameterless run starting\n',ii,p.NAverage);
                    end
                    updatePixelfly(); %This is tempurery
                    %                 if p.looping
                    %                     dialogBox = uicontrol('Style', 'PushButton', 'String', 'Break','Callback', '');
                    %                     while
                    obj.runStep();
                    if p.hasScopResults
                        r.scopeRes{1}(:,:,1,1,ii)=inst.scopes{1}.getChannels(p.chanList);
                    end                    
                    if ~p.pfLiveMode
                        try
                            r.images{1}(:,:,:,1,1,ii)=inst.cameras('pixelfly').getImages(picsPerStep);
                        catch
                            error('can''t access pixelfly. Check p.pfLiveMode')
                        end
                    end
                end
                fprintf('run complete\n');
                if p.postprocessing
                fprintf('Starting post processing.\n');
                tic
                obj.fitAll
                t=toc;
                fprintf('Post processing finished in t=%.2f s.\n',t);
                end
                customsave; 
                return
            end
            NInner = length(loopVals{1});
            if size(p.loopVals,2)~=1
                NOuter = length(loopVals{2});
            else
                NOuter=1;
                NoOuterFlag=1;
            end
            if NInner==0
                error('Can''t run a loop on outer loop without inner loop!');
            end
            for ii=1:NOuter
                for jj =1:NInner
                    for kk=1:p.NAverage
                        tStep=tic;
                        if ~exist('t')
                            t=0;
                        end
                        fprintf('Starting step %d out of %d. Averaging step #%d. Previous step took %.2f s\n',(ii-1)*NInner+jj,NInner*NOuter,kk,t)
                        updatePixelfly();
                        if exist('NoOuterFlag','var')
                            obj.runStep(loopVals{1}(jj));
                        else
                            obj.runStep(loopVals{1}(jj),loopVals{2}(ii));
                        end
                        if p.hasScopResults
                            r.scopeRes{1}(:,:,ii,jj,kk)=inst.scopes{1}.getChannels(p.chanList);
                        end
                        if p.hasPicturesResults %strcmpi(p.s.seq{1}.name,'Live MOT')
                            r.images{1}(:,:,:,ii,jj,kk)=inst.cameras('pixelfly').getImages(picsPerStep);
                            backupSave;
                        end
                        t=toc(tStep);
                        fprintf('Done step %d out of %d in %.2f s\n',(ii-1)*NInner+jj,NInner*NOuter,t);
                    end
                end
            end
            t2=toc(tAll);
            fprintf('Run completed. %d steps in %.2f seconds\n',NInner*NOuter,t2);
            
            
            if p.postprocessing
                fprintf('Starting post processing.\n');
                tic
                obj.fitAll
                t=toc;
                fprintf('Post processing finished in t=%.2f s.\n',t);
            end
            
        customsave; 
        end
        
        function calcTemp(obj,cam)
            %cam = 1 for pixelfly, =2 for thorcam
            global p
            global r
%             numPics=length(r.images(cam),
            delayList=p.TOFtimes*1e-6;    
            %we need to reshape the results to matrices who's collumns are
            %the TOF images, 7 rows are the fit parameters and the third
            %dimension is all the possible scan value permutations. 
            numScanParams=size(p.loopVals,2);
            if numScanParams==2
            numEl=size(p.loopVals{1},2)*size(p.loopVals{2},2)*p.NAverage;
            sizeInner=size(p.loopVals{1},2);
            sizeOuter=size(p.loopVals{2},2);
            elseif numScanParams==1
            numEl=size(p.loopVals{1},2)*p.NAverage;
            sizeInner=size(p.loopVals{1},2);
            sizeOuter=1;
            else 
                    
            sizeInner=1;
            sizeOuter=1;
            numEl=p.NAverage;
            end
            origShape=size(r.fitParams{cam});
            res=reshape(r.fitParams{cam},7,p.NTOF,numEl);
            
            for ii=1:numEl
            if length(find(res(5,:,ii)>0))>2
                [r.Txfit{cam}{ii},r.TxGOF{cam}{ii}]=fit(delayList'.^2,res(5,:,ii)'.^2,'poly1',...
                    'Exclude',res(5,:,ii)==0);
            else
                r.Txfit{cam}{ii}.p1=0;
                r.TxGOF{cam}{ii} = 0;
            end
            if length(find(res(6,:,ii)>0))>2
                [r.Tyfit{cam}{ii},r.TyGOF{cam}{ii}]=fit(delayList'.^2,res(6,:,ii)'.^2,'poly1',...
                    'Exclude',res(6,:,ii)==0);
            else
                r.Tyfit{cam}{ii}.p1=0;
                r.TyGOF{cam}{ii} = 0;
            end
            
            mrb=p.consts.mrb;
            kb=p.consts.kb;
            
            r.Tx{cam}(ii)=1e6.*r.Txfit{cam}{ii}.p1*mrb/kb;
            if r.Tx{cam}(ii)==0
                r.Tx{cam}(ii) = NaN;
            end
            r.Ty{cam}(ii)=1e6*r.Tyfit{cam}{ii}.p1*mrb/kb;
            if r.Ty{cam}(ii)==0
                r.Ty{cam}(ii) = NaN;
            end
            end
            
          r.Txfit{cam}=reshape(r.Txfit{cam},sizeOuter,sizeInner,p.NAverage);
          r.Tyfit{cam}=reshape(r.Tyfit{cam},sizeOuter,sizeInner,p.NAverage);
          r.TxGOF{cam}=reshape(r.TxGOF{cam},sizeOuter,sizeInner,p.NAverage);
          r.TyGOF{cam}=reshape(r.TyGOF{cam},sizeOuter,sizeInner,p.NAverage);
          r.Tx{cam}=reshape(r.Tx{cam},sizeOuter,sizeInner,p.NAverage);
          r.Ty{cam}=reshape(r.Ty{cam},sizeOuter,sizeInner,p.NAverage);
        end
        
        function fitAll(obj)
            global r
            global p
            global inst
            if ~p.pfLiveMode
                imVec{1}=reshape(r.images{1},size(r.images{1},1),size(r.images{1},2),size(r.images{1},3)*size(r.images{1},4)*size(r.images{1},5)*size(r.images{1},6)); %pixelfly imVec

                r.y=linspace(1,size(r.images{1},1)+1,size(r.images{1},1)).*inst.cameras('pixelfly').getScale;
                r.x=linspace(1,size(r.images{1},2)+1,size(r.images{1},2)).*inst.cameras('pixelfly').getScale;
                [fp,gof,fitVec]=vec2DgaussFit(r.x,r.y,imVec{1},r.bgImg{1});
                r.fitImages{1}=reshape(fitVec,size(r.images{1}));
                r.fitParams{1}=reshape(fp,7,size(r.images{1},3),size(r.images{1},4),size(r.images{1},5),size(r.images{1},6));
                r.GOF{1}=reshape(gof,size(r.images{1},3),size(r.images{1},4),size(r.images{1},5),size(r.images{1},6));
                obj.calcTemp(1);
            end
        end
        
        
        
    end
    
end

