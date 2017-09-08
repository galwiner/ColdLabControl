classdef CodeGenerator < handle
    % the CodeGen class
    %
    %
    %---------------------------------------------------------------

    properties(Constant = true)

        CommandList =  {'Do nothing'  ,'Analog out'  ,'Digital out',...
            'Photon count','Register'    ,'If'         ,...
            'Goto T/F'    ,'Push to FIFO','End program','DDS Prog.'};
        SubcommandList ={'NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA';...
            'AOO','AO1','AO2','AO3','AO4','NA','NA','NA','NA','NA','NA','NA','NA'  ;...
            'DOO','DO1','DO2','DO3','DO4','DO5','DO6','DO7','DO8','DO9','DO10','DO11','RAPtrig';...
            'PMT1+PMT2->RegA','PMT1->RegA','PMT2->RegA','reset','PMT1&PMT2>RegA','NA','NA','NA','NA','NA','NA','NA','NA';...
            'par1->RegA','par1->RegB','par1->RegC','Inc RegC','Inc RegA','RegB->RegC','RegB+flag[0]->RegB','Pause','RegB+RegA->RegB','AI1toPhase->RegD','RegD*2^n->RegD','NA','NA';...
            'RegA=par1','RegB>par1','RegC=par1','RegB>RegC','ExtTrig rising edge','NA','NA','NA','NA','NA','NA','NA','NA';...
            'NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA';...
            'RegA','RegB','RegC','PhotonPhase','NA','NA','NA','NA','NA','NA','NA','NA','NA';...
            'NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA';...
            'Bus','DDS1 Latch','DDS2 Latch','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA'};
        NumOfDDS = 2;
        DDSInternalClockFreq = 28.1474976710656; % Do not change this number
        DDSExternalFrequency = 24;
        DDSPLLRatio = 12;
        DDSFrequencyLimit = [1e-4 100];

    end

    properties
        % code has the shared memory structure :
        % [ command(byte) subcommand(byte) par1(int16) par2(int16) ]
        code=[];
        currentline=1;
        stack;
        numofreadout=0;
        DDSCurrentState;
%         DDSCurrentState = struct('IntRegMap',[],'IOPortBuffMap',[],...
%             'LegsValues',[]);
        DDSBusCurrentAddress = zeros(1,6);
        DDSBusCurrentData = zeros(1,8);

    end%properties

    properties (Dependent = true)
        codenumoflines;
    end

    methods
        function obj = CodeGenerator
            obj.currentline=1;
            obj.stack=Stack;
            obj.code=int16(zeros(999,4));
            for DDSIndex = 1:obj.NumOfDDS
