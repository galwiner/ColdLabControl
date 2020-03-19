classdef CodeGenerator < handle
    % the CodeGen class
    %
    %
    %---------------------------------------------------------------
    
    properties(Constant = true)
        
        CommandList =  {'Do nothing'  ,'Analog out'  ,'Digital out',...
            'Photon count','Register'    ,'If'         ,...
            'Goto T/F'    ,'Push to FIFO','End program','GenRamp','GenLoadTrig','GenStartAnalogRamp','GenStartCoolingPowerRamp'};
        SubcommandList ={'NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA';... %0
            'AOO','AO1','AO2','AO3','AO4','AO5','AO6','AO7','AO8','AO9','AO10','AO11','AO12','NA','NA','NA','NA','NA','NA';... %1
            'DOO','DO1','DO2','DO3','DO4','DO5','DO6','DO7','DO8','DO9','DO10','DO11','DO12','DO13','DO14','DO15','DO16','DO17','DO18';... %2
            'PMT1+PMT2->RegA','PMT1->RegA','PMT2->RegA','reset','PMT1&PMT2>RegA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA';... %3
            'par1->RegA','par1->RegB','par1->RegC','Inc RegC','Inc RegA','RegB->RegC','RegB+flag[0]->RegB','Pause','RegB+RegA->RegB','AI1toPhase->RegD','(RegD+v1)*2^v2l*v2h->RegD','pauseMemoryBlock','forStart','forEnd','NA','NA','NA','NA','NA';... %4
            'RegA=par1','RegB>par1','RegC=par1','RegB>RegC','ExtTrig rising edge','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA';... %5
            'NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA';... %6
            'RegA','RegB','RegC','PhotonPhase','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA';... %7
            'NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA';... %8
            'ON','OFF','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA';...%9
            'NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA';}; %10
        
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
        end
        
        function GenSeq(obj,arrayofpulses,varargin)
            % This method generate the code of pulse sequence with all
            % the pulse parameter setting but WITHOUT LOGIC
            
            %The first stage create a time line from the pules array
            % timeline structure [ time channel action parameter]
            timeline=Pulse.Sequence2TimeLine(arrayofpulses);
            numoflines=size(timeline,1);
            
            %lasteventtime keeps track of the last event that occured. if
            %we pass a single positive integer after arrayofpulses, this is set to
            %the time in the past (negative) when the last event occured.
            %if we don't lasteventtime simply gets set to 0.
            if (size(varargin,2)==1)
                
                lasteventtime=-varargin{1};
            else
                lasteventtime=0;
            end
            
            %the main stage that compiles the timeline to FPGA code
            for i=1:numoflines
                % insert wait until new event, unless the previus evvent
                % was forEnd, at which case insert 1 clock cacle.
                %this change was done on 18/07/19. to revert back,
                %un-comment the next line, and comment the following 5
                %lines
