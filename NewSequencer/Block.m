classdef Block < matlab.mixin.CustomDisplay &handle
    %parent class for a block
    
    properties
        b
        name
        atomic={'setImagingDetuning','setCoolingDetuning','setRepumpDetuning','pause',...
            'setDigitalChannel','setAnalogChannel','GenPause','startAnalogRamp','setCircCurrent'...
            ,'startCoolingPowerRamp','forStart','forEnd'};
        compound={'TakeAbsPic','TrigScope','TakePicForMWSpectro','Load MOT'...
            ,'Release MOT','ToF','TakePic','bgimg','Reload MOT','MOTblink','setAHH','endOfSeqToF'...
            ,'forBlock','LoadDipoleTrap'};
        async={'SetMWFreq','SetupDDSSweepCentSpan','SetupDDSSweepUpDown',...
            'setDDSfreq','setHH','getWLMdata','updateCams','Live Cameras'...
            ,'setICEDetuning','matlabPause','setICEFreq','setRigolModParams'...
            ,'setRigolDC','setRigolGateMode','setCamExp'};        
    end
    
    methods
        function obj=Block(inputSeq,name)
            obj.atomic=[obj.atomic,obj.async]; %update the list of atomic actions so that each async action is also atomic
            
            if nargin==0
                obj.b={};
            end
            if nargin==1
                obj.name='';
            end
            if nargin==2
                obj.name=name;
            end
            if nargin>0
                if size(inputSeq,1)==1
                    if iscell(inputSeq)
                        if ~iscell(inputSeq{1})
                            inputSeq={inputSeq};
                        end
                        %                     if size(inputSeq,1)~=1
                        %                         inputSeq=inputSeq';
                        %                     end
                        %                     obj.b{end+1}=inputSeq;
                        obj.b=inputSeq;
                        obj.name=inputSeq{1}{1};
                        
                        
                        %                     obj.b=inputSeq;
                        
                    else
                        obj.b{end+1}={inputSeq};
                        obj.name=inputSeq;
                    end
                else
                    if ~all(cellfun(@(x) mod(size(x,2)-1,2)==0,inputSeq))
                        error('All sequence inputs must by key-value pairs')
                    end
                    obj.b=inputSeq;
                    obj.name='';
                end
                
            end
        end
        %             for ii=1:length(obj.b)
        %                 obj.isAtomic(obj.b(ii))
        %             end
        
        function setInnerParameter(obj,parameterName)
            %             paramIndex=find(strcmp(cellfun(@(x) num2str(x),fullSeq{ii},'UniformOutput',false),parameterName));
            obj.b
        end
        
        function setOuterParameter(obj,parameterName)
            obj.b
        end
        function [bool,listBool]=isAsync(obj,action)
            %bool is a boolean indicating if ALL actions are Asyncronous.
            %listBool gives indices where async actions live.
            if isempty(action)
                bool=0;
            end
            if strcmpi('cell',class(action))
                %                 if strcmpi('cell',class(action))
                if size(action,1)==1
                    if any(strcmpi(action{1}{1},obj.async))
                        bool=1;
                    else
                        bool=0;
                    end
                else
                    for ii=1:size(action,1)
                        bool(ii)= obj.isAsync(action{ii}{1});
                        
                    end
                    listBool=bool;
                    bool=all(bool);
                end
            elseif strcmpi('char',class(action))
                if any(strcmpi(action,obj.async))
                    bool=1;
                else
                    bool=0;
                end
            end
            
            
        end
        function bool=isAtomic(obj,action)
            if strcmpi('cell',class(action))
                if size(action,1)==1
                    
                    if class(action{1})=='cell' %this is a hack to make it work. we aren't sure where we are going wrong. if this block does not exist, we cannot add an atomic action as a first action
                        action=action{1};
                    end
                    
                    if any(strcmpi(action{1},obj.atomic))
                        bool=1;
                    else
                        bool=0;
                    end
                else
                    for ii=1:size(action,1)
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
            if obj.isAtomic(action) && ~any(strcmpi(action,'duration'))
                error('action must have a duration!');
            end
            
            if nargin==2
                if isempty(obj.b)
                    obj.b={action};
                else
                    obj.b{end+1,:}=action;
                end
                if isempty(obj.name)
                    obj.name=action{1};
                end
                
            else
                obj.b={obj.b{1:pos-1};action;obj.b{pos+1:end}};
            end
        end
        function atomizeAll(obj,seq)
            if nargin==1
                seq=obj.b;
            end
            if isempty(seq)
                warning('Cannot atomize empty Block');
                return
            end
            if strcmpi('Block',class(seq))
                seq=seq.b{1};
            end
            %             seq=seq{:};
            %             newseq={};
            for ii=1:size(seq,1)
                temp=obj.atomizer(seq{ii});
                
                if ~exist('newseq','var')
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
                if size(action,2)>1
                    dat={action{2:end}};
                    if ~mod(size(dat,2),2)==0
                        error('Action/Block parameters need to be key-value pairs');
                    end
                    params=dat(1:2:end);
                    values=dat(2:2:end);
                    
                end
                switch action{1}
                    case 'Load MOT'
                        atomizedAction={
                            {'setCoolingDetuning','duration',0,'value',p.coolingDet,'description','Load MOT: set cooling detuning'};...
                            {'setRepumpDetuning','duration',0,'value',0,'description','Load MOT: set repump to resonanse'};...
                            {'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.coolingPower,'description','Load MOT: set cooling power'};
                            {'setDigitalChannel','channel','IGBT_circ','duration',0,'value','high','description','Load MOT:set IGBT ON'};...
                            {'setDigitalChannel','channel','IGBT_rect','duration',0,'value','high','description','Load MOT: IGBT ON'};...
                            {'setCircCurrent','channel','CircCoil','duration',0,'value',p.circCurrent,'description','Load MOT:set coil current'};...
                            {'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high','description','Load MOT:cooling laser on'};...
                            {'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high','description','Load MOT:repump laser on'};...
                            {'pause','duration',p.MOTLoadTime,'description','Load MOT:delay during mot load'}
                            };
                    case 'Release MOT'
                        atomizedAction={
                            {'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low','description','Release MOT:COOLING OFF'};...
                            {'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low','description','Release MOT:REPUMP OFF'}
                            {'pause','duration',1,'description','Release MOT: Puse after turning lasers off'}
                            {'setAnalogChannel','channel','CircCoil','duration',0,'value',0,'description','Release MOT:CURRENT OFF'};...
                            %                             {'pause','duration',p.IGBTDelay,'description','Release MOT: Pause before IGBT low'};...
                            %                             {'setDigitalChannel','channel','IGBT_rect','duration',0,'value','low','description','Release MOT: IGBT OFF'};...
                            {'setDigitalChannel','channel','IGBT_circ','duration',0,'value','low','description','Release MOT: IGBT OFF'};...
                            {'pause','duration',p.MOTReleaseTime,'description','Release MOT: Pause after turning off magnetic field'}
                            };
                    case 'endOfSeqToF'
                        %duplicates the entire seq above it according to
                        %the number of ToF images and adds image
                        %taking+delay
                        replicatingBlock={};
                        for ind=1:size(p.s.seq,1)-1
                            replicatingBlock=[replicatingBlock;p.s.seq{ind}.b];
                        end
                        for ii = 1:length(p.TOFtimes)
                            
                            tmpatomizedAction=vertcat({{'pause','duration',p.TOFtimes(ii)}},{{'TakePic'}},replicatingBlock);
                            
                            if ii==1
                                atomizedAction=tmpatomizedAction;
                            elseif ii==length(p.TOFtimes)
                                atomizedAction=[atomizedAction;vertcat({{'pause','duration',p.TOFtimes(ii)}},{{'TakePic'}})];
                            else
                                atomizedAction=[atomizedAction;tmpatomizedAction];
                            end
                        end
                    case 'forBlock'
                        loopNumInd=find(strcmpi('loopNum',action));
                        if isempty(loopNumInd)
                            error('No loopNum in forBlock');
                        end
                        loopNum = action{loopNumInd+1};
                        
                        copyBlockInd=find(strcmpi('copyBlock',action));
                        if isempty(copyBlockInd)
                            error('No copyBlock in forBlock');
                        end
                        copyBlock = action{copyBlockInd+1};
                        
                        if ~iscell(copyBlock{1})
                            atomizedAction={copyBlock};
                        else
                            atomizedAction=copyBlock;
                        end
                        for ii=1:loopNum-1
                            if ~iscell(copyBlock{1})
                                atomizedAction=[atomizedAction;{copyBlock}];
                            else
                                atomizedAction=[atomizedAction;copyBlock];
                            end
                        end
                        
                        
                        
                    case 'ToF'
                        for ii = 1:length(p.TOFtimes)
                            if ii==1
                                
                                tmpatomizedAction={
                                    {'Load MOT',action{2:end}};...
                                    {'Release MOT',action{2:end}};...
                                    {'pause','duration',p.TOFtimes(ii)};...
                                    {'TakePic',action{2:end}}...
                                    };
                            else
                                tmpatomizedAction={
                                    {'Reload MOT',action{2:end}};...
                                    {'Release MOT',action{2:end}};...
                                    {'pause','duration',p.TOFtimes(ii)};...
                                    {'TakePic',action{2:end}}...
                                    };
                            end
                            if ii==1
                                atomizedAction=tmpatomizedAction;
                            else
                                atomizedAction=[atomizedAction;tmpatomizedAction];
                            end
                        end
                    case 'TakePic'
                        imagePause = max(p.cameraParams{1}.E2ExposureTime,p.cameraParams{2}.E2ExposureTime);
                        atomizedAction={
                            ...%Set power to max and jump to resonanse
                            {'setDigitalChannel','channel','pixelflyPlaneTrig','duration',20,'value','High','description','picture:trigger photo'};...%Trigger camera
                            {'setDigitalChannel','channel','pixelflyTopTrig','duration',20,'value','High','description','picture:trigger photo'};...%Trigger camera
                            {'pause','duration',5.6};...%pixelfly intrinsic delay
                            {'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0};...
                            {'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0};...
                            {'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',1000,'description','picture: cooling power max'};...
                            {'setCoolingDetuning','duration',0,'value',0,'description','picture:Jump to resonanse'};...
                            {'setRepumpDetuning','duration',0,'value',0,'description','picture: set repump to resonanse'};...
                            {'setDigitalChannel','channel','coolingSwitch','duration',imagePause,'value','High','description','picture:cooling on'};...%Cooling on
                            {'setDigitalChannel','channel','repumpSwitch','duration',imagePause,'value','High','description','picture:repump on'};...%repump on
                            {'pause','duration',imagePause,'description','picture:wait during exposure'};...%Wait for exposure time
                            ...%Set power to what it was and jump to original freq
                            {'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.coolingPower,'description','picture:restore cool pwr'};...
                            {'setCoolingDetuning','duration',0,'value',p.coolingDet,'description','picture:Jump back'}};

                        %%Old technic, using ICE to jump to resonanse
%                         atomizedAction={
%                             ...%Set power to max and jump to resonanse
%                             {'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low','description','picture:cooling off'};...%Cooling off
%                             {'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',880,'description','picture: cooling power max'};...
%                             {'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','High','description','picture:trigger ICE jump'};...
%                             {'pause','duration',300,'description','picture:ICE freq stabilize'};...%Wait for frequency to jump
%                             {'setDigitalChannel','channel','pixelflyPlaneTrig','duration',20,'value','High','description','picture:trigger photo'};...%Trigger camera
%                             {'setDigitalChannel','channel','pixelflyTopTrig','duration',20,'value','High','description','picture:trigger photo'};...%Trigger camera
%                             {'pause','duration',5.6};%pixelfly intrinsic delay
%                             {'setDigitalChannel','channel','coolingSwitch','duration',p.cameraParams{1}.E2ExposureTime,'value','High','description','picture:cooling on'};...%Cooling on
%                             {'setDigitalChannel','channel','repumpSwitch','duration',p.cameraParams{1}.E2ExposureTime,'value','High','description','picture:repump on'};...%repump on
%                             {'pause','duration',imagePause,'description','picture:wait during exposure'};...%Wait for exposure time
%                             ...%Set power to what it was and jump to original freq
%                             {'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.coolingPower,'description','picture:restore cool pwr'};...
%                             {'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','High','description','picture:trig ICE det. jump'};...
%                             {'pause','duration',300,'description','picture:ICE freq stabilize'}};%Wait for frequency to jump
                    case 'Live MOT'
                        atomizedAction={...
                            {'Load MOT'};...
                            {'Live Cameras','description','run imaqreset'}...
                            };
                    case 'bgimg'
                        atomizedAction={...
                            {'setDigitalChannel','channel','IGBT_circ','duration',0,'value','low','description','bgImg: IGBT OFF'};...
                            {'setAnalogChannel','channel','CircCoil','duration',0,'value',0,'description','bgImg:CURRENT OFF'};...
                            {'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','High','description','bgImg:trigger ICE jump'};...
                            {'pause','duration',300,'description','bgImg:ICE freq stabilize'};...%Wait for frequency to jump
                            {'setDigitalChannel','channel','pixelflyPlaneTrig','duration',20,'value','High','description','picture:trigger photo'};...%Trigger camera
                            {'setDigitalChannel','channel','pixelflyTopTrig','duration',20,'value','High','description','picture:trigger photo'};...%Trigger camera
                            {'pause','duration',5.6};%pixelfly intrinsic delay
                            {'setDigitalChannel','channel','coolingSwitch','duration',0,'value','High','description','bgImg:cooling on'};...%Cooling on
                            {'setDigitalChannel','channel','repumpSwitch','duration',0,'value','High','description','bgImg:repump on'};...%repump on
                            {'pause','duration',p.cameraParams{1}.E2ExposureTime,'description','bgImg:wait during exposure'};...%Wait for exposure time
                            ...%Set power to what it was and jump to original freq
                            {'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','High','description','bgImg:trig ICE det. jump'}...
                            };
                    case 'Reload MOT'
                        atomizedAction={
                            {'setCoolingDetuning','duration',0,'value',p.coolingDet,'description','Reload MOT: set cooling detuning'};...
                            {'setRepumpDetuning','duration',0,'value',0,'description','Reload MOT: set repump to resonanse'};...
                            {'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.coolingPower,'description','Reload MOT: set cooling power'};
                            {'setDigitalChannel','channel','IGBT_circ','duration',0,'value','high','description','Reload MOT:set IGBT ON'};...
                            {'setCircCurrent','channel','CircCoil','duration',0,'value',p.circCurrent,'description','Reload MOT:set coil current'};...
                            {'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high','description','Reload MOT:cooling laser on'};...
                            {'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high','description','Reload MOT:repump laser on'};...
                            {'pause','duration',p.MOTReloadTime,'description','Reload MOT:delay during mot reload'}
                            };
                    case 'MOTblink'
                        atomizedAction={{'Load MOT'};...
                            {'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low','description','MOT BLINK: cooling off'};...
                            {'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low','description','MOT BLINK: repump off'};...
                            {'pause','duration',10};...
                            %                             {'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','High','description','MOT BLINK: trigger ICE jump'};...
                            {'TrigScope'};...
                            {'setDigitalChannel','channel','IGBT_circ','duration',0,'value','low','description','MOT BLINK: IGBT OFF'};...
                            {'setAnalogChannel','channel','CircCoil','duration',0,'value',0,'description','MOT BLINK:CURRENT OFF'};...
                            {'pause','duration',100};...
                            {'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high','description','MOT BLINK: cooling on'};...
                            {'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high','description','MOT BLINK: repump on'};...
                            {'pause','duration',1e6};...
                            {'setDigitalChannel','channel','IGBT_circ','duration',0,'value','high','description','MOT BLINK: IGBT OFF'};...
                            {'setAnalogChannel','channel','CircCoil','duration',0,'value',p.circCurrent,'description','MOT BLINK:CURRENT OFF'};...
                            {'GenPause','duration',500e3,'channel','none','value','none'}};...
                            %{'pause','duration',1500e3};...
                        
                    case 'TrigScope'
                        atomizedAction={{'setDigitalChannel','channel','ScopeTrigger','duration',1,'value','high','description','Scope Trigger'}};
                    case 'setAHH'
                        atomizedAction={{'setAnalogChannel','channel','CircCoil','duration',0,'value',p.circCurrent,'description','set AHH CURRENT'}};
                        %                     case 'startAnalogRamp'
                        %                         atomizedAction={{'startAnalogRamp','EndCurrent',p.compressionEndCurrent,'ptsToAdd',p.compressionPtsToAdd,'duration',0,'description','start magnetic field compression'}};
                    case 'TakePicForMWSpectro'
                        imagePause = max(p.cameraParams{1}.E2ExposureTime,p.cameraParams{2}.E2ExposureTime);
                        atomizedAction={
                            ...%Set power to max and jump to resonanse
                            {'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low','description','picture:cooling off'};...%Cooling off
                            {'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',1000,'description','picture: cooling power max'};...
                            {'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','High','description','picture:trigger ICE jump'};...
                            {'pause','duration',300,'description','picture:ICE freq stabilize'};...%Wait for frequency to jump
                            {'setDigitalChannel','channel','pixelflyPlaneTrig','duration',20,'value','High','description','picture:trigger photo'};...%Trigger camera
                            {'setDigitalChannel','channel','pixelflyTopTrig','duration',20,'value','High','description','picture:trigger photo'};...%Trigger camera
                            {'pause','duration',5.6};%pixelfly intrinsic delay
                            {'setDigitalChannel','channel','coolingSwitch','duration',p.cameraParams{1}.E2ExposureTime,'value','High','description','picture:cooling on'};...%Cooling on
                            {'pause','duration',imagePause,'description','picture:wait during exposure'};...%Wait for exposure time
                            ...%Set power to what it was and jump to original freq
                            {'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.coolingPower,'description','picture:restore cool pwr'};...
                            {'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','High','description','picture:trig ICE det. jump'};...
                            {'pause','duration',300,'description','picture:ICE freq stabilize'}};%Wait for frequency to jump
                    case 'LoadDipoleTrap'
                        p.MOTLoadTime = p.DTParams.MOTLoadTime;
                        p.coolingDet = p.DTParams.coolingDet;
                        p.circCurrent = p.DTParams.circCurrent;
                        p.DTPic = p.DTParams.DTPic;
                        atomizedAction={...
                            {'Load MOT'};...
                            {'setCircCurrent','channel','CircCoil','duration',0,'value',p.DTParams.CompressioncircCurrent};...
                            {'pause','duration',p.DTParams.compressionRampTime};...
                            {'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.DTParams.CompressionPower};...
                            {'setCoolingDetuning','duration',0,'value',p.DTParams.compressionDetuning};...
                            {'setRepumpDetuning','duration',0,'value',p.DTParams.repumpDetuning};...
                            {'pause','duration',p.DTParams.compressionTime};...
                            {'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0};...
                            {'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0};...
                            {'Release MOT'};...
                            {'setRepumpDetuning','duration',0,'value',0}};
                    case 'TakeAbsPic'
                        imagePause = p.AbsImgTime;
                        atomizedAction={
                            ...%Set power to max and jump to resonanse
%                             {'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','High','description','picture:trigger ICE jump'};...
%                             {'pause','duration',300,'description','picture:ICE freq stabilize'};...%Wait for frequency to jump
                            {'setAnalogChannel','channel','ImagingVVAN','duration',0,'value',p.imagingPower,'description','set imaging power'};...
                            {'setDigitalChannel','channel','pixelflyPlaneTrig','duration',20,'value','High','description','picture:trigger photo'};...%Trigger camera
                            {'setDigitalChannel','channel','pixelflyTopTrig','duration',20,'value','High','description','picture:trigger photo'};...%Trigger camera
                            {'pause','duration',5.6};...%pixelfly intrinsic delay
                            {'setDigitalChannel','channel','repumpSwitch','duration',imagePause,'value','high'};...
                            {'setDigitalChannel','channel','ZEEMANSwitch','duration',imagePause,'value','High'};...%Cooling on
                            {'pause','duration',imagePause,'description','picture:wait during exposure'}};%Wait for exposure time
                            %Set power to what it was and jump to original freq
%                             {'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','High','description','picture:trig ICE det. jump'};...
%                             {'pause','duration',300,'description','picture:ICE freq stabilize'}};%Wait for
                    otherwise
                        error('No such action found: %s',action{1});
                end
                
                if exist('params','var') %passing parameters on
                    for ii=1:size(atomizedAction,1)
                        found=zeros(1,size(params,2));
                        for jj=1:size(atomizedAction{ii},2)
                            for kk=1:size(params,2)
                                bool=strcmp(params{kk},atomizedAction{ii}{jj});
                                if bool
                                    found(kk)=1;
                                end
                                
                                if bool
                                    atomizedAction{ii}{jj+1}=values{kk};
                                    %                             elseif jj==size(atomizedAction{ii},2) && ~found(kk)
                                    %                                 size(atomizedAction{ii},2)
                                    %                                 atomizedAction{ii}{jj+1}=params{kk};
                                    %                                 atomizedAction{ii}{jj+2}=values{kk};
                                end
                            end
                            
                        end
                    end
                end
                
                
                
            end
        end
        function setTimeline(obj,starttime)
            %Assume deferent steps are separated by lines
            if nargin ==1
                starttime=0;
            end
            
            seq = obj.b;
            if ~obj.isAtomic(seq)
                error('Cannot add start times to a compound sequence');
            end
            currTime = starttime;
            for ii = 1:size(seq,1)
                if strcmpi(seq{ii}{1},'pause')
                    durationInd=find(strcmpi('duration',seq{ii}));
                    if isempty(durationInd)
                        error('action does not have a duration!');
                    end
                    currTime=currTime+seq{ii}{durationInd+1};
                else
                    durationInd=find(strcmpi('duration',seq{ii}));
                    
                    
                    if isempty(durationInd) && ~(strcmpi(seq{ii}{1},'forStart') || strcmpi(seq{ii}{1},'forEnd'))
                        error('action does not have a duration!');
                    end
                    seq{ii}{end+1} = 'start time';
                    seq{ii}{end+1} = currTime;
                    currTime = currTime+1/40;
                end
                obj.b=seq;
            end
            
        end
        function visualize(obj,a)
            blockWidth=10;
            blockHeight=10;
            if nargin==1
                a=axes;
                axis equal
            end
            xlim([0,100]);
            ylim([-1,blockHeight+1]);
            yticks([]);
            for ii=1:size(obj.b,1)
                rectangle(a,'Position',[(ii-1)*blockWidth,0,blockWidth,blockHeight],'Curvature',0.2);
                str=obj.b{ii}{1};
                strlen=length(str);
                text(a,blockWidth*(ii-1)+blockWidth/2-floor(strlen/2),blockHeight/2,str);
            end
        end
        
        
        function value=toTable(obj)
            value=table();
            if isempty(obj.b)
                
                value.name=obj.name;
            else
                
                value.name=obj.b{1}{1};
                vars={};
                vals={};
                for ind=2:2:length(obj.b{1})
                    vars{end+1}=obj.b{1}{ind};
                    vals{end+1}=obj.b{1}{ind+1};
                end
                
                
                for ind=1:length(vars)
                    value.(vars{ind})=vals{ind};
                end
                
            end
        end
    end
    
    
    methods (Access = protected)
        function displayScalarObject(obj)
            if isempty(obj.b)
                fprintf('empty block\n');
            else
                fprintf('Block: %s\n',obj.name)
                fprintf('______\n');
                block=obj.b;
                for ii =1:size(block,1)
                    fprintf('%d:%-20s\t',ii,block{ii}{1});
                    if size(block{ii},2)>1
                        if any(strcmpi(block{ii},'description'))
                            ind=find(strcmpi(block{ii},'description'))+1;%index where description value is
                            fprintf('%-30s\t',block{ii}{ind});
                            for jj=2:2:size(block{ii},2)
                                fprintf('%s:%s|',block{ii}{jj},num2str(block{ii}{jj+1}));
                            end
                        else
                            fprintf('%-30s\t','');
                            for jj=2:2:size(block{ii},2)
                                fprintf('%s:%s|',block{ii}{jj},num2str(block{ii}{jj+1}));
                            end
                        end
                    end
                    fprintf('\n');
                    %
                end
            end
        end
    end
end


