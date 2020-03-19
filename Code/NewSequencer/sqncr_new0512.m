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
            global p;
            
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
            if nargin==2
                %this meens that a seq has been enterd, and you need to
                %atomize it, rathar then the "obj.seq"
                tmpSeq = varargin{1};
            else
                tmpSeq = obj.seq;
            end
            for ii=1:size(tmpSeq,1) % loop over all Blocks in seq
                if ii==1
                    tmpSeq{ii}.atomizeAll; %use atomizeAll function of Block calss to atomize Block.
                    fullseq = tmpSeq{ii}.b; %set atomized Blosk (stored in b) to fullseq
                else
                    tmpSeq{ii}.atomizeAll;%use atomizeAll function of Block calss to atomize Block.
                    fullseq=[fullseq;tmpSeq{ii}.b];%concatenate new atomized Blosk with fullseq
                end
            end
            %now move all asynchronous actions to the top of the sequence
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
            if nargin==1 %if no parameters are input, set both to NaN
                innerLoopVal=NaN;
                outerLoopVal=NaN;
            end
            if nargin==2 %if innerLoopVal in input, set only outerLoopVal to NaN
                outerLoopVal=NaN;
            end
            [syncSeq,asyncSeq]=obj.atomizeAndMerge; %generate full sequqence
            fullseq=[asyncSeq;syncSeq];%combine async and sync parts
            populatedSeq=obj.populateVars(fullseq,innerLoopVal,outerLoopVal); %populate value
            stepRes=obj.execute(populatedSeq); % and collect results
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
            % loop over fullSeq and varify all entries are 1x1 cell array.
            for ii = 1:size(fullSeq,1)
                if strcmpi(class(fullSeq{ii}),'block')
                    fullSeq{ii} = fullSeq{ii}.b;
                end
            end
            found=[0,0]; %a flag array indicating whethr INNERLOOPVAR and OUTERLOOPVAR were found
            for ii=1:size(fullSeq,1) % loop over fullSeq
                %index in fullSeq{ii} where p.INNERLOOPVAR could be found.
                innerloopInd = find(strcmp(cellfun(@(x) num2str(x),fullSeq{ii},'UniformOutput',false),num2str(p.INNERLOOPVAR)));           
                if ~isempty(innerloopInd) %if p.INNERLOOPVAR was found
                    if isnan(innerLoopVal) %if innerLoopVal = Nan, but p.INNERLOOPVAR was found, report error
                        error('No inner loop parameter passed but INNERLOOPVAR placeholder exists in sequence');
                    end
                    if length(innerloopInd)>1 %if more then one p.INNERLOOPVAR was found, report error
                        error('There can be only one InnerLoopVar per line!')
                    end
                    found(1)=1;%set INNERLOOPVAR flag to 1
                    fullSeq{ii}{innerloopInd}=innerLoopVal;%replace p.INNERLOOPVAR with innerLoopVal
                end
                %repeat fot OUTERLOOPVAR
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
                end
            end
            if (found(1)==0 && ~isnan(innerLoopVal)) %if found flag is 0, but innerLoopVal~=nan, report an error
                error('Inner loop values passed but no placeholder value found!. check sequence');
            elseif (found(2)==0 && ~isnan(outerLoopVal))%if found flag is 0, but outerLoopVal~=nan, report an error
                error('Outer loop values passed but no placeholder value found!. check sequence');
            end
            populatedSeq=fullSeq; %return populated seq.
        end
        function asyncRes=executeAsync(obj,seq)
            global inst
            global p  
            if p.hasScopResults==1%prepare scope (set to single shot)
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
            for ii=1:size(seq,1)
                switch seq{ii}{1}
                    case 'setDDSfreq'
                        channelInd = find(strcmpi(seq{ii},'channel')); %DDS chanel, 1-4
                        channelVal = seq{ii}{channelInd+1};
                        freqInd = find(strcmpi(seq{ii},'freq'));
                        freqVal = seq{ii}{freqInd+1};
                        inst.DDS.setFreq(channelVal,freqVal,0,0)
                        asyncRes=1;
                    case 'setSynthHDFreq'
                        channelInd = find(strcmpi(seq{ii},'channel')); %DDS chanel, 'a',or 'b'
                        if ~isempty(channelInd)
                            channelVal = seq{ii}{channelInd+1};
                        else
                            channelVal = 'a';
                        end
                        freqInd = find(strcmpi(seq{ii},'freq'));
                        freqVal = seq{ii}{freqInd+1};
                        inst.synthHD.setFreq(freqVal,channelVal);
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
                                inst.Lasers(lower(laserName)).setEventData(freq,evtNum,1,FeedFord); %cooling uses mode 1, i.e invert off and int vco on          
                            elseif strcmpi(laserName,'repump')
                                freq = repumpDetToFreq(Detuning,N);
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
                                if isfield(inst,'BiasFieldManager')
                                    inst.BiasFieldManager.abortTrigger
                                end
                                inst.BiasCoils{2}.setCurrent(2,currentVal);
                            case 'y'
                                if isfield(inst,'BiasFieldManager')
                                    inst.BiasFieldManager.abortTrigger
                                end
                                inst.BiasCoils{1}.setCurrent(1,currentVal);
                            case 'z'
                                if isfield(inst,'BiasFieldManager')
                                    inst.BiasFieldManager.abortTrigger
                                end
                                if ~isfield(p,'zBiasLocationPSU')
                                    inst.BiasCoils{1}.setCurrent(2,currentVal); %z
                                elseif strcmp(p.zBiasLocationPSU,'2,1')
                                    inst.BiasCoils{2}.setCurrent(1,currentVal); %z
                                else
                                    inst.BiasCoils{1}.setCurrent(2,currentVal); %z
                                end
                        end
                        if isfield(inst,'BiasFieldManager')
                            inst.BiasFieldManager.initTrigger;
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
                    case 'setRigolBurstMode'
                        asyncRes=1;
                        %sets the burst mode of the rigol FG
                        chanInd = find(strcmpi(seq{ii},'channel')); %1, 2 or 'both'
                        if isempty(chanInd)
                            error('no channle in ''setRigolBurstMode''');
                        end
                        chanVal = seq{ii}{chanInd+1};
                        modeInd = find(strcmpi(seq{ii},'mode')); %'NORMal', or 'GATed'.
                        if isempty(modeInd)
                            error('no mode in ''setRigolBurstMode''');
                        end
                        modeVal = seq{ii}{modeInd+1};
                        if strcmpi(chanVal,'both')
                            inst.rigol1.setBurstMode(1,modeVal);
                            inst.rigol1.setBurstMode(2,modeVal);
                        elseif chanVal==1
                            inst.rigol1.setBurstMode(1,modeVal);
                        elseif chanVal==2
                            inst.rigol1.setBurstMode(2,modeVal);
                        else
                            error('bad channle settings in async action: setRigolBurstMode');
                        end
                    case 'setRigolBurstState'
                        asyncRes=1;
                        %sets the burst mode of the rigol FG
                        chanInd = find(strcmpi(seq{ii},'channel')); %1, 2 or 'both'
                        if isempty(chanInd)
                            error('no channle in ''setRigolBurstState''');
                        end
                        chanVal = seq{ii}{chanInd+1};
                        StateInd = find(strcmpi(seq{ii},'state')); %'on','off',1, or 0.
                        if isempty(StateInd)
                            error('no state in ''setRigolBurstState''');
                        end
                        stateVal = seq{ii}{StateInd+1};
                        if strcmpi(chanVal,'both')
                            inst.rigol1.setBurstState(1,stateVal);
                            inst.rigol1.setBurstState(2,stateVal);
                        elseif chanVal==1
                            inst.rigol1.setBurstState(1,stateVal);
                        elseif chanVal==2
                            inst.rigol1.setBurstState(2,modeVal);
                        else
                            error('bad channle settings in async action: setRigolBurstMode');
                        end
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
                        updateIds;
                        asyncRes=1;
                    case 'setProbeDetuning'
                        detInd= find(strcmpi(seq{ii},'detuning'));
                        if isempty(detInd)
                            error('no detuning found in setProbeDetuning!')
                        end
                        detuningVal = seq{ii}{detInd+1};
                        fromInd= find(strcmpi(seq{ii},'from'));
                        if isempty(fromInd)
                            fromVal = 2;
                        else
                            fromVal = seq{ii}{fromInd+1};
                        end
                        toInd= find(strcmpi(seq{ii},'to'));
                        if isempty(toInd)
                            toVal = 3;
                        else
                            toVal = seq{ii}{toInd+1};
                        end
                        
                        multiplierInd= find(strcmpi(seq{ii},'multiplier'));
                        if isempty(multiplierInd)
                            multiplierVal = 8;
                        else
                            multiplierVal = seq{ii}{multiplierInd+1};
                        end
                        inst.DDS.setFreq(2,probeDetToFreq(detuningVal,multiplierVal,fromVal,toVal));
                        if inst.DDS.getFreq(4)~=200
                            inst.DDS.setFreq(4,200);
                        end
                        asyncRes=1;
                    case 'setBiasPulse'
                        biasFieldInd= find(strcmpi(seq{ii},'BiasField'));
                        if isempty(biasFieldInd)
                            error('no BiasFiled found in setBiasPulse!')
                        end
                        biasVal= seq{ii}{biasFieldInd+1};
                        MagneticPulseTimeInd= find(strcmpi(seq{ii},'MagneticPulseTime'));
                        if isempty(MagneticPulseTimeInd)
                            error('no MagneticPulseTime found in setBiasPulse!')
                        end
                        MagneticPulseTimeVal= seq{ii}{MagneticPulseTimeInd+1};
                        inst.BiasFieldManager.configBpulse([NaN,biasVal,NaN],MagneticPulseTimeVal);
                        asyncRes=1;
                    case 'setIceEvent'
                        lockFreqInd = find(strcmpi(seq{ii},'lockFreq'));
                        if ~isempty(lockFreqInd)
                            lockFreqVal = seq{ii}{lockFreqInd+1};
                        else
                            error('must have lockFreq in setIceEvent')
                        end
                        evtIDInd = find(strcmpi(seq{ii},'evtID'));
                        if isempty(evtIDInd)
                            evtID = 2;
                        else
                            evtID = seq{ii}{evtIDInd+1};
                        end
                        inst.Lasers('cooling').setEventData(lockFreqVal,evtID,3,0);
                        asyncRes=1;
                    case 'setZeemanPumpPower'
                        valueInd = find(strcmpi(seq{ii},'value'));
                        if ~isempty(valueInd)
                            Value = seq{ii}{valueInd+1};
                        else
                            error('setZeemanPumpPower must have Value')
                        end
                        NDInd = find(strcmpi(seq{ii},'ND'));
                        if ~isempty(NDInd)
                            ND = seq{ii}{NDInd+1};
                        else
                            ND = [];
                        end
                        AOVolt = zeemanPumpPower2AO(Value,ND);
                        inst.KeithleyPSU.setVoltage(2,AOVolt)
                        if ii==length(seq)
                            pause(1.5)
                            fprintf('KeithleyPSU set Voltage: pausing for 1.5 seconds to let voltage settle\n')
                        else
                            pauseFlag = 1;
                            for ll = 1:length(seq)-ii
                                if strcmpi(seq{ll+ii}{1},'setZeemanRepumpPower')||strcmpi(seq{ll+ii}{1},'setZeemanPumpPower')
                                    pauseFlag = 0;
                                end
                            end
                            if pauseFlag==1
                                pause(1.5)
                                fprintf('KeithleyPSU set Voltage: pausing for 1.5 seconds to let voltage settle\n')
                            end
                        end
                        asyncRes=1;
                    case'setZeemanRepumpPower'
                        valueInd = find(strcmpi(seq{ii},'value'));
                        if ~isempty(valueInd)
                            Value = seq{ii}{valueInd+1};
                        else
                            error('setZeemanRepumpPower must have Value')
                        end
                        NDInd = find(strcmpi(seq{ii},'ND'));
                        if ~isempty(NDInd)
                            ND = seq{ii}{NDInd+1};
                        else
                            ND = [];
                        end
                        AOVolt = zeemanRepumpPower2AO(Value,ND);
                        inst.KeithleyPSU.setVoltage(1,AOVolt)
                        if ii==length(seq)
                            pause(1.5)
                            fprintf('KeithleyPSU set Voltage: pausing for 1.5 seconds to let voltage settle\n')
                        else
                            pauseFlag = 1;
                            for ll = 1:length(seq)-ii
                                if strcmpi(seq{ll+ii}{1},'setZeemanRepumpPower')||strcmpi(seq{ll+ii}{1},'setZeemanPumpPower')
                                    pauseFlag = 0;
                                end
                            end
                            if pauseFlag==1
                                pause(1.5)
                                fprintf('KeithleyPSU set Voltage: pausing for 1.5 seconds to let voltage settle\n')
                            end
                        end
                        asyncRes=1;
                    case 'setZeemanRepumpDetuning'
                        valueInd = find(strcmpi(seq{ii},'value'));
                        if ~isempty(valueInd)
                            Value = seq{ii}{valueInd+1};
                        else
                            error('setZeemanRepumpDetuning must have Value')
                        end
                        freq=repumpDetToFreq(Value,64);
                        inst.Lasers('repump').setEventData(freq,2,15,0);
                        fprintf('Setting repump detuning in EvtNum 2 to %.2f MHz (%.1f Gamma detuned) with multiplier 64 (Evt Mode 15)\n',freq,Value/p.consts.Gamma);
                        asyncRes=1;
                    case 'configDoubleBPulse'
                        
                        firstBvalueInd = find(strcmpi(seq{ii},'firstB'));
                        if ~isempty(firstBvalueInd)
                            firstB= seq{ii}{firstBvalueInd+1};
                        else
                            firstB =[nan,nan,-0.01].*inst.BiasFieldManager.conversionFactors;
                        end
                        secondBvalueInd = find(strcmpi(seq{ii},'secondB'));
                        if ~isempty(secondBvalueInd )
                            secondB= seq{ii}{secondBvalueInd +1};
                        else
                            secondB =[p.xJumpBField,p.BiasField,p.zJumpBField];
                        end
                        directionInd=find(strcmpi(seq{ii},'direction'));
                        if ~isempty(directionInd)
                            direction= seq{ii}{directionInd+1};
                        end
                        scannedVarInd=find(strcmpi(seq{ii},'scannedVal'));
                        if ~isempty(scannedVarInd)
                            scannedVal= seq{ii}{scannedVarInd+1};
                        end
                        t1valueInd = find(strcmpi(seq{ii},'t1'));
                        if ~isempty(t1valueInd )
                            t1= seq{ii}{t1valueInd +1};
                        else
                            t1 =2e3;
                        end
                        t2valueInd = find(strcmpi(seq{ii},'t2'));
                        if ~isempty(t2valueInd )
                            t2= seq{ii}{t2valueInd +1};
                        else
                            t2 =p.MagneticPulseTime;
                        end
                        fprintf('configuring a double B pulse for zeeman pumping. init B: [%.3f,%.3f,%.3f], finalB: [%.3f,%.3f,%.3f]\n',firstB,secondB);
                        fprintf('configuring a double B pulse for zeeman pumping. t1: %.1f, t2: %.1f\n',t1,t2);
                        if exist('direction')
                            switch lower(direction)
                                case 'x'
                                    secondB(1)=scannedVal;
                                case 'y'
                                    secondB(2)=scannedVal;
                                case 'z'
                                    secondB(3)=scannedVal;
                            end
                        end
                        inst.BiasFieldManager.configDoubleBpulse(firstB,secondB,t1,t2);
                        asyncRes=1;
                    case 'setBiasE'
                        ExInd = find(strcmpi(seq{ii},'Ex'));
                        EyInd = find(strcmpi(seq{ii},'Ey'));
                        EzInd = find(strcmpi(seq{ii},'Ez'));                        
                        if ~isempty(ExInd)
                            Ex= seq{ii}{ExInd+1};
                            inst.BiasE.setXField(Ex);
                        end
                        if ~isempty(EyInd)
                            Ey= seq{ii}{EyInd+1};
                            inst.BiasE.setYField(Ey);
                        end
                        if ~isempty(EzInd)
                            Ez= seq{ii}{EzInd+1};
                            inst.BiasE.setZField(Ez);
                        end
                        asyncRes=1;
                    case 'setResonatorPercent'
                        PercentInd = find(strcmpi(seq{ii},'value'));
                        value = seq{ii}{PercentInd +1};
                        inst.m2.setResonatorPercentage(value);
                        pause(0.05);
                        asyncRes=1;
                    case 'setScopeTimeBase'
                        tbInd= find(strcmpi(seq{ii},'value'));
                        value = seq{ii}{tbInd +1};
                        inst.scopes{1}.setTimebase(value);
                        inst.scopes{1}.setDelay(-value/2);
                        asyncRes=1;
                    case 'configRigolRampBurst'
                        freqInd= find(strcmpi(seq{ii},'freq'));
                        freq = seq{ii}{freqInd +1};
                        ampInd= find(strcmpi(seq{ii},'amp'));
                        amp = seq{ii}{ampInd +1};
                        offsetInd= find(strcmpi(seq{ii},'offset'));
                        offset = seq{ii}{offsetInd +1};
                        phaseInd= find(strcmpi(seq{ii},'phase'));
                        phase = seq{ii}{phaseInd +1};
                        symmInd= find(strcmpi(seq{ii},'symm'));
                        symm = seq{ii}{symmInd +1};
                        chanInd= find(strcmpi(seq{ii},'chan'));
                        chan = seq{ii}{chanInd +1};
                        nCycInd= find(strcmpi(seq{ii},'nCyc'));
                        nCyc = seq{ii}{nCycInd +1};
                        inst.rigol1.configRampBuest(chan,freq,amp,offset,phase,symm,nCyc)
                        asyncRes=1;                       
                    case 'setKDCAngle'
                        angleInd= find(strcmpi(seq{ii},'angle'));
                        angle = seq{ii}{angleInd +1};
                        inst.kdc.setAngle(angle);
                        asyncRes=1;
                    case 'setControlPower' %sets the control power, in mW
                        powerInd= find(strcmpi(seq{ii},'power'));
                        power = seq{ii}{powerInd +1};
                        NDInd= find(strcmpi(seq{ii},'ND'));
                        if isempty(NDInd)
                            ND = [];
                        else
                            ND = seq{ii}{NDInd +1};
                        end
                        inst.kdc.setAngle(controlPower2angle(power,ND));
                        asyncRes=1;
                    otherwise
                        error('%s no such async action',seq{ii}{1});
                end
            end
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
                %                 if ii == 11
                %                 disp(ii)
                %                 end
                if strcmpi(seq{ii}{1},'pause')
                    continue
                end
                
                %                 if strcmpi(seq{ii}{1},'forStart')
                %                     seq{ii}{end+1}='channel';
                %                     seq{ii}{end+1}='forStart';
                %                     seq{ii}{end+1}='duration';
                %                     seq{ii}{end+1}=0;
                %                     seq{ii}{end+1}='value';
                %                     seq{ii}{end+1}=0;
                %                 end
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
                if strcmpi(seq{ii}{1},'setRepumpDetuning')
                    seq{ii}{end+1}='channel';
                    seq{ii}{end+1} = 'RPMPVCO';
                end
                if strcmpi(seq{ii}{1},'setImagingDetuning')
                    seq{ii}{end+1}='channel';
                    seq{ii}{end+1} = 'ImagingVCO';
                end
                
                if strcmpi(seq{ii}{1},'setRepumpPower')
                    seq{ii}{end+1}='channel';
                    seq{ii}{end+1} = 'RPMPVVAN';
                end
                if strcmpi(seq{ii}{1},'setCoolingPower')
                    seq{ii}{end+1}='channel';
                    seq{ii}{end+1} = 'COOLVVAN';
                end
                
                if strcmpi(seq{ii}{1},'setImagingPower')
                    seq{ii}{end+1}='channel';
                    seq{ii}{end+1} = 'ImagingVVAN';
                end
                if strcmpi(seq{ii}{1},'set480ControlPower')
                    seq{ii}{end+1}='channel';
                    seq{ii}{end+1} = 'ImagingVVAN';
                end
                if strcmpi(seq{ii}{1},'setBlueDTPower')
                    seq{ii}{end+1}='channel';
                    seq{ii}{end+1} = 'BlueDTVVAN';
                end
                if strcmpi(seq{ii}{1},'setPurpleDTPower')
                    seq{ii}{end+1}='channel';
                    seq{ii}{end+1} = 'PurpleDTVVAN';
                end
                if strcmpi(seq{ii}{1},'set776ControlPower')
                    seq{ii}{end+1}='channel';
                    seq{ii}{end+1} = 'ImagingVVAN';
                end
                if strcmpi(seq{ii}{1},'setProbePower')
                    seq{ii}{end+1}='channel';
                    seq{ii}{end+1} = 'PRBVVAN';
                end
                if strcmpi(seq{ii}{1},'setCircCurrent')
                    seq{ii}{end+1}='channel';
                    seq{ii}{end+1} = 'CircCoil';
                end
                if strcmpi(seq{ii}{1},'startCoolingPowerRamp')
                    seq{ii}{end+1}='channel';
                    seq{ii}{end+1} = 'COOLVVAN';
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
                        %                     elseif strcmpi(channelName,'ImagingVVAN') && strcmpi(seq{ii}{1},'setAnalogChannel')
                        %                         valueInd = find(strcmpi(seq{ii},'value'));
                        %                         try
                        %                             seq{ii}{valueInd+1}=ImagingPower2AO(seq{ii}{valueInd+1});
                        %                         catch err
                        %                             error('%s',err.message)
                        %                         end
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
                elseif seq{ii}{InvertedInd+1}==1
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
                            %                             if width==0
                            if ~Inverted
                                width=-1;
                            end
                            %                             end
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
                        %                         currentPulse.rampFinalVal=round(2^15/10 * CoolingPower2AO(seq{ii}{currInd+1}));
                        currentPulse.rampFinalVal=round(2^15/10 * seq{ii}{currInd+1});
                        %                     case 'forStart'
                        %                         currentPulse=AnalogPulse('forStart',startTime,0,Value);
                    case 'forEnd'
                        %currentPulse=AnalogPulse('forEnd',startTime,0,Value);
                        currentPulse=AnalogPulse('forEnd',startTime,0,Value+1); %chnged from Value to Value+1 on 06/10/19 because the dorN parameter in the pigeon shows Value-1. If we fix the pigeon for mechanism, we should revert this back.
                    case 'setCoolingDetuning'
                        %Changed on 27/12/18 by L.D, because the cooling
                        %AOM swiched to a -1,-1 order and to a 100-200 vco
                        det = Value;
                        %                         VCOFreq = 110-(p.coolingLockDet-det)/2;
                        %                         minDet = (75.83-110)*2+p.coolingLockDet;
                        %                         maxDet = (154.65-110)*2+p.coolingLockDet;
                        %                         if VCOFreq<75.83
                        %                             warning(sprintf('desired cooling detuning can''t be set. Minimal detuning of %0.2f set',minDet))
                        %                             VCOFreq = 75.84;
                        %                         elseif VCOFreq>154.56
                        %                             warning(sprintf('desired cooling detuning can''t be set. Maximal detuning of %0.2f set',maxDet))
                        %                             VCOFreq = 154.55;
                        %                         end
                        VCOFreq = 110+(p.coolingLockDet-det)/2;
                        minDet = (110-93.77)*2+p.coolingLockDet;
                        maxDet = (110-201.14)*2+p.coolingLockDet;
                        if VCOFreq<93.77
                            warning(sprintf('desired cooling detuning can''t be set. Minimal detuning of %0.2f set',minDet))
                            VCOFreq = 93.77;
                        elseif VCOFreq>201.14
                            warning(sprintf('desired cooling detuning can''t be set. Maximal detuning of %0.2f set',maxDet))
                            VCOFreq = 201.14;
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
                        AOVolt = ImagingVCOFreq2AO(imagingDetToFreq(Value));
                        currentPulse=AnalogPulse(p.ct.PhysicalName{channelName},startTime,width,AOVolt);
                    case 'setImagingPower'
                        AOVolt = ImagingPower2AO(Value);
                        currentPulse=AnalogPulse(p.ct.PhysicalName{channelName},startTime,width,AOVolt);
                    case 'setRepumpPower'
                        AOVolt = repumpPower2AO(Value);
                        currentPulse=AnalogPulse(p.ct.PhysicalName{channelName},startTime,width,AOVolt);
                    case 'setCoolingPower'
                        AOVolt = CoolingPower2AO(Value);
                        currentPulse=AnalogPulse(p.ct.PhysicalName{channelName},startTime,width,AOVolt);
                    case 'setProbePower'
                        AOVolt = ProbePower2AO_withND(Value,p.probeNDList);
                        currentPulse=AnalogPulse(p.ct.PhysicalName{channelName},startTime,width,AOVolt);
                    case 'set480ControlPower'
                        AOVolt = Control480Power2AO(Value);
                        currentPulse=AnalogPulse(p.ct.PhysicalName{channelName},startTime,width,AOVolt);
                    case 'set776ControlPower'
                        if isfield(p,'Control776NDList')
                            ndlist = p.Control776NDList;
                        else
                            ndlist = [];
                        end
                        AOVolt = Control776Power2AO(Value,ndlist);
                        currentPulse=AnalogPulse(p.ct.PhysicalName{channelName},startTime,width,AOVolt);
                    case 'setBlueDTPower'
                        AOVolt = BlueDTPower2AO(Value);
                        currentPulse=AnalogPulse(p.ct.PhysicalName{channelName},startTime,width,AOVolt);
                    case 'setPurpleDTPower'
                        AOVolt = PurpleDTPower2AO(Value);
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
            %we don't remember why this block below is here. it might be to
            %prevent pause actions from appearing at the end of a sequence
            %but we're not sure. 9/1/2019
            delayInd=find(strcmpi(seq{end},'start time'));
            if isempty(delayInd) && strcmpi(seq{end}{1},'pause')
                pauseInd=find(strcmpi(seq{end},'duration'));
                %                 delayInd=find(strcmpi(seq{end-1},'start time'));
                %                 pauseTime=(seq{end}{pauseInd+1}+seq{end-1}{delayInd+1})*1e-6;
                pauseTime=seq{end}{pauseInd+1}*1e-6;
            end
            
            if exist('FPGASeq','var')
                seqUpload(FPGASeq,p.DEBUG);
                if exist('pauseTime','var')
                    fprintf('Pausing for %.2f s for FPGA execution\n',pauseTime);
                    pause(pauseTime);
                else
                    %Changed by L.D on 26.3.19. We did not include the
                    %duration of the last action.
                    %                     pauseTime=seq{end}{delayInd+1}*1e-6+0.1;
                    %                     pauseTime=seq{end}{delayInd+1}*1e-6+0.1+width*1e-6;
                    %Changed by L.D on 18.09.19. removed the extra 100ms delay
                    pauseTime=seq{end}{delayInd+1}*1e-6+width*1e-6;
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
            if ~p.pfLiveMode
                r.bgImg{1}=inst.cameras('pixelfly').getImages(1);
            end
            if ~p.idsLiveMode
                r.bgImg{2}=inst.cameras('ids').getImages(1);
            end
            updatePixelfly();
            updateIds;
            p.s=origS;
        end
        function run(obj)
            global p
            global r
            global inst
            p.run_loop_ctr = p.run_loop_ctr +1;
            picsPerStep=p.picsPerStep;
            %setup bias magnetic field pulse, for zeeman pumping
            %set default value
            if ~isfield(p,'BiasField') && ~isfield(p,'biasField')
                p.BiasField=-0.5;
            end
            %to help with backwards compatibility with a different spelling.
            if isfield(p,'biasField')
                p.BiasField = p.biasField;
            end
            %to reduce time lag while looping (say during alignment), initiate pulses only if not looping,
            %or this is the first loop
            if ~p.loopingRun || p.run_loop_ctr == 1
                I = inst.BiasFieldManager.I; %get current currents
                B = inst.BiasFieldManager.I .*  inst.BiasFieldManager.conversionFactors;%convert to magnetic field
                B0 = p.B0; %magnetic field for 0 field on atoms
                firstB = [nan,nan,-0.01*inst.BiasFieldManager.conversionFactors(3)];%first field to jump. Only jump z
                BJump = B0; % init the jump as zero field.
                %check if there are set values for jump, and set to them
                if isfield(p,'xJumpBField')
                    BJump(1) = p.xJumpBField;
                end
                if isfield(p,'BiasField')
                    p.yJumpBField = p.BiasField;
                    fprintf('setting yJumpBField to be biasField\n')
                    BJump(2) = p.BiasField;
                elseif isfield(p,'yJumpBField')
                    BJump(2) = p.yJumpBField;
                end
                if isfield(p,'zJumpBField')
                    BJump(3) = p.zJumpBField;
                end
                %confige the magnetic pulse.
                if isfield(p,'p.ZeemanPumpTime') && p.ZeemanPumpTime>1e4
                    inst.BiasFieldManager.configDoubleBpulse(firstB,BJump,2e3,p.ZeemanPumpTime);
                elseif isfield(p,'MagneticPulseTime')
                    inst.BiasFieldManager.configDoubleBpulse(firstB,BJump,2e3,p.MagneticPulseTime);
                elseif any(contains(p.s.toTable.name,'LoadDipoleTrapAndPump'))
                    error('No Magnetic pulse configured while using LoadDipoleTrapAndPump');
                else
                    warning('No Magnetic pulse configured');
                end
            end
            loopVals=p.loopVals;
            tAll=tic;
            % check, if loopVals is empty, than set loopVals{1,2} to nan and Ninner and
            % Nouter to 1, else set according to parameters
            if isempty(p.loopVals) %no scaned parameters.
                NInner = 1; % run inner-loop only once
                loopVals{1} = nan; %set inner-loop vals to nan
                NOuter = 1;% run outer-loop only once
                loopVals{2} = nan;%set outer-loop vals to nan
            else %some parameters are scanned.
                NInner = length(loopVals{1});
                if size(p.loopVals,2)~=1 %check if there is also an outer parameter scan
                    NOuter = length(loopVals{2});
                else %set NOuter to one and rise the NoOuterFlag.
                    NOuter=1;
                    NoOuterFlag=1;
                end
                if NInner==0
                    error('Can''t run a loop on outer loop without inner loop!');
                end
            end
            % if needed, randomize loop vals
            if isfield(p,'randomizeLoopVals') && p.randomizeLoopVals
                r.runValsIdxMap{1}=randperm(length(loopVals{1})); %permute loopVals{1} randomly
                loopVals{1}=loopVals{1}(r.runValsIdxMap{1}); %get randomized loopVals{1}
                r.runValsMap{1}=loopVals{1}; %save as referance
                if ~exist('NoOuterFlag','var')%do also for loopVals{2}
                    r.runValsIdxMap{2}=randperm(length(loopVals{2}));
                    loopVals{2}=loopVals{2}(r.runValsIdxMap{2});
                    r.runValsMap{2}=loopVals{2};
                end
                disp('randomized run!');
            end
            stepCtr=1; %count steps, needed for partitioning the results of the tt. Should change soon (05/12/19)
            %run settling loop, te warm up the system
            if isfield(p,'runSettlingLoop') && p.runSettlingLoop
                fprintf('running sequence %d times to settle the system\n',p.settlingStepN)
                for pp = 1:p.settlingStepN %run first step for settlingStepN times
                    obj.runStep(loopVals{1}(1),loopVals{2}(1)); 
                end
            end
            %loop over outer, inner and avarage loops
            for ii=1:NOuter
                for jj =1:NInner
                    for kk=1:p.NAverage
                        tStep=tic;
                        %t is previus step time, if dose not exist, set to 0
                        if ~exist('t')
                            t=0;
                        end
                        fprintf('Starting step %d out of %d. Averaging step #%d. Previous step took %.2f s\n',(ii-1)*NInner+jj,NInner*NOuter,kk,t)
                        % if the step counter is 1, and a tt dump
                        % measurement is performed, init a new dump file.
                        if stepCtr==1 && p.ttDumpMeasurement
                            r.fileNames={}; %reset the file names cell array
                            r.fileNames{end+1}=fullfile(getCurrentSaveFolder,getNextDumpFileName(getCurrentSaveFolder)); %set first file name
                            inst.dumpMeas=TTDump(inst.tt,r.fileNames{1},1e9,[1,2,3]); %start ttDump measurement
                            fprintf('pausing 0.1s for tt dump file creation (var loop)\n');
                            pause(0.1);
                        end
                        % run the step with the current loop parameters % (nan is no loop params exist)
                        if exist('NoOuterFlag','var')
                            obj.runStep(loopVals{1}(jj));
                        else
                            obj.runStep(loopVals{1}(jj),loopVals{2}(ii));
                        end
                        obj.obtainRes(ii,jj,kk,NOuter,NInner,stepCtr);
                        stepCtr=stepCtr+1;
                        fprintf('pausing %.2f between run steps\n',p.pauseBetweenRunSteps);
                        pause(p.pauseBetweenRunSteps);
                        t=toc(tStep);
                        fprintf('Done step %d out of %d in %.2f s\n',(ii-1)*NInner+jj,NInner*NOuter,t);
                    end
                end
                backupSave; %run backupSave between outer-loops. In practice, this is rarely used.
            end
            t2=toc(tAll);
            fprintf('Run completed. %d steps in %.2f seconds\n',NInner*NOuter,t2);
            % to keep dump files from getting too large, we split them
            % using cyclesPerRun
            if p.ttDumpMeasurement && mod(stepCtr-1,p.cyclesPerRun+1)~=0
                inst.tt.sync();
                inst.dumpMeas.stop;
            end
            % performe automated post processing (fitAll). Mainly fit images
            if p.postprocessing       
                fprintf('Starting post processing.\n');
                tpost=tic;
                obj.fitAll
                t=toc(tpost);
                fprintf('Post processing finished in t=%.2f s.\n',t);
            end
            tsave=tic;
            %save results, p and r only
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
            if ~p.pfLiveMode
                if isfield(inst,'cameras')
                    r.y{1} = inst.cameras('pixelfly').y;
                    r.x{1} = inst.cameras('pixelfly').x;
                else
                    scale = 8.5575e-06;
                    r.y{1} = (1:size(r.images{1},1))*scale;
                    r.x{1} = (1:size(r.images{1},2))*scale;
                end
                if p.absImg{1}==1
                    if size(r.images{1},3)~=2
                        error('p.picsPerStep must be 2 for absorption image');
                    end
                    [ims1,ims2] = extractArray(r.images{1},3); %extract the 1st and 2nd images
                    r.normIms{1} = (ims2-200)./(ims1-200); %200 is the camera dark count
                    imVec{1} = r.normIms{1}(:,:,:);
                    xCents = ones(size(imVec,3));
                    yCents = ones(size(imVec,3));
                    if isfield(p,'FitPos')
                        xCents = p.FitPos{1}(1);
                        yCents = p.FitPos{1}(2);
                    else
                        [xCents,yCents] = findCents(imVec{1});
                    end
                    scale = r.y{1}(2)-r.y{1}(1);
                    if ~isfield(p,'fitWidthHight')
                        [xWidths,yWidths] = getAbsImageWidth(imVec{1},'scale',scale);
                    else
                        xWidths = p.fitWidthHight(1);
                        yWidths = p.fitWidthHight(2);
                    end
                    [fp,gof,fitVec] = vecAbsImFit(r.x{1},r.y{1},r.normIms{1}(:,:,:),xCents*scale,yCents*scale,xWidths,yWidths);
                    reshapeSize = [size(r.images{1},1),size(r.images{1},2),size(r.images{1},4),size(r.images{1},5),size(r.images{1},6)];
                    r.fitImages{1}=reshape(fitVec,reshapeSize);
                    %                     r.fitParams{1}=reshape(fp,7,size(r.images{1},4),size(r.images{1},5),size(r.images{1},6));
                    r.fitParams{1}=reshape(fp,6,size(r.images{1},4),size(r.images{1},5),size(r.images{1},6));
                    r.GOF{1}=reshape(gof,size(r.images{1},4),size(r.images{1},5),size(r.images{1},6));
                    atomNumVec=getAtomNumFromOD(r.fitParams{1}(2,:),r.fitParams{1}(5,:),r.fitParams{1}(6,:),0);
                    atomDensityVec=getAtomDensity(atomNumVec,[r.fitParams{1}(5,:);r.fitParams{1}(6,:)]);
                    r.atomNum{1}=reshape(atomNumVec,size(r.images{1},4),size(r.images{1},5),size(r.images{1},6));
                    r.atomDensity{1}=reshape(atomDensityVec,size(r.images{1},4),size(r.images{1},5),size(r.images{1},6));
                else
                    imVec{1}=reshape(r.images{1},size(r.images{1},1),size(r.images{1},2),size(r.images{1},3)*size(r.images{1},4)*size(r.images{1},5)*size(r.images{1},6)); %pixelfly imVec
                    if isfield(p,'FitPos')
                        [fp,gof,fitVec]=vec2DgaussFit(r.x{1},r.y{1},imVec{1},r.bgImg{1},p.FitPos{1}(1),p.FitPos{1}(2));
                    else
                        [fp,gof,fitVec]=vec2DgaussFit(r.x{1},r.y{1},imVec{1},r.bgImg{1});
                    end
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
            if ~p.idsLiveMode
                imVec{2}=reshape(r.images{2},size(r.images{2},1),size(r.images{2},2),size(r.images{2},3)*size(r.images{2},4)*size(r.images{2},5)*size(r.images{2},6)); %pixelfly Top imVec
                if isfield(inst,'cameras')
                    r.y{2} = inst.cameras('ids').y;
                    r.x{2} = inst.cameras('ids').x;
                else
                    scale = 8.5575e-06*2.2236;
                    r.y{2} = (1:size(r.images{2},1))*scale;
                    r.x{2} = (1:size(r.images{2},2))*scale;
                end
                if isfield(p,'FitPos')
                    [fp,gof,fitVec]=vec2DgaussFit(r.x{2},r.y{2},imVec{2},r.bgImg{2},p.FitPos{2}(1),p.FitPos{2}(2));
                else
                    [fp,gof,fitVec]=vec2DgaussFit(r.x{2},r.y{2},imVec{2},r.bgImg{2});
                end
                r.fitImages{2}=reshape(fitVec,size(r.images{2}));
                r.fitParams{2}=reshape(fp,7,size(r.images{2},3),size(r.images{2},4),size(r.images{2},5),size(r.images{2},6));
                r.GOF{1}=reshape(gof,size(r.images{2},3),size(r.images{2},4),size(r.images{2},5),size(r.images{2},6));
                atomNumVec=getAtomNum(r.fitParams{2}(7,:),'top');
                atomDensityVec=getAtomDensity(atomNumVec,[r.fitParams{2}(5,:);r.fitParams{2}(6,:)]);
                r.atomNum{2}=reshape(atomNumVec,size(r.images{2},3),size(r.images{2},4),size(r.images{2},5),size(r.images{2},6));
                r.atomDensity{2}=reshape(atomDensityVec,size(r.images{2},3),size(r.images{2},4),size(r.images{2},5),size(r.images{2},6));
                if p.calcTemp
                    obj.calcTemp(2);
                end
            end
        end
        function outTable=toTable(obj,seq)
            if nargin==1
                seq = obj.seq;
            end
            outTable=table();
            outTable.name=obj.name;
            if isempty(obj.seq)
                outTable.name='none';
            else
                vars={};
                blk = {};
                for ind=1:length(seq)
                    if ~strcmpi(class(seq{ind}),'Block')
                        blk{ind} = Block(seq{ind});
                    else
                        blk{ind} = seq{ind};
                    end
                    vars=horzcat(vars,blk{ind}.toTable.Properties.VariableNames);
                end
                %                 vars=unique(lower(vars));
                vars=unique(vars);
                vals=cell(length(seq),length(vars));
                for ind=1:length(seq)
                    for jnd=1:length(vars)
                        if any(strcmpi(vars(jnd),blk{ind}.toTable.Properties.VariableNames))
                            name=vars(jnd);
                            name=name{1};
                            vals{ind,jnd}=blk{ind}.toTable.(name);
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
        function obtainRes(obj,outInd,inInd,avgInd,NOuter,NInner,stepCtr)
            %this finction accesses the varius instroments and obtains the
            %measurement result. It then sets them in the proper place,
            %according to outInd,inInd,avgInd. %stepCtr is for tt dump
            %managment
            global p
            global r
            global inst
            ii = outInd;
            jj = inInd;
            kk = avgInd;
            picsPerStep = p.picsPerStep;
            if p.hasScopResults
                try
                    dat=inst.scopes{1}.getChannels(p.chanList);
                    digDat=inst.scopes{1}.getDigitalChannels;
                    if (ii==1 && jj==1 && kk==1)
                        r.scopeRes{1}=zeros(size(dat,1),size(dat,2),NOuter,NInner,p.NAverage);
                        r.scopeDigRes{1}=zeros(size(digDat,1),size(digDat,2),NOuter,NInner,p.NAverage);
                    end
                    r.scopeRes{1}(1:size(dat,1),1:size(dat,2),ii,jj,kk)=dat;
                    r.scopeDigRes{1}(1:size(digDat,1),1:size(digDat,2),ii,jj,kk)=digDat;
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
            if p.hasPicturesResults
                if picsPerStep~=1
                    if ~p.pfLiveMode
                        try
                            r.images{1}(:,:,:,ii,jj,kk)=inst.cameras('pixelfly').getImages(picsPerStep);
                        catch err
                            error(err.identifier,'can''t access pixelflyPlane. Check p.pfLiveMode\n%s',err.message);
                        end
                    end
                    if ~p.idsLiveMode
                        try
                            r.images{2}(:,:,:,ii,jj,kk)=inst.cameras('ids').getImages(picsPerStep);
                        catch err
                            error(err.identifier,'can''t access pixelflyPlane. Check p.pfLiveMode\n%s',err.message);
                        end
                    end
                else
                    if ~p.pfLiveMode
                        try
                            r.images{1}(:,:,1,ii,jj,kk)=inst.cameras('pixelfly').getImages(picsPerStep);
                        catch err
                            error(err.identifier,'can''t access pixelflyPlane. Check p.pfLiveMode\n%s',err.message);
                        end
                    end
                    if ~p.idsLiveMode
                        try
                            r.images{2}(:,:,1,ii,jj,kk)=inst.cameras('ids').getImages(picsPerStep);
                        catch err
                            error(err.identifier,'can''t access pixelflyPlane. Check p.pfLiveMode\n%s',err.message);
                        end
                    end
                end
            end
            if p.ttDumpMeasurement && mod(stepCtr,p.cyclesPerRun+1) ==0
                fprintf('pausing 0.3s for tt dump readout (var loop)\n');
                pause(0.3);
                inst.tt.sync; %added 4/9/19 after correspondance with the Igor from swabian
                inst.dumpMeas.stop;
                r.fileNames{end+1}=fullfile(getCurrentSaveFolder,getNextDumpFileName(getCurrentSaveFolder));
                idx=length(r.fileNames);
                if stepCtr~=(NOuter*NInner*p.NAverage)%was changed on 25/09/19 from stepCtr~=(NOuter*NInner*p.NAverage-1). This would open a new file at the end of the run.
                    inst.dumpMeas=TTDump(inst.tt,r.fileNames{idx},1e9,[1,2,3]);
                end
            end
        end
    end
end