%                 obj.DDSCurrentState(DDSIndex).IntRegMap = [];
%                 obj.DDSCurrentState(DDSIndex).IOPortBuffMap = [];
                obj.DDSCurrentState(DDSIndex).LegsValues = [];
            end
            %
        end

        function GenSeq(obj,arrayofpulses,varargin)
            % This method generate the code of pulse sequence with all
            % the pulse parameter setting but WITHOUT LOGIC
            
            %The first stage create a time line from the pules array
            % timeline structure [ time channel action parameter]
            DDSprogTime=26;%in clock cycles
            timeline=Pulse.Sequence2TimeLine(arrayofpulses);
            numoflines=size(timeline,1);
            if (size(varargin,2)==1)
                lasteventtime=-varargin{1};
            else
                lasteventtime=0;
            end
            %the main stage that compile the timeline to FPGA code
            for i=1:numoflines
                % insert wait until new event
                GenPause(obj,(timeline(i,1)-lasteventtime)/40);
                lasteventtime=timeline(i,1);
                channel=timeline(i,2);
                operation=timeline(i,3);
                parameter=timeline(i,4);
                channeltype=PulseChannelInfo(channel,'ChannelType');
                switch operation
                    case 1 %---------------- switch ON -----------------------
                        % set digital channel to on
                        switch channeltype
                            case {'VCO','Dig','DDSwithSw'}
                                obj.code(obj.currentline,:)=...
                                    [ 2 , PulseChannelInfo(channel,'DigitalSwitch'),PulseChannelInfo(channel,'OnIs'), 0];
                                obj.currentline=obj.currentline+1;
                            case {'PMT', 'FifolessPMT'}
                                % reset PMT counters  command=3 subcommand = 3
                                obj.code(obj.currentline,:)=[ 3 , 3 , 0 , 0];
                                obj.currentline=obj.currentline+1;
                            case {'DDS' }
                                % use DDS high level command to swich the
                                % output power on
                                obj.GenDDSIPower(PulseChannelInfo(channel,'DDSNum'),PulseChannelInfo(channel,'OnIs'));
                                lasteventtime=lasteventtime+DDSprogTime;% currect for DDS communication time
                            otherwise
                                error(' No Switch ON for this ChannelType');
                        end
                    case 2 % ---------------- switch OFF ----------------------
                        switch channeltype
                            case {'VCO','Dig','DDSwithSw'}
                                obj.code(obj.currentline,:)=...
                                    [ 2 , PulseChannelInfo(channel,'DigitalSwitch'),~PulseChannelInfo(channel,'OnIs'), 0];
                                obj.currentline=obj.currentline+1;
                            case 'PMT'
                                % set RegB to 0
                                obj.code(obj.currentline,:) = [ 4 , 1 , 0 , 0];
                                % the command for handeling PMT is 3
                                % subcommand = 0 -> add sum of photon counters to regB
                                % subcommand = 1 -> add only photon counter 1 to regB
                                % subcommand = 2 -> add only photon counter 2 to regB
                                % subcommand = 4 -> add PMT 1&2 to regB low&high byte 
                                obj.code(obj.currentline+1,:)=[ 3 , PulseChannelInfo(channel,'Operation'), 0 , 0];
                                % Push RegB to FIFO :Command 7 subcommand 1
                                obj.code(obj.currentline+2,:) = [ 7 , 1 , 0 , 0];
                                obj.currentline=obj.currentline+3;
                                obj.numofreadout=obj.numofreadout+1;
                            case 'FifolessPMT'
                                % regB<-#photons
                                obj.code(obj.currentline,:)=[ 3 , PulseChannelInfo(channel,'Operation') , 0 , 0];
                                obj.currentline=obj.currentline+1;
                            case 'DDS'
                                % use DDS high level command to swich the
                                % output power off
                                obj.GenDDSIPower(PulseChannelInfo(channel,'DDSNum'),0);
                                lasteventtime=lasteventtime+DDSprogTime;% currect for DDS communication time

                            otherwise
                                error(' No Switch ON for this ChannelType');
                        end

                    case 3 % -------------- set frequency ---------------------
                        switch channeltype
                            case 'VCO'
                                % SetFreqAddress relate to the Analogout channel on
                                % the fpag that set by the subcommand.
                                % command is set to 1 that handel analog out
                                % get the real value that represent the freq

                                freq=parameter;
                                voltage=eval(PulseChannelInfo(channel,'Freq2Value'));
                                obj.code(obj.currentline,:)=...
                                    [ 1 , PulseChannelInfo(channel,'SetFreqAddress') , voltage , 0];
                                obj.currentline=obj.currentline+1;
                            case {'DDS','DDSwithSw'}
                                % use DDS high level command to set
                                % frequency
                                obj.GenDDSFrequencyWord(PulseChannelInfo(channel,'DDSNum'),1,parameter)
                                lasteventtime=lasteventtime+18;%  for DDS communication time
                            otherwise
                                error(' invalid channel type for set freq ');
                        end
                    case 4 %---------------- set phase ------------------------
                        switch channeltype
                            case {'DDS','DDSwithSw'}
                              % use DDS high level command to set phase                          
                              obj.GenDDSPhaseWord(PulseChannelInfo(channel,'DDSNum'),1,parameter)
                              lasteventtime=lasteventtime+8;%  for DDS communication time
                             otherwise
                                error(' invalid Channel type for set phase ');
                        end
                    case 5 % ---------------- set amplitude ----------------------
                        switch channeltype
                            case {'VCO'}
                                obj.code(obj.currentline,:)=...
                                    [ 1 , PulseChannelInfo(channel,'SetAmpAddress'),parameter, 0];
                                obj.currentline=obj.currentline+1;
                            case {'DDSwithSw','DDS'}
                                % use DDS high level command to set amp
                                obj.GenDDSIPower(PulseChannelInfo(channel,'DDSNum'),parameter);
                                lasteventtime=lasteventtime+18;%  for DDS communication time
                            otherwise
                                error(' invalid Channel type for set amplitude');
                        end

                    otherwise %-------- any other operation -------------------
                end %switch

            end %for loop
        end % SegGen

        function GenRegOp(obj,cmdStr,cmdVar1,cmdVar2,cmdVar3)
            if ~exist('cmdVar1')
                cmdVar1=0;
            end
            if ~exist('cmdVar2')
                cmdVar2=0;
            end
            if ~exist('cmdVar3')
                cmdVar3=0;
            end
            switch cmdStr
                case {'RegA='} %RegB=cmdVar(1): command 4 subc 0, par1=cmdVar(1)
                    obj.code(obj.currentline,:)=[4 0 cmdVar1 0];
                    obj.currentline=obj.currentline+1;
                case {'RegB='} %RegB=cmdVar(1): command 4 subc 1, par1=cmdVar(1)
                    obj.code(obj.currentline,:)=[4 1 cmdVar1 0];
                    obj.currentline=obj.currentline+1;
                case {'RegC='} %RegC=cmdVar(1): command 4 subc 2, par1=cmdVar(1)
                    obj.code(obj.currentline,:)=[4 2 cmdVar1 0];
                    obj.currentline=obj.currentline+1;
                case {'RegD='} %RegD=cmdVar(1): command 4 subc 11, par1=cmdVar(1)
                    obj.code(obj.currentline,:)=[4 11 cmdVar1 0];
                    obj.currentline=obj.currentline+1;
                case {'RegA=+1'} %RegC=RegC+1: command 4 subc 4
                    obj.code(obj.currentline,:)=[4 4 0 0];
                    obj.currentline=obj.currentline+1;
                case {'RegC=+1'} %RegC=RegC+1: command 4 subc 3
                    obj.code(obj.currentline,:)=[4 3 0 0];
                    obj.currentline=obj.currentline+1;
                case {'RegD=AI1toPhase'} %RegD=AI1toPhase : command 4 subc 9
                    obj.code(obj.currentline,:)=[4 9 0 0];
                    obj.currentline=obj.currentline+1;
                case {'FIFO<-RegA'} %command 7, subc 0, no pars
                    obj.code(obj.currentline,:)=[7 0 0 0];
                    obj.currentline=obj.currentline+1;
                case {'FIFO<-RegB'} %command 7, subc 1, no pars
                    obj.code(obj.currentline,:)=[7 1 0 0];
                    obj.currentline=obj.currentline+1;
                case {'FIFO<-RegC'} %command 7, subc 2, no pars
                    obj.code(obj.currentline,:)=[7 2 0 0];
                    obj.currentline=obj.currentline+1;
                case {'FIFO<-RegD'} %command 7, subc 5, no pars
                    obj.code(obj.currentline,:)=[7 5 0 0];
                    obj.currentline=obj.currentline+1;
                case {'FIFO<-AI1'} %command 7, subc 4, no pars
                    obj.code(obj.currentline,:)=[7 4 0 0];
                    obj.currentline=obj.currentline+1;
