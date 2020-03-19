classdef sqncr < handle & matlab.mixin.CustomDisplay
    %sequence generator
    properties
        seq
        name='empty';
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
        
        function clear(obj)
            %clear the sequence
            obj.seq={};
        end
        function str=stringify(obj)
            str=sprintf('Sequence:\n');
            str=[str sprintf('_________\n')];
            if isempty(obj.seq)
                str=[str sprintf('Empty sequence\n')];
            else
                for ind=1:length(obj.seq)
                    str=[str sprintf('Block %d: %s\n',ind,obj.seq{ind}.name)]; %TODO: add a block getName func
                end
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
        function [syncSeq,asyncSeq]=atomizeAndMerge(obj,varargin)
            if isempty(obj.seq)
                error('sequence is empty, cannot perform action');
            end
            %             if nargin==2
            %                 %a pre-atomized innerloopVal was passed (needed to use for
            %                 %blocks)
            %
            %             elseif nargin==3
            %                 %a pre-atomized outerloopVal was passed (needed to use for
            %                 %blocks)
            %
            %             end
            if nargin==2
                %this meens that a seq has been enterd, and you need to
                %atomize it, rathar then the "obj.seq"
                tmpSeq = varargin{1};
                for ii=1:size(tmpSeq,1)
                    if ii==1
                        tmpSeq{ii}.atomizeAll;
                        fullseq = obj.tmpSeq{ii}.b;
                    else
                        tmpSeq{ii}.atomizeAll;
                        fullseq=[fullseq;obj.tmpSeq{ii}.b];
                    end
                end
                [syncSeq,asyncSeq]=obj.sortAsync(fullseq);
            else
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
%             populatedSeq=obj.populateVars(obj.seq,innerLoopVal,outerLoopVal); %populate value
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
            for ii = 1:size(fullSeq,1)
                if strcmpi(class(fullSeq{ii}),'block')
                    fullSeq{ii} = fullSeq{ii}.b;
                end
            end
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
                try
                    inst.scopes{1}.setState('single');
                    fullscreenTime=inst.scopes{1}.getTimebase;
                    fprintf('Set Scope to single, pausing for %.2f\n',fullscreenTime/2);
                    pause(fullscreenTime/2+0.1) % This pause is because the scope would not trigger at long times.
                    if inst.scopes{1}.isTrigged
                        error('scope remains in trigged mode!');
                    end
                    
                catch err
                    warning('Error in scope readout:%s',err.message);
                end
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
                        disp('setDDSfreq not implemented yet')
                        asyncRes=1;
                    case 'setICEFreq'
                        laserNameInd=find(strcmpi('Laser Name',seq{ii}));
                        if isempty(laserNameInd)
                            error('Laser name missing in setICEDetuning');
                        end
                        laserName = seq{ii}{laserNameInd+1};
                        freqInd=find(strcmpi('freq',seq{ii}));
                        if isempty(freqInd)
                            error('freq missing in setICEFreq');
                        end
                        freq = seq{ii}{freqInd+1}; %in MHz
                        
                        evtNumInd=find(strcmpi('evtNum',seq{ii}));
                        if isempty(evtNumInd)
                            evtNum=1;
                        else
                            evtNum=seq{ii}{evtNumInd+1};
                        end
                        FeedFordInd = find(strcmpi('FeedForward',seq{ii}));
                        if isempty(evtNumInd)
                            FeedFord=0;
                        else
                            FeedFord=seq{ii}{FeedFordInd+1};
                        end
                        N=inst.Lasers(lower(laserName)).getMultiplyer;
                        if strcmpi(inst.Lasers(lower(laserName)).getIntRefStatus,'on') %check if locking to internal vco.
                            if strcmpi(laserName,'cooling')
                                freq = coolingDetToFreq(freq,N);
                                inst.Lasers(lower(laserName)).setIntFreq(freq);
                                inst.Lasers(lower(laserName)).setEventData(freq,evtNum,1,FeedFord); %cooling uses mode 1, i.e invert off and int vco on
                                %                                 inst.Lasers(lower(laserName)).setCurrentEvent(evtNum);
                            elseif strcmpi(laserName,'repump')
                                freq = repumpDetToFreq(Detuning,N);
                                %                                 inst.Lasers(lower(laserName)).setIntFreq(freq);
                                inst.Lasers(lower(laserName)).setEventData(freq,1,15,0); %repump uses mode 15, i.e invert on and int vco on
                                inst.Lasers(lower(laserName)).setCurrentEvent(evtNum);
                            else
                                error('Only cooling and repump are implemented. If using a deferent laser, implement it.\n')
                            end
                        else
                            error('Exturnal reference jump is not implemented yet')
                        end
                        asyncRes=1;
                    case 'setICEDetuning'
                        laserNameInd=find(strcmpi('Laser Name',seq{ii}));
                        if isempty(laserNameInd)
                            error('Laser name missing in setICEDetuning');
                        end
                        laserName = seq{ii}{laserNameInd+1};
                        detInd=find(strcmpi('detuning',seq{ii}));
                        if isempty(detInd)
                            error('Detuning missing in setICEDetuning');
                        end
                        Detuning = seq{ii}{detInd+1}; %in MHz
                        
                        evtNumInd=find(strcmpi('evtNum',seq{ii}));
                        if isempty(evtNumInd)
                            evtNum=1;
                        else
                            evtNum=seq{ii}{evtNumInd+1};
                        end
                        FeedFordInd = find(strcmpi('FeedForward',seq{ii}));
                        if isempty(evtNumInd)
                            FeedFord=0;
                        else
                            FeedFord=seq{ii}{FeedFordInd+1};
                        end
                        N=inst.Lasers(lower(laserName)).getMultiplyer;
                        if strcmpi(inst.Lasers(lower(laserName)).getIntRefStatus,'on') %check if locking to internal vco.
                            if strcmpi(laserName,'cooling')
                                freq = coolingDetToFreq(Detuning,N);
                                %                                 inst.Lasers(lower(laserName)).setIntFreq(freq);
                                inst.Lasers(lower(laserName)).setEventData(freq,evtNum,1,FeedFord); %cooling uses mode 1, i.e invert off and int vco on
                                
                            elseif strcmpi(laserName,'repump')
                                freq = repumpDetToFreq(Detuning,N);
                                %                                 inst.Lasers(lower(laserName)).setIntFreq(freq);
                                inst.Lasers(lower(laserName)).setEventData(freq,1,15,0); %repump uses mode 15, i.e invert on and int vco on
                            else
                                error('Only cooling and repump are implemented. If using a deferent laser, implement it.\n')
                            end
                        else
                            error('External reference jump is not implemented yet')
                        end
                        asyncRes=1;
                    case 'getWLMdata'
                        disp('getWLMdata')
                        asyncRes=1;
                    case 'updateCams'
                        asyncRes.pixelFlyStatus=updatePixelfly(p.cameraParams('pixelfly'));
                        updateThorcam(p.cameraParams('thorcam'));
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
                    case 'SetupDDSSweepCentSpan'
                        channelInd = find(strcmpi(seq{ii},'channel')); %DDS chanel, 1-4
                        channelVal = seq{ii}{channelInd+1};
                        centerInd = find(strcmpi(seq{ii},'center')); %DDS Scan center
                        centerVal = seq{ii}{centerInd+1};
                        spanInd = find(strcmpi(seq{ii},'span')); %Sweep span
                        spanVal = seq{ii}{spanInd+1};
                        UpTimeInd = find(strcmpi(seq{ii},'UpTime')); %Sweep up time
                        UpTimeVal = seq{ii}{UpTimeInd+1};
                        multiplyerInd = find(strcmpi(seq{ii},'multiplyer'));%multiplyer (for locking)
                        if multiplyerInd == 0
                            multiplyerVal = 1;
                        else
                            multiplyerVal = seq{ii}{multiplyerInd+1};
                        end
                        symmetricInd = find(strcmpi(seq{ii},'symmetric'));%if 1 then the scan is symetric
                        if isempty(symmetricInd)
                            symmetricVal = 1;
                            downTimeVal = UpTimeVal;
                        else
                            symmetricIndVal = seq{ii}{symmetricInd+1};
                            if symmetricIndVal ~= 1
                                downTimeInd = ind(strcmpi(seq{ii},'downTime')); %If not symmetric then this is the down ramp time
                                downTimeVal = seq{ii}{downTimeInd+1};
                            else
                                downTimeVal = UpTimeVal;
                            end
                        end
                        inst.DDS.setupSweepMode(channelVal,centerVal,spanVal,UpTimeVal,multiplyerVal,symmetricVal,downTimeVal)
                        asyncRes=1;
                    case 'SetupDDSSweepUpDown'
                        channelInd = find(strcmpi(seq{ii},'channel')); %DDS chanel, 1-4
                        channelVal = seq{ii}{channelInd+1};
                        UpFreqInd = find(strcmpi(seq{ii},'UpFreq')); %DDS Up frequency
                        UpFreqVal = seq{ii}{UpFreqInd+1};
                        DownFreqInd = find(strcmpi(seq{ii},'DownFreq')); %DDS down frequency
                        DownFreqVal = seq{ii}{DownFreqInd+1};
                        UpTimeInd = find(strcmpi(seq{ii},'UpTime')); %Sweep up time
                        UpTimeVal = seq{ii}{UpTimeInd+1};
                        multiplyerInd = find(strcmpi(seq{ii},'multiplyer'));%multiplyer (for locking)
                        if isempty(multiplyerInd)
                            multiplyerVal = 1;
                        else
                            multiplyerVal = seq{ii}{multiplyerInd+1};
                        end
                        symmetricInd = find(strcmpi(seq{ii},'symmetric'));%if 1 then the scan is symetric
                        if isempty(symmetricInd)
                            symmetricIndVal = 1;
                            downTimeVal = UpTimeVal;
                        else
                            symmetricVal = seq{ii}{symmetricInd+1};
                            if symmetricVal ~= 1
                                downTimeInd = find(strcmpi(seq{ii},'downTime')); %If not symmetric then this is the down ramp time
                                downTimeVal = seq{ii}{downTimeInd+1};
                            else
                                downTimeVal = UpTimeVal;
                            end
                        end
                        inst.DDS.setupSweepModeUpFreqDownFreq(channelVal,UpFreqVal,DownFreqVal,UpTimeVal,multiplyerVal,symmetricVal,downTimeVal)
                        asyncRes=1;
                    case 'SetMWFreq'
                        freqInd = find(strcmpi(seq{ii},'frequency')); %in MHz.
                        freqVal = seq{ii}{freqInd+1};
                        inst.MWSource.setFreq(freqVal,0,0);
                        asyncRes=1;
                    case 'setRigolDC'
                        chanInd = find(strcmpi(seq{ii},'channel')); %1, 2 or 'both'
                        chanVal = seq{ii}{chanInd+1};
                        biasInd = find(strcmpi(seq{ii},'output')); %in V
                        biasVal = seq{ii}{biasInd+1};
                        if strcmpi(chanVal,'both')
                            inst.rigol1.applyDC(1,biasVal);
                            inst.rigol1.applyDC(2,biasVal);
                        elseif chanVal==1
                            inst.rigol1.applyDC(1,biasVal);
                        elseif chanVal==2
                            inst.rigol1.applyDC(2,biasVal);
                        else
                            error('bad settings in async action: setRigolDC');
                        end
                        asyncRes=1;
                    case 'setRigolModParams'
                        chanInd = find(strcmpi(seq{ii},'channel')); %1, 2 or 'both'
                        chanVal = seq{ii}{chanInd+1};
                        biasInd = find(strcmpi(seq{ii},'bias')); %in V
                        biasVal = seq{ii}{biasInd+1};
                        modInd = find(strcmpi(seq{ii},'modulation')); %in V
                        modVal = seq{ii}{modInd+1};
                        freqInd = find(strcmpi(seq{ii},'freq')); %in Hz
                        freqVal = seq{ii}{freqInd+1};
                        if strcmpi(chanVal,'both')
                            inst.rigol1.setModulatedSinWave(1,biasVal,modVal,freqVal);
                            inst.rigol1.setModulatedSinWave(2,biasVal,modVal,freqVal);
                        elseif chanVal==1
                            inst.rigol1.setModulatedSinWave(1,biasVal,modVal,freqVal);
                        elseif chanVal==2
                            inst.rigol1.setModulatedSinWave(2,biasVal,modVal,freqVal); 
                        else
                            error('bad settings in async action: setRigolModParams');
                        end
                        asyncRes=1;
                        case 'setRigolGateMode'
                            %sets the gating mode of the rigol FG
                            chanInd = find(strcmpi(seq{ii},'channel')); %1, 2 or 'both'
                            if isempty(chanInd)
                               error('no channle in ''setRigolGateMode''');
                            end
                            chanVal = seq{ii}{chanInd+1};
                            modeInd = find(strcmpi(seq{ii},'mode')); %'NORMal', or 'GATed'.
                            if isempty(modeInd)
                                error('no mode in ''setRigolGateMode''');
                            end
                            modeVal = seq{ii}{modeInd+1};
                            if strcmpi(chanVal,'both')
                                inst.rigol1.setGateMode(1,modeVal);
                                inst.rigol1.setGateMode(2,modeVal);
                            elseif chanVal==1
                                inst.rigol1.setGateMode(1,modeVal);
                            elseif chanVal==2
                                inst.rigol1.setGateMode(2,modeVal);
                            else
                                error('bad channle settings in async action: setRigolGateMode');
                            end
                            asyncRes=1;
                    case 'setCamExp'
                        expTimeInd = find(strcmpi(seq{ii},'expTime'));
                        if isempty(expTimeInd)
                            error('no expTime found in setCamExp!')
                        end
                        expTimeVal = seq{ii}{expTimeInd+1};
                        camInd = find(strcmpi(seq{ii},'cam'));
                        if isempty(camInd)
                            camVal = 'plane';
                        else
                            camVal = seq{ii}{camInd+1};
                        end
                        if strcmpi(camVal,'plane')
                            p.cameraParams{1}.E2ExposureTime = expTimeVal;
                        elseif strcmpi(camVal,'top')
                            p.cameraParams{2}.E2ExposureTime = expTimeVal;
                        else
                            error('cam must be ''plane'', or ''top''!')
                        end
                        updatePixelfly;
                        asyncRes=1;
                    otherwise
                        error('%s no such async action',seq{ii}{1});
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
                
                if strcmpi(seq{ii}{1},'forStart')
                    seq{ii}{end+1}='channel';
                    seq{ii}{end+1}='forStart';
                    seq{ii}{end+1}='duration';
                    seq{ii}{end+1}=0;
                    seq{ii}{end+1}='value';
                    seq{ii}{end+1}=0;
                end
                if strcmpi(seq{ii}{1},'forEnd')
                    seq{ii}{end+1}='channel';
                    seq{ii}{end+1}='forEnd';
                    seq{ii}{end+1}='duration';
                    seq{ii}{end+1}=0;
                end
                if strcmpi(seq{ii}{1},'setCoolingDetuning')
                    seq{ii}{end+1}='channel';
                    seq{ii}{end+1} = 'COOLVCO';
                end
                if strcmpi(seq{ii}{1},'setRepumpDetuning')
                    seq{ii}{end+1}='channel';
                    seq{ii}{end+1} = 'RPMPVCO';
                end
                if strcmpi(seq{ii}{1},'setImagingDetuning')
                    seq{ii}{end+1}='channel';
                    seq{ii}{end+1} = 'ImagingVCO';
                end
                if ~strcmpi(seq{ii}{1},'GenPause')
                    chanIdx=find(strcmpi(seq{ii},'channel'));
                    if isempty(chanIdx)
                        error('Error: No channel name in action %s',seq{ii}{1});
                    end
                    channelName=seq{ii}{chanIdx+1};
                    if strcmpi(channelName,'coolvvan') && strcmpi(seq{ii}{1},'setAnalogChannel')
                        seq{ii}=[seq{ii},'value'];
                        try
                            seq{ii}=[seq{ii},CoolingPower2AO(seq{ii}{find(strcmpi(seq{ii},'coolingPower'))+1})];
                        catch
                            warning('No CoolingPower found in set CoolingPower')
                        end
                    elseif strcmpi(channelName,'ImagingVVAN') && strcmpi(seq{ii}{1},'setAnalogChannel') 
                        valueInd = find(strcmpi(seq{ii},'value'));
                        try
                            seq{ii}{valueInd+1}=ImagingPower2AO(seq{ii}{valueInd+1});
                        catch err
                            error('%s',err.message)
                        end
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
                if ~strcmpi(seq{ii}{1},'GenPause')
                    ValueInd = find(strcmpi(seq{ii},'value'));
                    if isempty(ValueInd)
                        error('Error: No value in action %s',seq{ii}{1});
                    end
                    Value=seq{ii}{ValueInd+1};
                end
                InvertedInd = find(strcmpi(seq{ii},'inverted'));
                if isempty(InvertedInd)
                    Inverted = false;
                else
                    Inverted=true;
                end
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
                            if width==0
                                width=-1;
                            end
                        end
                        currentPulse=Pulse(p.ct.PhysicalName{channelName},startTime,width);
                        if Inverted
                            currentPulse.inverted = true;
                        end
                    case 'setCircCurrent'
                        currentPulse=AnalogPulse(p.ct.PhysicalName{'CircCoil'},startTime,width,Value*10/220);
                    case 'setAnalogChannel'
                        currentPulse=AnalogPulse(p.ct.PhysicalName{channelName},startTime,width,Value);
                        if Inverted
                            currentPulse.inverted = true;
                        end
                    case 'startAnalogRamp'
                        currentPulse=AnalogPulse(p.ct.PhysicalName{channelName},startTime,width,0);
                        currentPulse.ramp=true;
                        stepSize=int16(2^16/(width/1.5)); %1.5 microseconds is the update time for the analog channel.
                        
                        fprintf('Circular coil ramp step size: %d\n',stepSize);
                        p.rampStepSize(end+1)=stepSize;
                        currentPulse.rampStepSize=stepSize;
                        if currentPulse.rampTime>33e3
                            error('max ramp time: 1/3 second!')
                        end
                        currentPulse.rampTime=width/10; %ramp duration is in 10 microsecond jumps
                        p.rampTime(end+1)=currentPulse.rampTime*10; %in microseconds
                        currInd=find(strcmpi('EndCurrent',seq{ii}));
                        currentPulse.rampFinalVal=seq{ii}{currInd+1};
                    case 'startCoolingPowerRamp'
                        currentPulse=AnalogPulse(p.ct.PhysicalName{channelName},startTime,width,0);
                        currentPulse.ramp=true;
                        stepSize=int16(2^16/(width/1.5)); %1.5 microseconds is the update time for the analog channel.
                        
                        fprintf('Cooling power ramp step size: %d\n',stepSize);
                        p.rampStepSize(end+1)=stepSize;
                        currentPulse.rampStepSize=stepSize;
                        if currentPulse.rampTime>33e3
                            error('max ramp time: 1/3 second!')
                        end
                        currentPulse.rampTime=width/10; %ramp duration is in 10 microsecond jumps
                        p.rampTime(end+1)=currentPulse.rampTime*10; %in microseconds
                        currInd=find(strcmpi('EndPower',seq{ii}));
                        currentPulse.rampFinalVal=round(2^15/10 * CoolingPower2AO(seq{ii}{currInd+1}));
                    case 'forStart'
                        currentPulse=AnalogPulse('forStart',startTime,0,Value);
                        
                    case 'forEnd'
                        currentPulse=AnalogPulse('forEnd',startTime,0,Value);
                    case 'setCoolingDetuning'
                        det = Value;
                        VCOFreq = 110-(p.coolingLockDet-det)/2;
                        minDet = (75.83-110)*2+p.coolingLockDet;
                        maxDet = (154.65-110)*2+p.coolingLockDet;
                        if VCOFreq<75.83
                            warning(sprintf('desired cooling detuning can''t be set. Minimal detuning of %0.2f set',minDet))
                            VCOFreq = 75.84;
                        elseif VCOFreq>154.56
                            warning(sprintf('desired cooling detuning can''t be set. Maximal detuning of %0.2f set',maxDet))
                            VCOFreq = 154.55;
                        end
                        AOVolt = CoolingVCOFreq2AO(VCOFreq);
                        currentPulse=AnalogPulse(p.ct.PhysicalName{'COOLVCO'},startTime,width,AOVolt);
                        case 'setRepumpDetuning'
                        det = Value;
                        VCOFreq = 110-det;
                        minDet = 110-154.35;
                        maxDet = 110-75.22;
                        if VCOFreq>154.35
                            warning(sprintf('desired repump detuning can''t be set. Minimal detuning of %0.2f set',minDet))
                            VCOFreq = 154.34;
                        elseif VCOFreq<75.22
                            warning(sprintf('desired repump detuning can''t be set. Maximal detuning of %0.2f set',maxDet))
                            VCOFreq = 75.23;
                        end
                        AOVolt = RepumpVCOFreq2AO(VCOFreq);
                        currentPulse=AnalogPulse(p.ct.PhysicalName{'RPMPVCO'},startTime,width,AOVolt);
                    case 'setImagingDetuning'
                        AOVolt = ImagingVCOFreq2AO(220-p.coolingLockDet+Value);
                        currentPulse=AnalogPulse(p.ct.PhysicalName{channelName},startTime,width,AOVolt);
                    otherwise
                        error('Error! no such synchronic action! %s',seq{ii}{1});
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
                    pauseTime=seq{end}{delayInd+1}*1e-6+0.1;
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
            p.s.runStep();
            if ~p.pfPlaneLiveMode
                r.bgImg{1}=inst.cameras('pixelflyPlane').getImages(1);
            end
            if ~p.pfTopLiveMode
                r.bgImg{2}=inst.cameras('pixelflyTop').getImages(1);
            end
            updatePixelfly();
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
                    if p.NAverage == 1
                        fprintf('Single step, parameterless run starting\n');
                    else
                        fprintf('Step %d out of %d, parameterless run starting\n',ii,p.NAverage);
                    end
                    %                     updatePixelfly();
                    %                     updateThorcam();
                    %                 if p.looping
                    %                     dialogBox = uicontrol('Style', 'PushButton', 'String', 'Break','Callback', '');
                    %                     while
                    obj.runStep();
                    if p.hasScopResults
                        try
                            dat=inst.scopes{1}.getChannels(p.chanList);
                            r.scopeRes{1}=zeros(size(dat,1),size(dat,2),1,1,p.NAverage);
                            r.scopeRes{1}(:,:,1,1,ii)=dat;
                        catch err
                            warning(err.identifier,'Error in scope readout:%s',err.message);
                        end
                        
                    end
                    if p.hasSpecResults
                        try
                            if p.handheldSpecRes
                                [tmpFreq,tmpAmp] = inst.spectrumAna{2}.getTrace;
                                r.specRes{2}(:,1,1,1,ii) = tmpFreq;
                                r.specRes{2}(:,2,1,1,ii) = tmpAmp;
                            end
                        catch err
                            error(err.identifier,'Can''t get trace from handheld spectrum analyzer.\n%s\n',err.message);
                        end
                        try
                            if p.benchtopSpecRes
                                [tmpFreq,tmpAmp] = inst.spectrumAna{1}.getTrace;
                                r.specRes{1}(:,1,1,1,ii) = tmpFreq;
                                r.specRes{1}(:,2,1,1,ii) = tmpAmp;
                            end
                        catch err
                            error(err.identifier,'Can''t get trace from benchtop spectrum analyzer.\n%s\n',err.message);
                        end
                    end
                    if ~p.pfPlaneLiveMode
                        try
                            tmp=inst.cameras('pixelflyPlane').getImages(picsPerStep);
                            r.images{1}(:,:,1:size(tmp,3),1,1,ii)=tmp;
                        catch err
                            error('can''t access pixelfly. Check p.pfLiveMode\n%s',err.message)
                        end
                    end
                    if ~p.pfTopLiveMode
                        try
                            tmp=inst.cameras('pixelflyTop').getImages(picsPerStep);
                            r.images{2}(:,:,1:size(tmp,3),1,1,ii)=tmp;
                            %                             tc=inst.cameras('pixelflyTop');
                            %
                            %                             [~,numTrigs]=inst.cameras('thorcam').cam.Trigger.Counter.Get;
                            %                             if numTrigs ~= p.picsPerStep
                            %                                 error('Thorcam did not receive all trigger pulses!.\n Expected %d, actuall: %d',p.picsPerStep,tc.numTrigs);
                            %                             end
                            % %                             for ind=2:numTrigs+1
                            %                             memlist=double(tc.memlist);
                            %                             for ind=1:p.picsPerStep
                            % %                                 r.images{2}(:,:,ind)=tc.getImageFromMemoryLocation(ind);
                            %                                 [result,memid,seqid]=tc.cam.Memory.Sequence.WaitForNextImage(1e3);
                            %                                 r.images{2}(:,:,ind)=tc.getImageFromMemoryLocation(double(memid));
                            % %                                 tc.cam.Memory.ToIntPtr(memid);
                            %                                 tc.cam.Memory.Sequence.Unlock(memid)
                            % %                                 r.images{2}(:,:,ind)=tc.cam.Memory.ToIntPtr(memlist(ind));
                            % %                                 tc.cam.Memory.ToIntPtr(int32(2:40));
                            % %                                 tc.cam.Memory.Sequence.Unlock(int32(ind-1));
                            %                             end
                            %
                            % %                             tc.cam.Memory.Sequence.ExitImageQueue;
                            %                             tc.clearTriggerCount;
                            %                             tc.clearSeqMemory;
                            %                             tc.cam.Acquisition.Stop;
                            % %                             tc.cam.Exit;
                            % %                             tc.cam.Init;
                            %                             %                             tmp=inst.cameras('thorcam').getImages(picsPerStep);
                            %                             %                             r.images{2}(:,:,1:size(tmp,3),1,1,ii)=tmp;
                        catch err
                            error(err.identifier,'can''t access pixelflyTop. Check p.pfLiveMode\n%s',err.message)
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
                if p.notificationOn
                    
                    pb1=Pushbullet('o.j3zDBT7wvgkxZ0iq5pl35nazFjUqyElI'); %Gal's API key
                    pb2=Pushbullet('o.iSMxC5nj0HiMBdTFMhc6x6wvQBC1viyW'); %Lee's API key
                    pb1.pushNote([],'Cold Lab notification!','measurement done!');
                    pb2.pushNote([],'Cold Lab notification!','measurement done!');
                end
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
                        %                         updatePixelfly();
                        %                         updateThorcam();
                        if exist('NoOuterFlag','var')
                            obj.runStep(loopVals{1}(jj));
                        else
                            obj.runStep(loopVals{1}(jj),loopVals{2}(ii));
                        end
                        if p.hasScopResults
                            try
                                dat=inst.scopes{1}.getChannels(p.chanList);
                                if (ii==1 && jj==1 && kk==1)
                                    %Changed on 26/08/18 by LD