%                 GenPause(obj,(timeline(i,1)-lasteventtime)/40);
                if i~=1&&timeline(i-1,3)==7&&strcmpi(PulseChannelInfo(timeline(i-1,2),'ChannelType'),'forEnd')
                    GenPause(obj,1/40);
                else
                GenPause(obj,(timeline(i,1)-lasteventtime)/40);
                end
                lasteventtime=timeline(i,1);
                channel=timeline(i,2);
                operation=timeline(i,3);
                parameter=timeline(i,4);
                channeltype=PulseChannelInfo(channel,'ChannelType');
                switch operation
                    case 1 %---------------- switch ON -----------------------
                        % set digital channel to on
                        switch channeltype
                            case {'VCO','Dig'}
                                %command 2, subcommand ## is the CPU
                                %implementation of Digital Output. we then
                                %pass the OnIs param to this cpu command,
                                %thus turning the dig channel on. the last
                                %param is 0 because this command does not
                                %take further arguments.
                                obj.code(obj.currentline,:)=...
                                    [ 2 , PulseChannelInfo(channel,'DigitalSwitch'),PulseChannelInfo(channel,'OnIs'), 0];
                                obj.currentline=obj.currentline+1;
                            case {'PMT'}
                                % reset PMT counters  command=3 subcommand = 3
                                obj.code(obj.currentline,:)=[ 3 , 3 , 0 , 0];
                                obj.currentline=obj.currentline+1;
                            case 'Analog'
                                % switch on analog channel
                                obj.code(obj.currentline,:)=[1,PulseChannelInfo(channel,'AnalogSwitch'),parameter,0];
                                obj.currentline=obj.currentline+1;
                            otherwise
                                error(' No Switch ON for this ChannelType');
                        end
                    case 2 % ---------------- switch OFF ----------------------
                        switch channeltype
                            case {'VCO','Dig'}
                                obj.code(obj.currentline,:)=...
                                    [ 2 , PulseChannelInfo(channel,'DigitalSwitch'),~PulseChannelInfo(channel,'OnIs'), 0];
                                obj.currentline=obj.currentline+1;
                            case 'PMT'
                                % set RegB to 0
                                obj.code(obj.currentline,:) = [ 4 , 1 , 0 , 0];
                                % the command for handeling PMT is 3
                                % subcommand = 1 -> add only photon counter 1 to regB
                                % subcommand = 2 -> null
                                obj.code(obj.currentline+1,:)=[ 3 , PulseChannelInfo(channel,'Operation'), 0 , 0];
                                % Push RegB to FIFO :Command 7 subcommand 1
                                obj.code(obj.currentline+2,:) = [ 7 , 1 , 0 , 0];
                                obj.currentline=obj.currentline+3;
                                obj.numofreadout=obj.numofreadout+1;
                            case 'Analog'
                                % switch off analog channel
                                obj.code(obj.currentline,:)=[1,PulseChannelInfo(channel,'AnalogSwitch'),parameter,0];
                                obj.currentline=obj.currentline+1;
                                
                            otherwise
                                error(' No Switch OFF for this ChannelType'); %this used to say switch ON. i think it was wrong. 19/10/15
                        end      
                    case 3 % -------------- set frequency ---------------------
                        switch channeltype
                            case 'VCO'
                                % SetFreqAddress relate to the Analogout channel on
                                % the fpga that set by the subcommand.
                                % command is set to 1 that handle analog out
                                % get the real value that represent the freq
                                freq=parameter;
                                voltage=eval(PulseChannelInfo(channel,'Freq2Value')); %IF YOU ARE USING EVAL YOU ARE DOING IT WRONG
                                obj.code(obj.currentline,:)=...
                                    [ 1 , PulseChannelInfo(channel,'SetFreqAddress') , voltage , 0];
                                obj.currentline=obj.currentline+1;
                            otherwise
                                error(' invalid channel type for set freq ');
                        end
                    case 4 %---------------- set Analog Ramp ------------------------
                        switch channeltype
                            case {'Analog'}
                                val=de2bi(parameter,31);
                                param1=bi2de(val(1:16)); %this is the ramp step size 
                                param2=bi2de(val(17:31));%this is the end current param 
                                obj.code(obj.currentline,:)=[9,1,param1,param2];
                                obj.currentline=obj.currentline+1;
                            otherwise
                                error(' invalid Channel type for analog ramp ');
                        end
                     case 5 %---------------- set cooling intensity Ramp ------------------------
                        switch channeltype
                            case {'Analog'}
                                val=de2bi(parameter,31);
                                param1=bi2de(val(1:16)); %this is the ramp step size 
                                param2=bi2de(val(17:31));%this is the end voltage param 
                                obj.code(obj.currentline,:)=[9,2,param1,param2];
                                obj.currentline=obj.currentline+1;
                            otherwise
                                error(' invalid Channel type for analog ramp ');
                        end
                    case 6 % ---------------- set amplitude ----------------------
                        switch channeltype
                            case {'VCO'}
                                obj.code(obj.currentline,:)=...
                                    [ 1 , PulseChannelInfo(channel,'SetAmpAddress'),parameter, 0];
                                obj.currentline=obj.currentline+1;
                            otherwise
                                error(' invalid Channel type for set amplitude');
                        end
                    case 7 % ---------------- for loop operations ----------------------
                        switch channeltype
                            case {'forStart'}
                                
                                obj.code(obj.currentline,:) = [ 4 ,12,parameter, 0];
                                
                                obj.currentline=obj.currentline+1;
                            case {'forEnd'}
                                c=typecast(int32(parameter-1),'int16');
                                obj.code(obj.currentline,:) = [ 4 ,13,c(1),c(2)];
                                obj.code(obj.currentline+1,:) = [ 0 ,0,0, 0];
                                obj.currentline=obj.currentline+2;
                            otherwise
                                error(' invalid Channel type for set amplitude');
                        end
                    otherwise %-------- any other operation -------------------
                        
                end %switch
                
            end %for loop
        end % SegGen
        
        function GenLodingMeasTrig(obj)
          %sets the AI0 channal measurement trig to high
            obj.code(obj.currentline,:)=[10 0 0 0];
            obj.currentline=obj.currentline+1;
        end
        
        function GenSetAO(obj,ChStr,Var)
            %             this function generates analog output commands in the code
            %             matrix. only analog output chnnels that are implemented in
            %             hardware can be cases in the ChStr switch block.
            switch ChStr
                case 'AO0'
                    obj.code(obj.currentline,:)=[1 0 Var 0];
                    obj.currentline=obj.currentline+1;
                case 'AO1'
                    obj.code(obj.currentline,:)=[1 1 Var 0];
                    obj.currentline=obj.currentline+1;
                case 'AO3'
                    obj.code(obj.currentline,:)=[1 3 Var 0];
                    obj.currentline=obj.currentline+1;
                case 'AO4'
                    obj.code(obj.currentline,:)=[1 4 Var 0];
                    obj.currentline=obj.currentline+1;
                otherwise
                    disp('Unknown method');
            end
        end
        
        function GenRegOp(obj,cmdStr,cmdVar1,cmdVar2)
            %             this function is
            if ~exist('cmdVar1')
                cmdVar1=0;
            end
            if ~exist('cmdVar2')
                cmdVar2=0;
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
                    %                 case {'RegD='} %RegD=cmdVar(1): command 4 subc 11, par1=cmdVar(1)
                    %                     obj.code(obj.currentline,:)=[4 11 cmdVar1 0];
                    %                     obj.currentline=obj.currentline+1;
                case {'RegA=+1'} %RegC=RegC+1: command 4 subc 4
                    obj.code(obj.currentline,:)=[4 4 0 0];
                    obj.currentline=obj.currentline+1;
                case {'RegC=+1'} %RegC=RegC+1: command 4 subc 3
                    obj.code(obj.currentline,:)=[4 3 0 0];
                    obj.currentline=obj.currentline+1;
                case {'RegD=AI1+par1'} %RegD=AI1toPhase : command 4 subc 9
                    obj.code(obj.currentline,:)=[4 9 cmdVar1 0];
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
                case {'RegD=RegD*par2*2^par1'} %command 4, subc 10,2 pars
                    obj.code(obj.currentline,:)=[4 10 cmdVar1 cmdVar2];
                    obj.currentline=obj.currentline+1;
                    
                otherwise
                    disp('Unknown method.')
            end
        end
        
        function GenPause(obj,c)
            % c is in microseconds
            % Employes command 4,7 of the pigeon
            if c>60e6
                fprintf('warning GenPuase was wait time of > minute\n in code line %d\n',c*1e-6,obj.currentline);
                dbstop;
                return;
            elseif c>10e6
                fprintf('warning GenPuase was wait time of %.3f [s]\n',c*1e-6);
            end
            c=c*40; % translate to clock cycle
            if (c>=1)
                c=typecast(int32(c-1),'int16');
                obj.code(obj.currentline,:)=[4,7,c(1),c(2)];
                obj.currentline=obj.currentline+1;
            end
            
        end
        function GenStartAnalogRamp(obj,stepsToAdd,finalCurent)
            obj.code(obj.currentline,:)=[9,1,int16(stepsToAdd),int16(finalCurent)];
            obj.currentline=obj.currentline+1;
        end
        
        function GenPauseMemoryBlock(obj)
            %command 4, subc 11, no pars
            % generate puase with sleep counter = memoryBlock[RegC]
            obj.code(obj.currentline,:)=[4 11 0 0];
            obj.currentline=obj.currentline+1;
        end
        
        function GenWaitExtTrigger(obj)
            obj.code(obj.currentline,:)=[4,7,40*5,0];
            % generate if statement is external trigger rising edge
            obj.code(obj.currentline+1,:)=[5,4,0,0];
            % generate conditional goto
            obj.code(obj.currentline+2,:)=[6,0,obj.currentline+4,obj.currentline];
            % generate empty line due to goto
            obj.code(obj.currentline+3,:)=[0,0,0,0];
            obj.currentline=obj.currentline+4;
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
        
        function GenRepeatEnd(obj,expression,c)
            % the end statement matching the GenFor
            startline=obj.stack.Pop;
            % generate if statement
            switch expression
                case 'RegB>0'
                    obj.code(obj.currentline,:)=[5,1,0,0];
                case 'RegA>'
                    obj.code(obj.currentline,:)=[5,5,c,0];
                case 'RegC>'
                    obj.code(obj.currentline,:)=[5,2,c,0];
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
                    % generate if statement RegB=>c :command=5, subcommand=5,par1=c
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
        
        function GenSquareWave(obj,bool,period)
            %start/stop square wave on Connector1/DIO6 with given period in uS
            %if bool is 1, start if book is 0, stop.
            period=40*period; %convert uS to clock cycles
            c=typecast(int32(period-1),'int16');
            obj.code(obj.currentline,:)=[9,bool,c(1),c(2)];
            obj.currentline=obj.currentline+1;
        end
        
        
        function GenFinish(obj)
            % End and reset program. command=8 ...
            obj.code(obj.currentline,:)=[8,0,0,0];
            obj.code(obj.currentline+1,:)=[0,0,0,0];
            obj.currentline=obj.currentline+2;
            obj.code(obj.currentline:end,:)=[];
        end
        
        function DisplayCode(obj)
            global p
            numofline=size(obj.code,1);
            disp('line  command         subcommand              par1       par2');
            disp('--------------------------------------------------------------');
            for i=1:numofline
                s_command=char(obj.CommandList(obj.code(i,1)+1));
                if (obj.code(i,2)<size(obj.SubcommandList,2))
                    s_subcommand=char(obj.SubcommandList(obj.code(i,1)+1,obj.code(i,2)+1));
                else
                    try
                        digSwitchInd = find(p.ct.Switch==obj.code(i,2));
                         chnName= p.ct.PhysicalName(digSwitchInd);
                         s_subcommand = chnName{1};
                    catch
                        s_subcommand=['Sub' num2str(obj.code(i,2))];
                    end
                end
                s_par1=obj.code(i,3);
                s_par2=obj.code(i,4);
                if strcmpi(s_subcommand,'Pause')
                    fprintf('%5d %-15s %-15s %.2f muS\n',i,s_command,s_subcommand,typecast(horzcat(int16(s_par1),int16(s_par2)),'int32')/40);
                else 
                    fprintf('%5d %-15s %-15s %10d %10d\n',i,s_command,s_subcommand,s_par1,s_par2);
                end
            end
        end
        
        function value = get.codenumoflines(obj)
            value = obj.currentline-1;
        end
        
    end % methods
    
end %class