%                 case {'RegD*2^n'} %command 7, subc 4, no pars
%                    
%                     obj.code(obj.currentline,:)=[4 10 cmdVar1 cmdVar2];
%                     obj.currentline=obj.currentline+1;
                    
                 case {'(RegD+off)*C*2^n'} %command 4, subc 10, par1 = [C n], par2 = off
                     % off = cmdVar1, C = cmdVar2, n = cmdVar3 
                    hexString = '0000';
                    cmdVar2Hex = dec2hex(cmdVar2);
                    hexString((3-length(cmdVar2Hex)):2) = cmdVar2Hex;
                    if cmdVar3<0
                        cmdVar3Hex = dec2hex(255-(abs(cmdVar3)-1));
                    else
                        cmdVar3Hex = dec2hex(cmdVar3);
                    end
                    hexString((5-length(cmdVar3Hex)):4) = cmdVar3Hex;
                    obj.code(obj.currentline,:)=[4 10 hex2dec(hexString) int16(cmdVar1)];
                    obj.currentline=obj.currentline+1;
                otherwise
                    disp('Unknown method.')
            end
        end
        
        function GenPhotonTimes(obj,duration)
            % translate duration in uS to loop number
            % loop time= 10 x Clock =250ns
            duration=round(duration*4);
            % the methods generate the code for measureing photon time of arrivel
            if duration>0

                duration=typecast(int32(duration),'int16');
                obj.code(obj.currentline,:)=[3,0,0,0];                         % load sum of photon counters to regB
                obj.code(obj.currentline+1,:)=[4,5,0,0];                       % if  RegB>RegC
                obj.currentline=obj.currentline+2;

                obj.code(obj.currentline,:)=[4,0,0,0];                         % set RegA to 0
                obj.code(obj.currentline+1,:)=[7,0,0,0];                       % Push RegA to FIFO to singnal new exp
                % repeat
                obj.code(obj.currentline+2,:)=[4,4,0,0];                       % increace RegA by 1
                obj.code(obj.currentline+3,:)=[3,0,0,0];                       % load sum of photon counters to regB
                obj.code(obj.currentline+4,:)=[5,3,0,0];                       % if  RegB>RegC
                obj.code(obj.currentline+5,:)=[6,0,obj.currentline+9,...       % conditional goto
                    obj.currentline+7];         % true=currentline+2 false=currentline+?
                obj.code(obj.currentline+6,:)=[0,0,0,0];                       % empty line due to goto
                %false
                obj.code(obj.currentline+7,:)=[6,0,obj.currentline+11,...      % goto after true
                    obj.currentline+11];
                obj.code(obj.currentline+8,:)=[0,0,0,0];                       % empty line due to goto
                %true
                obj.code(obj.currentline+9,:)=[4,5,0,0];                       % Set RegC to RegB
                obj.code(obj.currentline+10,:)=[7,0,0,0];                      % Push RegA to FIFO

                obj.code(obj.currentline+11,:)=[5,0,duration(1),duration(2)];   % if RegA=duration
                obj.code(obj.currentline+12,:)=[6,0,obj.currentline+14,...      % conditional goto
                    obj.currentline+2];          % true->stop=currentline+5 false->loop =currentline+1
                obj.code(obj.currentline+13,:)=[0,0,0,0];                       % empty line due to goto

                obj.currentline=obj.currentline+14;                             % update currentline
            end
        end

        function GenPhotonPhase(obj,duration)
            % translate duration in uS to loop number
            % loop time= 10 x Clock =250ns
            duration=round(duration*4);
            % the methods generate the code for measureing photon time of arrivel
            if duration>0

                duration=typecast(int32(duration),'int16');
                obj.code(obj.currentline,:)=[3,0,0,0];                         % load sum of photon counters to regB
                obj.code(obj.currentline+1,:)=[4,5,0,0];                       % if  RegB>RegC
                obj.currentline=obj.currentline+2;

                obj.code(obj.currentline,:)=[4,0,0,0];                         % set RegA to 0
                obj.code(obj.currentline+1,:)=[7,0,0,0];                       % Push RegA to FIFO to singnal new exp
                % repeat
                obj.code(obj.currentline+2,:)=[4,4,0,0];                       % increace RegA by 1
                obj.code(obj.currentline+3,:)=[3,0,0,0];                       % load sum of photon counters to regB
                obj.code(obj.currentline+4,:)=[5,3,0,0];                       % if  RegB>RegC
                obj.code(obj.currentline+5,:)=[6,0,obj.currentline+9,...       % conditional goto
                    obj.currentline+7];         % true=currentline+2 false=currentline+?
                obj.code(obj.currentline+6,:)=[0,0,0,0];                       % empty line due to goto
                %false
                obj.code(obj.currentline+7,:)=[6,0,obj.currentline+11,...      % goto after true
                    obj.currentline+11];
                obj.code(obj.currentline+8,:)=[0,0,0,0];                       % empty line due to goto
                %true
                obj.code(obj.currentline+9,:)=[4,5,0,0];                       % Set RegC to RegB
                obj.code(obj.currentline+10,:)=[7,3,0,0];                      % Push Photon Phase to FIFO

                obj.code(obj.currentline+11,:)=[5,0,duration(1),duration(2)];   % if RegA=duration
                obj.code(obj.currentline+12,:)=[6,0,obj.currentline+14,...      % conditional goto
                    obj.currentline+2];          % true->stop=currentline+5 false->loop =currentline+1
                obj.code(obj.currentline+13,:)=[0,0,0,0];                       % empty line due to goto

                obj.currentline=obj.currentline+14;                             % update currentline
            end
        end

        function GenWait(obj,c)
            % the methods generate a wait of time= (1+cx4)xClock
            % =25+Cx100[ns]
            if ~exist('c') %do Gen wait based on the time given in memoryBlock(regC)
                % set RegA to 0 : command=4,subcomand=0
                obj.code(obj.currentline,:)=[4,0,0,0];
               
                % increace RegA by 1 :command=4,subcomand=4
                obj.code(obj.currentline+1,:)=[4,4,0,0];

                % generate if statement RegA=memoryblock(regC) :command=5,subcommand=6,no pars
                obj.code(obj.currentline+2,:)=[5,6,0,0];

                % generate conditional goto
                % command=6, subcommand = Na, true->stop=currentline+5
                % false->loop =currentline+1
                obj.code(obj.currentline+3,:)=[6,0,obj.currentline+5,obj.currentline+1];
                % generate empty line due to goto
                obj.code(obj.currentline+4,:)=[0,0,0,0];
                obj.currentline=obj.currentline+5;
            elseif c>1
                % set RegA to 0 : command=4,subcomand=0
                obj.code(obj.currentline,:)=[4,0,0,0];

                % increace RegA by 1 :command=4,subcomand=4
                obj.code(obj.currentline+1,:)=[4,4,0,0];

                % generate if statement RegA=c :command=5, subcommand=0,[par1,par2]=c
                c=typecast(int32(c),'int16');
                obj.code(obj.currentline+2,:)=[5,0,c(1),c(2)];

                % generate conditional goto
                % command=6, subcommand = Na, true->stop=currentline+5
                % false->loop =currentline+1
                obj.code(obj.currentline+3,:)=[6,0,obj.currentline+5,obj.currentline+1];
                % generate empty line due to goto
                obj.code(obj.currentline+4,:)=[0,0,0,0];
                obj.currentline=obj.currentline+5;
            end
        end

        function GenPause(obj,c)
         % c is in microseconds 
         % Employes command 4,7 of the pigeon
            c=c*40; % translate to clock cycle
            if (c>=1)               
                c=typecast(int32(c-1),'int16');
                obj.code(obj.currentline,:)=[4,7,c(1),c(2)];
                obj.currentline=obj.currentline+1;
            end
                 
        end

        function GenWaitExtTrigger(obj)

            % generate if statement is external trigger rising edge
            obj.code(obj.currentline,:)=[5,4,0,0];
            % generate conditional goto
            obj.code(obj.currentline+1,:)=[6,0,obj.currentline+3,obj.currentline];
            % generate empty line due to goto
            obj.code(obj.currentline+2,:)=[0,0,0,0];
            obj.currentline=obj.currentline+3;
        end

        function GenRepeatSeq(obj,arrayofpulses,c)
            % set RegC to 0 : command=4,subcomand=2
            obj.code(obj.currentline,:)=[4,2,0,0];
            obj.currentline=obj.currentline+1;

            % save currentline to startline
            startline=obj.currentline;

            % increace RegC by 1 :command=4,subcomand=3
            obj.code(obj.currentline,:)=[4,3,0,0];
            obj.currentline=obj.currentline+1;

            % generate the pulses code !without logic!
            obj.GenSeq(arrayofpulses);

            % generate if statement RegC=c :command=5, subcommand=2,par1=c
            obj.code(obj.currentline,:)=[5,2,c,0];
            obj.currentline=obj.currentline+1;

            % generate conditional goto startline/currentline+1
            % command=6, subcommand = Na ,true:par1=currentline+2 false:par2=startline
            obj.code(obj.currentline,:)=[6,0,obj.currentline+2,startline];
            % generate empty line due to goto
            obj.code(obj.currentline+1,:)=[0,0,0,0];
            obj.currentline=obj.currentline+2;

        end

        function GenFor(obj,N)
            %generate the start of a for loop, based on regC, iterated N
            %times. regC will run from 0,..,N-1
            if N<1
                return;
            end
            % set RegC to 0 : command=4,subcomand=2
            obj.code(obj.currentline,:)=[4,2,0,0];
            obj.currentline=obj.currentline+1;
            %push currentline to stack, for GenForEnd
            obj.stack.Push(N);
            obj.stack.Push(obj.currentline);
        end
        
        function GenForEnd(obj)
            % the end statement matching the GenFor
            startline=obj.stack.Pop;
            N=obj.stack.Pop;
            % increace RegC by 1 :command=4,subcomand=3
            obj.code(obj.currentline,:)=[4,3,0,0];
            obj.currentline=obj.currentline+1;
            % generate if statement RegC==N :command=5, subcommand=2,par1=N
            obj.code(obj.currentline,:)=[5,2,N,0];
            obj.currentline=obj.currentline+1;
            % generate conditional goto startline/currentline+1
            % command=6, subcommand = Na ,true:par1=currentline+2 false:par2=startline
            obj.code(obj.currentline,:)=[6,0,obj.currentline+2,startline];
            % generate empty line due to goto
            obj.code(obj.currentline+1,:)=[0,0,0,0];
            obj.currentline=obj.currentline+2;
        end
        
        function GenRepeat(obj)
            %generate the start of a repeat loop
            %push currentline to stack, for GenForEnd
            obj.stack.Push(obj.currentline);
        end
        
        function GenRepeatEnd(obj,expression)
            % the end statement matching the GenFor
            startline=obj.stack.Pop;
            % generate if statement 
            switch expression
                case 'RegB>0'
                   obj.code(obj.currentline,:)=[5,1,0,0];
                otherwise
                   error('Unknown method.');
            end
            obj.currentline=obj.currentline+1;
            % generate conditional goto 
            % command=6, subcommand = Na ,true:par1=currentline+2 false:par2=startline
            obj.code(obj.currentline,:)=[6,0,obj.currentline+2,startline];
            % generate empty line due to goto
            obj.code(obj.currentline+1,:)=[0,0,0,0];
            obj.currentline=obj.currentline+2;
        end
        
        function GenIfDo(obj,expr,c)
            % generate the If statement according to expr
            % the syntax must look like;
            % GenIfDo(...)
            %      GenSeq(...)
            % GenElseDo(...)
            %      GenSeq(...)
            % GenElseEnd
            switch expr
                case 'PhotonCount>='
                    % generate if statement RegA=>c :command=5, subcommand=5,par1=c
                    obj.code(obj.currentline,:)=[5,5,c,0];
                case 'RegB>'
                    % generate if statement RegA=>c :command=5, subcommand=5,par1=c
                    obj.code(obj.currentline,:)=[5,1,c,0];
                case 'RegC='
                   % generate if statement RegC=>c :command=5, subcommand=5,par1=c
                    obj.code(obj.currentline,:)=[5,2,c,0];
                    
                otherwise
                    error('invalid if expression');
            end
            % generate the conditional goto command
            % command=6, subcommand = Na ,true:par1=currentline+2 (continue )
            % false:par2=Na the GenElseDo function will fill the par2 value
            % for this line
            obj.stack.Push(obj.currentline+1);
            obj.code(obj.currentline+1,:)=[6,0,obj.currentline+3,0];
            obj.code(obj.currentline+2,:)=[0,0,0,0]; % null line for goto implemntation
            obj.currentline=obj.currentline+3;
        end

        function GenElseDo(obj)
            % End the GenIfDo=true part
            % generarte a goto command=6, subcommand = Na par1=par2 will be
            % update by GenElseEnd
            obj.code(obj.currentline,:)=[6,0,0,0];
            obj.code(obj.currentline+1,:)=[0,0,0,0]; % null line for goto implemntation
            % update the par2 in the if line
            obj.code(obj.stack.Pop,4)=obj.currentline+2;
            % save currentline for the GenElseEnd
            obj.stack.Push(obj.currentline);
            obj.currentline=obj.currentline+2;
        end

        function GenElseEnd(obj)
            % update the GenElseDo
            elseLine = obj.stack.Pop;
            obj.code(elseLine,3)=obj.currentline;
            obj.code(elseLine,4)=obj.currentline;
        end

        function GenFinish(obj)
            % End and reset program. command=8 ...
            obj.code(obj.currentline,:)=[8,0,0,0];
            obj.code(obj.currentline+1,:)=[0,0,0,0];
            obj.currentline=obj.currentline+2;
            obj.code(obj.currentline:end,:)=[];
        end

        % ------------- DDS low instructions. ----------------
        function GenDDSBusState(obj,address,data)
            %Sets values for the address and data but which is in common for all the DDS.
            % Both address and data expressed in Hex basis.

            % updating the internal memory of the bus in the object.
            obj.DDSBusCurrentAddress = zeros(1,6);
            tempAddress = double(dec2bin(hex2dec(address)))-48;
            if length(tempAddress)>6
                error('Wrong address value');
            else
                obj.DDSBusCurrentAddress...
                    (1,end-length(tempAddress)+1:end) = tempAddress;
            end