%                                     r.scopeRes{1}=zeros(1e5,5,NOuter,NInner,p.NAverage);
                                    r.scopeRes{1}=zeros(size(dat,1),size(dat,2),NOuter,NInner,p.NAverage);
                                end
                                r.scopeRes{1}(1:size(dat,1),1:size(dat,2),ii,jj,kk)=dat;
                            catch err
                                warning(err.identifier,'Error in scope readout:%s',err.message);
                            end
                        end
                        if p.hasSpecResults
                            updateSpectrumAnalyzer;
                            try
                                if p.handheldSpecRes
                                [tmpFreq,tmpAmp] = inst.spectrumAna{2}.getTrace;
                                r.specRes{2}(:,1,ii,jj,kk) = tmpFreq;
                                r.specRes{2}(:,2,ii,jj,kk) = tmpAmp;
                                end
                            catch err
                                error(err.identifier,'Can''t get trace from handheld spectrum analyzer. %s',err.message);
                            end
                            try
                                if p.benchtopSpecRes
                                [tmpFreq,tmpAmp] = inst.spectrumAna{1}.getTrace;
                                r.specRes{1}(:,1,ii,jj,kk) = tmpFreq;
                                r.specRes{1}(:,2,ii,jj,kk) = tmpAmp;
                                end
                            catch err
                                error(err.identifier,'Can''t get trace from benchtop spectrum analyzer. %s',err.message);
                            end
                        
                        end
                        if p.hasPicturesResults %strcmpi(p.s.seq{1}.name,'Live MOT')
                            if picsPerStep~=1
                                if ~p.pfPlaneLiveMode
                                    try
                                        r.images{1}(:,:,:,ii,jj,kk)=inst.cameras('pixelflyPlane').getImages(picsPerStep);
                                    catch err
                                        error(err.identifier,'can''t access pixelflyPlane. Check p.pfLiveMode\n%s',err.message);
                                    end
                                end
                                if ~p.pfTopLiveMode
                                    try
                                        r.images{2}(:,:,:,ii,jj,kk)=inst.cameras('pixelflyTop').getImages(picsPerStep);
                                    catch err
                                        error(err.identifier,'can''t access pixelflyPlane. Check p.pfLiveMode\n%s',err.message);
                                    end
                                    %                                         tc=inst.cameras('thorcam');
                                    %                                         [~,numTrigs]=inst.cameras('thorcam').cam.Trigger.Counter.Get;
                                    %                                         %                             if tc.numTrigs ~= p.picsPerStep
                                    %                                         %                                 warning('Thorcam did not receive all trigger pulses!.\n Expected %d, actuall: %d',p.picsPerStep,tc.numTrigs);
                                    %                                         %                             end
                                    %                                         for ind=2:numTrigs+1
                                    %                                             r.images{2}(:,:,ind-1,ii,jj,kk)=tc.getImageFromMemoryLocation(ind);
                                    %                                         end
                                    %                                         tc.clearTriggerCount;
                                    %                                         %                             tc.cam.Memory.Sequence.ExitImageQueue;
                                    %
                                    %                                         %                             tmp=inst.cameras('thorcam').getImages(picsPerStep);
                                    %                                         %                             r.images{2}(:,:,1:size(tmp,3),1,1,ii)=tmp;
                                    %                                     catch err
                                    %                                         error('can''t access thorcam. Check p.tcLiveMode\n%s',err.message)
                                    %                                     end
                                end
                            else
                                if ~p.pfPlaneLiveMode
                                    try
                                        r.images{1}(:,:,1,ii,jj,kk)=inst.cameras('pixelflyPlane').getImages(picsPerStep);
                                    catch err
                                        error(err.identifier,'can''t access pixelflyPlane. Check p.pfLiveMode\n%s',err.message);
                                    end
                                end
                                if ~p.pfTopLiveMode
                                    try
                                        r.images{2}(:,:,1,ii,jj,kk)=inst.cameras('pixelflyTop').getImages(picsPerStep);
                                    catch err
                                        error(err.identifier,'can''t access pixelflyPlane. Check p.pfLiveMode\n%s',err.message);
                                    end
                                end
                            end
                        end
