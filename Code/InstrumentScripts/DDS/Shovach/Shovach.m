classdef Shovach < handle
    %class to represent Meir Alon's 4 channel DDS
    properties
        s
        comport='COM16';
        name='DDS#1'
        freq = zeros(4,1);
        state = strings(1,4);
    end
    
    methods
        function obj = Shovach(comport,DRG,Singlemode,REF1)
            %             obj.s = serial(obj.comport,'BaudRate',9600,'DataBits',8);
            try
                if nargin==0
                    %                     obj.comport='COM16';
                    obj.s = serial(obj.comport,'BaudRate',9600,'DataBits',8);
                    obj.s.Timeout=2;
                    %                     obj.s = tcpip('10.10.10.109');
                    fopen(obj.s);
                    Rubidium_CLOCK_INIT(obj,1);
                    pause(1)
                    %                     SHOVACH_INIT_1(obj,0,1,1);
                    %                     SHOVACH_INIT_2(obj,0,1,1);
                    %                     SHOVACH_INIT_3(obj,0,1,1);
                    %                     SHOVACH_INIT_4(obj,0,1,1);
                    %                     fclose(obj.s);
                    if exist('D:\Box Sync\Lab\ExpCold\ControlSystem\Code\Configurations\lastKnownShovachFreqs.mat','file')
                        load('D:\Box Sync\Lab\ExpCold\ControlSystem\Code\Configurations\lastKnownShovachFreqs.mat')
                            obj.freq =ShovachFreqs;
                    else
                        warning('Shovach: Now lastKnownShovachFreqs file found. Setting all shovach.freq to zeros');
                    end
                else
                    obj.comport=comport;
                end
            catch ERR
                ERR
                error('Error in DDS initialization')
            end
            disp('DDS initialized');
            
        end
        
        function setFreq(obj,chan,freq,offset_phase,Adb)
            if nargin==3
                offset_phase=0;
                Adb=0;
            end
            try
                if obj.s.BytesAvailable~=0
                    flushinput(obj.s);
                end
                setShovachFreqInternal(obj,chan,freq,offset_phase,Adb);
            catch err
                fprintf('setFreq error: %s\n',err.message)
                flushinput(obj.s);
                pause(1)
                %                 fclose(obj.s);
                %                 fopen(obj.s);
                setShovachFreqInternal(obj,chan,freq,offset_phase,Adb);
                warning('Error occured in setShovachFreqInternal, reopened serial connection to Shovach');
            end
            fprintf('Shovach: set chan %d freq to %0.3f\n',chan,freq);
            obj.freq(chan) = freq;
            if exist('D:\Box Sync\Lab\ExpCold\ControlSystem\Code\Configurations\lastKnownShovachFreqs.mat','file')
                load('D:\Box Sync\Lab\ExpCold\ControlSystem\Code\Configurations\lastKnownShovachFreqs.mat')
                ShovachFreqs(chan) = freq;
                save('D:\Box Sync\Lab\ExpCold\ControlSystem\Code\Configurations\lastKnownShovachFreqs.mat','ShovachFreqs');
            else
                ShovachFreqs = [obj.getFreq(1),obj.getFreq(2),obj.getFreq(3),obj.getFreq(4)];
                ShovachFreqs(chan) = freq;
                save('D:\Box Sync\Lab\ExpCold\ControlSystem\Code\Configurations\lastKnownShovachFreqs.mat','ShovachFreqs');
            end
        end
        function freq = getFreq(obj,chan)
            freq = obj.freq(chan);
        end
        function setupSweepMode(obj,chan,center,span,time,multiplyer,symmetric,varargin)
            %varargin order: {1} = rampDownTime; {2} = Numner of steps
            if nargin <7
                symmetric = 1;
            end
            N = 1000; %Number of steps
            if nargin == 9 %2 varargin
                N = varargin{2};
            end
            if time/span<2
                warning('If time/span < 2 you risk broadeniong the line');
            end
            
            UP_FREQUENCY = (center + span/2)/multiplyer;
            DOWN_FREQUENCY = (center - span/2)/multiplyer;
            dfP = span*1e6/N/multiplyer; %in Hz
            dtP=time*1e-6/N;%in sec
            if dtP>260e-6
                N = time/260;
                warning('Performing %d frequency steps in DRG',floor(N))
                dtP=time*1e-6/N;%in sec
                dfP = span*1e6/N/multiplyer; %in Hz
            end
            if symmetric==1
                dtN=dtP;
            else
                try
                    dtN = varargin{1}*1e-6/N;%in sec
                catch
                    error('symmetric is not 1 but no rampDownTime found!');
                end
            end
            dfN=dfP;
            fprintf('Set DDS ramp step size to: %.2e Hz/step\n',dfP);
            
            if dfN/dtN < 1
                error('Cannot set sweep rate to more than 1 MHz/ uS!');
            end
            SHOVACH_DRG_INIT(obj,chan,UP_FREQUENCY,DOWN_FREQUENCY,dtP,dtN,dfP,dfN);
            SHOVACH_DRG_INIT(obj,chan,UP_FREQUENCY,DOWN_FREQUENCY,dtP,dtN,dfP,dfN);
            %             for ii = 1:3
            %             pause(2);
            %             SHOVACH_DRG_INIT(obj,chan,UP_FREQUENCY,DOWN_FREQUENCY,dtP,dtN,dfP,dfN);
            %             fprintf('Looping for detDDSSqeepMode. Loop # %d\n',ii)
            %             end
            fprintf('Shovach: set DRG mode in chan %d. Assuming CTL low, and setting freq to be %0.3f\n',chan,DOWN_FREQUENCY);
            obj.freq(chan) = DOWN_FREQUENCY; %set freq (just a matlab info, not on the device) to be DOWN_FREQUENCY. Assuming CTL is low
            if exist('D:\Box Sync\Lab\ExpCold\ControlSystem\Code\Configurations\lastKnownShovachFreqs.mat','file')
                load('D:\Box Sync\Lab\ExpCold\ControlSystem\Code\Configurations\lastKnownShovachFreqs.mat')
                ShovachFreqs(chan) = DOWN_FREQUENCY;
                save('D:\Box Sync\Lab\ExpCold\ControlSystem\Code\Configurations\lastKnownShovachFreqs.mat','ShovachFreqs');
            else
                ShovachFreqs = [obj.getFreq(1),obj.getFreq(2),obj.getFreq(3),obj.getFreq(4)];
                ShovachFreqs(chan) = DOWN_FREQUENCY;
                save('D:\Box Sync\Lab\ExpCold\ControlSystem\Code\Configurations\lastKnownShovachFreqs.mat','ShovachFreqs');
            end
        end
        function setupSweepModeUpFreqDownFreq(obj,chan,UP_FREQUENCY,DOWN_FREQUENCY,time,multiplyer,symmetric,varargin)
            %varargin order: rampDownTime
            if nargin <7
                symmetric = 1;
            end
            span = UP_FREQUENCY-DOWN_FREQUENCY;
            center = (UP_FREQUENCY+DOWN_FREQUENCY)/2;
            if time/span<2
                warning('If time/span < 2 you risk broadeniong the line');
            end
            N = 1000; %Number of steps
            dfP = span*1e6/N/multiplyer; %in Hz
            dtP=time*1e-6/N;%in sec
            if dtP>260e-6
                warning('Performing more then 1000 steps')
                N = time/260;
                dtP=time*1e-6/N;%in sec
                dfP = span*1e6/N/multiplyer; %in Hz
            end
            if symmetric==1
                dtN=dtP;
            else
                try
                    dtN = varargin{1}*1e-6/N;%in sec
                catch
                    error('symmetric is not 1 but no rampDownTime found!');
                end
            end
            dfN=dfP;
            
            fprintf('Set DDS ramp step size to: %.2e Hz/step\n',dfP);
            
            if dfN/dtN < 1
                error('Cannot set sweep rate to more than 1 MHz/ uS!');
            end
            SHOVACH_DRG_INIT(obj,chan,UP_FREQUENCY,DOWN_FREQUENCY,dtP,dtN,dfP,dfN);
            SHOVACH_DRG_INIT(obj,chan,UP_FREQUENCY,DOWN_FREQUENCY,dtP,dtN,dfP,dfN);
            fprintf('Shovach: set DRG mode in chan %d. Assuming CTL low, and setting freq to be %0.3f\n',chan,DOWN_FREQUENCY);
            obj.freq(chan) = DOWN_FREQUENCY; %set freq (just a matlab info, not on the device) to be DOWN_FREQUENCY. Assuming CTL is low
            if exist('D:\Box Sync\Lab\ExpCold\ControlSystem\Code\Configurations\lastKnownShovachFreqs.mat','file')
                load('D:\Box Sync\Lab\ExpCold\ControlSystem\Code\Configurations\lastKnownShovachFreqs.mat')
                ShovachFreqs(chan) = DOWN_FREQUENCY;
                save('D:\Box Sync\Lab\ExpCold\ControlSystem\Code\Configurations\lastKnownShovachFreqs.mat','ShovachFreqs');
            else
                ShovachFreqs = [obj.getFreq(1),obj.getFreq(2),obj.getFreq(3),obj.getFreq(4)];
                ShovachFreqs(chan) = DOWN_FREQUENCY;
                save('D:\Box Sync\Lab\ExpCold\ControlSystem\Code\Configurations\lastKnownShovachFreqs.mat','ShovachFreqs');
            end
            %             for ii = 1:3
            %             pause(2);
            %             SHOVACH_DRG_INIT(obj,chan,UP_FREQUENCY,DOWN_FREQUENCY,dtP,dtN,dfP,dfN);
            %             fprintf('Looping for detDDSSqeepModeUpDown. Loop # %d\n',ii)
            %             end
        end
        function delete(obj)
            fclose(obj.s);
            disp(['serial connection to ' obj.name  ' closed']);
        end
    end
end