%             obj.DDSBusCurrentData = zeros(1,8);
%             tempData = double(dec2bin(hex2dec(data)))-48;
%             if length(tempData)>8
%                 error('Wrong data value');
%             else
%                 obj.DDSBusCurrentData...
%                     (1,end-length(tempData)+1:end) = tempData;
%             end

            % feeding data to the bus.
            obj.code(obj.currentline,:)=[9,0,hex2dec(address),hex2dec(data)];
            obj.currentline=obj.currentline+1;
            obj.GenPause(0.05);
        end

        function GenDDSResetPulse(obj,DDSNum)
            % Resets the operation of one (DDSNum) or all (DDNum=0) the
            % DDS by raising and lowering the voltage over the chips reset
            % legs.
            % 8 instructions lines.
            if nargin>1
                DDSList = DDSNum;
            else
                DDSList = 1:obj.NumOfDDS;
            end

            % add the reset lines to the program
            for DDSIndex = 1:length(DDSList)
                % send the reset command.
                % flagVec = obj.DDSCurrentState(DDSList(DDSIndex)).LegsValues;
                flagVec = zeros(1,4);

                flagVec([1 3]) = 1;
                obj.code(obj.currentline,:) = ...
                    [9 DDSList(DDSIndex) bin2dec(char(fliplr(flagVec)+48)) 0];

                flagVec(1) = 0;

                obj.currentline=obj.currentline+1;
                obj.GenPause(1);
                obj.code(obj.currentline,:) = ...
                    [9 DDSList(DDSIndex) bin2dec(char(fliplr(flagVec)+48)) 0];
                obj.currentline=obj.currentline+1;

                obj.DDSCurrentState(DDSList(DDSIndex)).LegsValues = flagVec;

                % updating the IO bufferes and the internal registers maps.
                % The values are taken from the AD9854 Datasheet.
                obj.DDSCurrentState(DDSList(DDSIndex)).IOPortBuffMap(hex2dec('19')+1,:) = Dec2BinVec(hex2dec('40'),8);
                obj.DDSCurrentState(DDSList(DDSIndex)).IOPortBuffMap(hex2dec('1D')+1,:) = Dec2BinVec(hex2dec('10'),8);
                obj.DDSCurrentState(DDSList(DDSIndex)).IOPortBuffMap(hex2dec('1E')+1,:) = Dec2BinVec(hex2dec('64'),8);
                obj.DDSCurrentState(DDSList(DDSIndex)).IOPortBuffMap(hex2dec('1F')+1,:) = Dec2BinVec(hex2dec('01'),8);
                obj.DDSCurrentState(DDSList(DDSIndex)).IOPortBuffMap(hex2dec('20')+1,:) = Dec2BinVec(hex2dec('20'),8);
                obj.DDSCurrentState(DDSList(DDSIndex)).IOPortBuffMap(hex2dec('25')+1,:) = Dec2BinVec(hex2dec('80'),8);

                obj.DDSCurrentState(DDSList(DDSIndex)).IntRegMap = ...
                    obj.DDSCurrentState(DDSList(DDSIndex)).IOPortBuffMap;

            end
        end

        function GenDDSFSKState(obj,DDSNum,value)
            % Sets the logical value of the DDSNum DDS FSK leg.
            % 1 instructions lines.
            if  ((DDSNum>obj.NumOfDDS)||(DDSNum<1)||(round(DDSNum)~=DDSNum))
                error('Wrong DDS number');
            elseif ~((value==0)||(value==1))
                error('Wrong FSK value');
            else
                if isempty(obj.DDSCurrentState)
                    flagVec = [0 0 1 0];
                    obj.DDSCurrentState(DDSNum).LegsValues = flagVec;
                else
                    flagVec = obj.DDSCurrentState(DDSNum).LegsValues;
                end
                flagVec(2) = value;
                obj.code(obj.currentline,:) = ...
                    [9 DDSNum bin2dec(char(fliplr(flagVec)+48)) 0];
                obj.currentline=obj.currentline+1;
                obj.DDSCurrentState(DDSNum).LegsValues = flagVec;
            end
        end

        function GenDDSWRBPulse(obj,DDSNum)
            % Sends a WRB (write bit) pulse to the DDSNum DDS. When applied
            % the pulse orders the DDS to transfer the values from the
            % address/data bus to its' internal buffers. The pulse is
            % active on 0 logic level.
            if (DDSNum>obj.NumOfDDS)||(DDSNum<1)||(round(DDSNum)~=DDSNum)
                error('Wrong DDS number');
            else
                if isempty(obj.DDSCurrentState(DDSNum).LegsValues)
                    flagVec = [0 0 1 0];
                    obj.DDSCurrentState(DDSNum).LegsValues = flagVec;
                else
                    flagVec = obj.DDSCurrentState(DDSNum).LegsValues;
                end