%                        
                        pause(p.pauseBetweenRunSteps);
                        t=toc(tStep);
                        fprintf('Done step %d out of %d in %.2f s\n',(ii-1)*NInner+jj,NInner*NOuter,t);
                    end
                end
                
                  backupSave; %tried moving crash backup to outer loop. this might improve runtime
            end
            t2=toc(tAll);
            fprintf('Run completed. %d steps in %.2f seconds\n',NInner*NOuter,t2);
            
            if p.postprocessing
                
                fprintf('Starting post processing.\n');
                tpost=tic;
                obj.fitAll
                t=toc(tpost);
                fprintf('Post processing finished in t=%.2f s.\n',t);
            end
            tsave=tic;
            customsave;
            t=toc(tsave);
            fprintf('Customsave finished in t=%.2f s.\n',t);
        end
        function calcTemp(obj,cam,delayList)
            %cam = 1 for pixelfly, =2 for thorcam
            global p
            global r
            %             numPics=length(r.images(cam),
            if nargin ==2
                delayList=p.TOFtimes*1e-6;
            end
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
                if length(find(res(5,:,ii)>0))>1
                    [r.Txfit{cam}{ii},r.TxGOF{cam}{ii}]=fit(delayList'.^2,res(5,:,ii)'.^2,'poly1',...
                        'Exclude',res(5,:,ii)==0);
                else
                    r.Txfit{cam}{ii}.p1=0;
                    r.TxGOF{cam}{ii} = 0;
                end
                if length(find(res(6,:,ii)>0))>1
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
            %           r.TxR2{cam}=r.TxGOF{cam}(:)
            %           cellfun(@(x) isstruct(x),r.TxGOF{cam}(:))
        end
        function fitAll(obj)
            global r
            global p
            global inst
            obj.checkSaturation;
            if length(r.satFlags)>1
               if any(r.satFlags{1}(:)==1)
                   warning('Saturation in camera 1. Check r.satFlags for details');
               end
               if any(r.satFlags{2}(:)==1)
                   warning('Saturation in camera 2. Check r.satFlags for details');
               end
            else
                if any(r.satFlags{1}(:)==1)
                   warning('Saturation in camera 1. Check r.satFlags for details');
               end
            end
            %fit pielflyPlane
            if ~p.pfPlaneLiveMode
                r.y{1} = inst.cameras('pixelflyPlane').y;
                r.x{1} = inst.cameras('pixelflyPlane').x;
                if p.absImg{1}==1
                    imMat = reshape(r.images{1},size(r.images{1},1),size(r.images{1},2),size(r.images{1},3),size(r.images{1},4)*size(r.images{1},5)*size(r.images{1},6));
                    imVec{1} = squeeze(log(abs(imMat(:,:,1,:)./imMat(:,:,2,:))));
                    [fp,gof,fitVec]=vec2DgaussFit(r.x{1},r.y{1},imVec{1},r.bgImg{1});
                    reshapeSize = [size(r.images{1},1),size(r.images{1},2),size(r.images{1},4),size(r.images{1},5),size(r.images{1},6)];
                    r.fitImages{1}=reshape(fitVec,reshapeSize);
                    r.fitParams{1}=reshape(fp,7,size(r.images{1},4),size(r.images{1},5),size(r.images{1},6));
                    r.GOF{1}=reshape(gof,size(r.images{1},4),size(r.images{1},5),size(r.images{1},6));
                    atomNumVec=getAtomNumFromOD(r.fitParams{1}(2,:),r.fitParams{1}(5,:),r.fitParams{1}(6,:));
                    atomDensityVec=getAtomDensity(atomNumVec,[r.fitParams{1}(5,:);r.fitParams{1}(6,:)]);
                    r.atomNum{1}=reshape(atomNumVec,size(r.images{1},4),size(r.images{1},5),size(r.images{1},6));
                    r.atomDensity{1}=reshape(atomDensityVec,size(r.images{1},4),size(r.images{1},5),size(r.images{1},6));
                else
                    imVec{1}=reshape(r.images{1},size(r.images{1},1),size(r.images{1},2),size(r.images{1},3)*size(r.images{1},4)*size(r.images{1},5)*size(r.images{1},6)); %pixelfly imVec
                    [fp,gof,fitVec]=vec2DgaussFit(r.x{1},r.y{1},imVec{1},r.bgImg{1});
                    r.fitImages{1}=reshape(fitVec,size(r.images{1}));
                    r.fitParams{1}=reshape(fp,7,size(r.images{1},3),size(r.images{1},4),size(r.images{1},5),size(r.images{1},6));
                    r.GOF{1}=reshape(gof,size(r.images{1},3),size(r.images{1},4),size(r.images{1},5),size(r.images{1},6));
                    atomNumVec=getAtomNum(r.fitParams{1}(7,:));
                    atomDensityVec=getAtomDensity(atomNumVec,[r.fitParams{1}(5,:);r.fitParams{1}(6,:)]);
                    r.atomNum{1}=reshape(atomNumVec,size(r.images{1},3),size(r.images{1},4),size(r.images{1},5),size(r.images{1},6));
                    r.atomDensity{1}=reshape(atomDensityVec,size(r.images{1},3),size(r.images{1},4),size(r.images{1},5),size(r.images{1},6));
                end
                if p.calcTemp
                    obj.calcTemp(1);
                end
            end
            %fit pielflyTop
            if ~p.pfTopLiveMode
                imVec{2}=reshape(r.images{2},size(r.images{2},1),size(r.images{2},2),size(r.images{2},3)*size(r.images{2},4)*size(r.images{2},5)*size(r.images{2},6)); %pixelfly Top imVec
                r.y{2} = inst.cameras('pixelflyTop').y;
                r.x{2} = inst.cameras('pixelflyTop').x;
                [fp,gof,fitVec]=vec2DgaussFit(r.x{2},r.y{2},imVec{2},r.bgImg{2});
                r.fitImages{2}=reshape(fitVec,size(r.images{2}));
                r.fitParams{2}=reshape(fp,7,size(r.images{2},3),size(r.images{2},4),size(r.images{2},5),size(r.images{2},6));
                r.GOF{1}=reshape(gof,size(r.images{2},3),size(r.images{2},4),size(r.images{2},5),size(r.images{2},6));
                atomNumVec=getAtomNum(r.fitParams{2}(7,:));
                atomDensityVec=getAtomDensity(atomNumVec,[r.fitParams{2}(5,:);r.fitParams{2}(6,:)]);
                r.atomNum{2}=reshape(atomNumVec,size(r.images{2},3),size(r.images{2},4),size(r.images{2},5),size(r.images{2},6));
                r.atomDensity{2}=reshape(atomDensityVec,size(r.images{2},3),size(r.images{2},4),size(r.images{2},5),size(r.images{2},6));
                if p.calcTemp
                    obj.calcTemp(2);
                end
            end
        end
        
        function outTable=toTable(obj)
            outTable=table();
            outTable.name=obj.name;
            if isempty(obj.seq)
                outTable.name='none';
            else
                vars={};
                
                for ind=1:length(obj.seq)
                    vars=horzcat(vars,obj.seq{ind}.toTable.Properties.VariableNames);
                end
%                 vars=unique(lower(vars));
                vars=unique(vars);
                vals=cell(length(obj.seq),length(vars));
                for ind=1:length(obj.seq)
                    for jnd=1:length(vars)
                        if any(strcmpi(vars(jnd),obj.seq{ind}.toTable.Properties.VariableNames))
                            name=vars(jnd);
                            name=name{1};
                            vals{ind,jnd}=obj.seq{ind}.toTable.(name);
                        else
                            vals{ind,jnd}=0;
                        end
                    end
                end
                outTable=cell2table(vals);
                outTable.Properties.VariableNames=vars;
            end
            
            
            
            
        end
        
        function switchBlocks(obj,pos1,pos2)
            temp=obj.seq{pos1};
            obj.seq{pos1}=obj.seq{pos2};
            obj.seq{pos2}=temp;
        end
        function checkSaturation(obj)
            global r
            global p
            r.satFlags{1} = zeros(size(r.images{1},3),size(r.images{1},4),size(r.images{1},5),size(r.images{1},6));
            if ~isempty(r.images{2})
                r.satFlags{2} = zeros(size(r.images{2},3),size(r.images{2},4),size(r.images{2},5),size(r.images{2},6));
                twoCams = 1;
            else
                twoCams = 0;
            end
            if ~isempty(p.loopVals)
                NInner = length(p.loopVals{1});
            if size(p.loopVals,2)~=1
                NOuter = length(p.loopVals{2});
            else
                NOuter=1;
                NoOuterFlag=1;
            end
            else
                NInner = 1;
                NOuter=1;
            end
            for ii = 1:p.picsPerStep
                for jj = 1:NOuter
                    for kk = 1:NInner
                        for nn = 1:p.NAverage
                           im = r.images{1}(:,:,ii,jj,kk,nn);
                           r.satFlags{1}(ii,jj,kk,nn) = double(any(im(:)>=16e3));
                           if twoCams~=0
                               im = r.images{2}(:,:,ii,jj,kk,nn);
                               r.satFlags{2}(ii,jj,kk,nn) = double(any(im(:)>=16e3)); 
                           end
                        end      
                    end    
                end     
            end
        end
    end
end