%                 flagVec = obj.DDSCurrentState(DDSNum).LegsValues;
                flagVec(3) = 0;
                obj.code(obj.currentline,:) = ...
                    [9 DDSNum bin2dec(char(fliplr(flagVec)+48)) 0];
                flagVec(3) = 1;
                obj.currentline=obj.currentline+1;
                obj.GenPause(0.05);
                obj.code(obj.currentline,:) = ...
                    [9 DDSNum bin2dec(char(fliplr(flagVec)+48)) 0];
                obj.code(obj.currentline+1,:) =[ 0 0 0 0];
                obj.currentline=obj.currentline+2;


                % updating the generators IO buffer map
                obj.DDSCurrentState(DDSNum).IOPortBuffMap...
                    (BinVec2Dec(obj.DDSBusCurrentAddress)+1,:) = ...
                    obj.DDSBusCurrentData;
            end
        end

        function GenDDSIOUDPulse(obj,DDSNum)
            % Sends a IOUD (IO update) pulse to the DDSNum DDS. When applied
            % the pulse orders the DDS to transfer information from the
            % buffers to the internal registers, and by that, to update the
            % DDS operational values. The pulse is active on 0 logic level.
            if (DDSNum>obj.NumOfDDS)||(DDSNum<1)||(round(DDSNum)~=DDSNum)
                error('Wrong DDS number');
            else
                flagVec = obj.DDSCurrentState(DDSNum).LegsValues;
                flagVec(4) = 1;
                obj.code(obj.currentline,:) = ...
                    [9 DDSNum bin2dec(char(fliplr(flagVec)+48)) 0];
                flagVec(4) = 0;
                obj.currentline=obj.currentline+1;
                % wait 4 clock cycles
                obj.GenPause(0.1);
                obj.code(obj.currentline,:) = ...
                    [9 DDSNum bin2dec(char(fliplr(flagVec)+48)) 0];
                obj.currentline=obj.currentline+1;

                % transfering the data between the two internal maps.
                obj.DDSCurrentState(DDSNum).IntRegMap = ...
                    obj.DDSCurrentState(DDSNum).IOPortBuffMap;
            end
        end

        function GenDDSPushParametersToBase(obj)
            % Saves the DDS records from the object parametes to the base.
            DDSRecord.DDSCurrentState = obj.DDSCurrentState;
            DDSRecord.DDSBusCurrentAddress = obj.DDSBusCurrentAddress;
            DDSRecord.DDSBusCurrentData = obj.DDSBusCurrentData;

            assignin('base','DDSRecord',DDSRecord);

        end

        function GenDDSPullParametersFromBase(obj)
            % Pulls the DDS records from the base to the object parametes.
            if evalin ('base','exist(''DDSRecord'')')
                DDSRecord = evalin('base','DDSRecord');
                obj.DDSCurrentState = DDSRecord.DDSCurrentState;
                obj.DDSBusCurrentAddress = DDSRecord.DDSBusCurrentAddress;
                obj.DDSBusCurrentData = DDSRecord.DDSBusCurrentData;
            else
                for DDSIndex = 1:obj.NumOfDDS
                    obj.DDSCurrentState(DDSIndex).IntRegMap = zeros(41,8);
                    obj.DDSCurrentState(DDSIndex).IOPortBuffMap = zeros(41,8);
                    obj.DDSCurrentState(DDSIndex).LegsValues = zeros(1,4);
                end
                obj.DDSBusCurrentAddress = zeros(1,6);
                obj.DDSBusCurrentData = zeros(1,8);
            end
        end

        %--------------- DDS high instructions. ---------------
        function GenDDSInitialization(obj,DDSNum,modeNum)
            % Initialize the DDS for operation in one of its' modes.
            % DDSNum - Integer, the DDS serial number.
            % modeNum - Integer: 0 - single tone, 1 - FSK 2 - Ramped FSK 3
            % - chirp 4 - BPSK.
            % 32 instructions lines.

            if (DDSNum>obj.NumOfDDS)||(DDSNum<1)||(round(DDSNum)~=DDSNum)
                error('Wrong DDS number');
            end
            if (modeNum>4)||(modeNum<0)||(round(modeNum)~=modeNum)
                error('Wrong mode number');
            end

            %             % setting the PLL multiplication ratio to 10
            %             obj.GenDDSBusState('1e','4a');
            %             obj.GenDDSWRBPulse(DDSNum);
            %
            % disabling OSK (switch to internal)
            obj.GenDDSBusState('20','10');
            obj.GenDDSWRBPulse(DDSNum);

            % disabling the internal IOUD clock and setting the DDS mode.
            modeBinVec = double(dec2bin(modeNum))-48;
            dataWord = zeros(1,8);
            dataWord((end-length(modeBinVec)):(end-1)) = modeBinVec;

            obj.GenDDSBusState('1f',dec2hex(bin2dec(char(dataWord+48))));
            obj.GenDDSWRBPulse(DDSNum);
            obj.GenDDSIOUDPulse(DDSNum);

            % Updating the DDS PLL ratio.
            current1ELine = [0 1 0 fliplr(dec2binvec(obj.DDSPLLRatio,5))];
            obj.GenDDSBusState('1E',dec2hex(BinVec2Dec(current1ELine)));
            obj.GenDDSWRBPulse(DDSNum);
            obj.GenDDSIOUDPulse(DDSNum);
            
            % Enable TTL output in DDS 2 
            if (DDSNum==2)
                obj.GenDDSBusState('1D',dec2hex(0));
                obj.GenDDSWRBPulse(DDSNum);
                obj.GenDDSIOUDPulse(DDSNum);
            end
        end

        function GenDDSFrequencyWord(obj,DDSNum,wordNum,freqValue)
            % Sets one of the frequency words (out of the two) of the
            % defined DDS.
            % DDSNum - Integer, the DDS serial number.
            % wordNum - [1 or 2] the word number (each DDS has two frequency words).
            % freqValue - the desired frequency in MHz.
            % 26 insructions lines.
            if (DDSNum>obj.NumOfDDS)||(DDSNum<1)||(round(DDSNum)~=DDSNum)
                error('Wrong DDS number');
            end
            if (wordNum>2)||(wordNum<1)||(round(wordNum)~=wordNum)
                error('Wrong frequency word number');
            end
            if (freqValue>obj.DDSFrequencyLimit(2))||(freqValue<obj.DDSFrequencyLimit(1))
                error('Frequency out of range');
            end
            % calculating the frequency word considering the reference
            % clock.
            updatedFreqValue = freqValue*obj.DDSInternalClockFreq*10/obj.DDSPLLRatio/obj.DDSExternalFrequency;
            freqMat = Number2Byte(updatedFreqValue*1e12,6);

            % calculating the address words
            decAddressValue = [ 4 5 6 7 8 9];
            if wordNum==1
                hexAddressValue = dec2hex(decAddressValue);
            else
                hexAddressValue = dec2hex(decAddressValue+6);
            end

            % updating the DDS
            for index = 1:3 % updating only 3 bytes of the word
                obj.GenDDSBusState(hexAddressValue(index,:),...
                    dec2hex(BinVec2Dec(freqMat(index,:))));
                obj.GenDDSWRBPulse(DDSNum);
            end

            obj.GenDDSIOUDPulse(DDSNum);
        end

        function GenDDSPhaseWord(obj,DDSNum,wordNum,phaseValue)
            % Sets one of the phase words (out of the two) of the
            % defined DDS.
            % DDSNum - Integer, the DDS serial number.
            % wordNum - [1 or 2] the word number.
            % phaseValue - the desired phase in radians [0 to 2pi].

            if (DDSNum>obj.NumOfDDS)||(DDSNum<1)||(round(DDSNum)~=DDSNum)
                error('Wrong DDS number');
            end
            if (wordNum>2)||(wordNum<1)||(round(wordNum)~=wordNum)
                error('Wrong Phase word number');
            end
            % put in comment because a negative phase value is use to take the phase
            % word from the internal FPGA variabe AI1toPhase :
%                         if (phaseValue>(2*pi))||(phaseValue<0)
%                             error('Phase out of range');
%                         end
%                         decAddressValue = [ 0 1 ];
%                         if wordNum==1
%                             hexAddressValue = dec2hex(decAddressValue);
%                         else
%                             hexAddressValue = dec2hex(decAddressValue+2);
%                         end
%             
%                         % calculating the phase words
%                         tempPhaseVec = double(dec2bin(phaseValue/2/pi*(2^14-1)))-48;
%                         binPhaseVec = zeros(1,16);
%                         binPhaseVec((end-length(tempPhaseVec)+1):(end)) = tempPhaseVec;
%                         phaseMat = reshape(binPhaseVec,8,2)';
%                         for index = 1:2
%                             obj.GenDDSBusState(hexAddressValue(index,:),...
%                                 dec2hex(bin2dec(char(phaseMat(index,:)+48))));
%                             obj.GenDDSWRBPulse(DDSNum);
%                         end


            % calculating the phase words use only 6 of the 14 bits
            if wordNum==1
                hexAddressValue = dec2hex(0);
            else
                hexAddressValue = dec2hex(2);
            end

            if (phaseValue>=0)
                phaseData = double(uint8(phaseValue/2/pi*2^6));
            else
                phaseData = 256; % this should trig the FPGA to take RegD as data
            end
            obj.GenDDSBusState(hexAddressValue,dec2hex(phaseData));
            obj.GenDDSWRBPulse(DDSNum);
            obj.GenDDSIOUDPulse(DDSNum);
        end

        function GenDDSSweepParameters (obj,DDSNum,DFW,dwellPeriod)
            % Setes sweep parameters
            % DFW - Delta frequency word in MHz.
            % dwellPeriod - Single frequency step dwell time in micro-sec.
            % 78 instructions lines.

            % Configuring the delta frequency word.
            updatedDFW = DFW*obj.DDSInternalClockFreq*10/obj.DDSPLLRatio/obj.DDSExternalFrequency;

            deltaBinMat = Number2Byte(updatedDFW*1e12,6);
            deltaAddHexMat = dec2hex([16:21]);
            % updating the DDS
            for index = 1:6
                obj.GenDDSBusState(deltaAddHexMat(index,:),...
                    dec2hex(BinVec2Dec(deltaBinMat(index,:))));
                obj.GenDDSWRBPulse(DDSNum);
            end

            % Configuring the update clock ramp rate.
            sysClockPeriod = 1/obj.DDSExternalFrequency/1e6/obj.DDSPLLRatio;
            updateClock = round(dwellPeriod*1e-6/sysClockPeriod)-1;

            if (updateClock>(2^20))||(updateClock<1)
                error('Too many clock ticks');
            else
                rampRateBinMat = Number2Byte(updateClock,3);
                rampRateAddHexMat = dec2hex([26:28]);
                for index = 1:3 % updating only 4 bytes of the word
                    obj.GenDDSBusState(rampRateAddHexMat(index,:),...
                        dec2hex(BinVec2Dec(rampRateBinMat(index,:))));
                    obj.GenDDSWRBPulse(DDSNum);
                end
            end
            obj.GenDDSIOUDPulse(DDSNum);


            % Toggling ACC2 bit
            current1FLine = obj.DDSCurrentState(DDSNum).IntRegMap(32,:);

            % Toggling up
            current1FLine(2) = 1;
            obj.GenDDSBusState('1F',dec2hex(BinVec2Dec(current1FLine)));
            obj.GenDDSWRBPulse(DDSNum);
            obj.GenDDSIOUDPulse(DDSNum);
            obj.GenPause(2e1);
            % Toggling down
            current1FLine(2) = 0;
            obj.GenDDSBusState('1F',dec2hex(BinVec2Dec(current1FLine)));
            obj.GenDDSWRBPulse(DDSNum);
            obj.GenDDSIOUDPulse(DDSNum);

        end

        function GenDDSIPower (obj,DDSNum,pwr)
            % Sets the output power of the DDS I output.
            % pwr - the output power precentage [%] of the maximal power.

            % setting OSKEN=1, OSKINT=0
            OSKENValue = obj.DDSCurrentState(DDSNum).IntRegMap(33,3);
            OSKINTValue = obj.DDSCurrentState(DDSNum).IntRegMap(33,4);
%             if ~((OSKENValue==1)&&(OSKINTValue==0))
%                 current20Line = obj.DDSCurrentState(DDSNum).IntRegMap(33,:);
%                 current20Line([3 4]) = [1 0];
%                 obj.GenDDSBusState('20',dec2hex(BinVec2Dec(current20Line)));
%                 obj.GenDDSWRBPulse(DDSNum);
%             end
%     

            % setting the proper power value for I output
            value = round(pwr/100*4095);
            freqMat = Number2Byte(value,2);
            decAddressValue = [33 34];
            hexAddressValue = dec2hex(decAddressValue);
            for index = 1:2
                obj.GenDDSBusState(hexAddressValue(index,:),...
                                   dec2hex(BinVec2Dec(freqMat(index,:))));
                obj.GenDDSWRBPulse(DDSNum);
            end
            obj.GenDDSIOUDPulse(DDSNum);
        end
        
        function GenDDSClearACC2 (obj,DDSNum)
            % Resets the phase of DDS DDSNum.
            % Toggling ACC2 bit
            current1FLine = obj.DDSCurrentState(DDSNum).IntRegMap(32,:);

            % Toggling up
            current1FLine(2) = 1;
            obj.GenDDSBusState('1F',dec2hex(BinVec2Dec(current1FLine)));
            obj.GenDDSWRBPulse(DDSNum);
            obj.GenDDSIOUDPulse(DDSNum);
            obj.GenPause(2e1);
            % Toggling down
            current1FLine(2) = 0;
            obj.GenDDSBusState('1F',dec2hex(BinVec2Dec(current1FLine)));
            obj.GenDDSWRBPulse(DDSNum);
            obj.GenDDSIOUDPulse(DDSNum);
        end
     

        function DisplayCode(obj)
            numofline=size(obj.code,1);
            disp('line  command         subcommand              par1       par2');
            disp('--------------------------------------------------------------');
            for i=1:numofline;
                s_command=char(obj.CommandList(obj.code(i,1)+1));
                if (obj.code(i,2)<size(obj.SubcommandList,2))
                    s_subcommand=char(obj.SubcommandList(obj.code(i,1)+1,obj.code(i,2)+1));
                else
                    s_subcommand=['Sub' num2str(obj.code(i,2))];
                end    
                s_par1=obj.code(i,3);
                s_par2=obj.code(i,4);
                disp(sprintf('%5d %-15s %-15s %10d %10d',i,s_command,s_subcommand,s_par1,s_par2));
            end
        end;

        function value = get.codenumoflines(obj)
            value = obj.currentline-1;
        end

    end % methods

end %class