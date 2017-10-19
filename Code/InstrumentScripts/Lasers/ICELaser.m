classdef ICELaser < handle
    %this class represent a laser module in the ICE box.
    
    
    properties
        comport
        s %serial communication variable
        slot %where the current driver card is installed
        T1chan %T1 cooling channel 
        T2chan %T2 cooling channel
        
    end
    
      properties (Dependent)
      LasingStatus
   end
    
    methods
        function obj=ICELaser(comport,slot,T1chan,T2chan)
            obj.s=serial(comport,'BaudRate',115200,'StopBits',1,'Parity','none','timeout',0.5,'Terminator','LF');
            obj.slot=num2str(slot);
            obj.T1chan=num2str(T1chan);
            obj.T2chan=num2str(T2chan);
            obj.comport=comport;
            try
                fopen(obj.s); %open the serial connection
            catch err
                if strcmpi(err.identifier,'MATLAB:serial:fopen:opfailed')
                    warning('Connection already open');
                    fclose(instrfind);
                    fopen(obj.s);
                else
                    warning(['Problem opening serial connection:' err.identifier]);
                end
            end
            
            
        end
        
        function delete(obj)
            fclose(obj.s);
            warning(['serial connection closed in Laser: ' inputname(1)]);
        end
        
        function staus=get.LasingStatus(obj)
            staus=obj.getLaserStat;
        end
        
        
        function boolReturn = boolChck(obj,bool)
            % This function checks if bool is 'on' or 'off' and also
            % capitalize it, i.e 'on' becomes 'On'
            if strcmp(bool, 'on') || strcmp(bool,'On')
                boolReturn = 'On';
            elseif strcmp(bool, 'off') || strcmp(bool,'Off')
                boolReturn = 'Off';
            else
                error('wrong value for bool. must be On/Off');
            end
        end
        
        function resp=sendSerialCommand(obj,varargin)
            command='';
            if strcmpi(obj.s.Status,'closed')
                try
                    fopen(obj.s);
                catch err
%                     warning(['Cannot communicate with laser:' err.identifier]);
                    fclose(instrfind);
                    fopen(obj.s);
                end
            else
                command=strjoin(varargin,' ');
                command = [command char(13)];
                fprintf(obj.s,command);
                resp=fscanf(obj.s);
                resp=resp(1:end-1);
            end
        end
        
        
        
        function laserLockStat = getFreqLockStat(obj)
            %This function checks the quality of the laser lock.
            %The function takes the RMS of the laser error signal, over N=15 measurments with dt = 100ms difference.
            %If the error is above the threshhold of 0.1?(Make sure this is true!!) then is it rejected.
            N = 15; %Number of samples
            dt = 0.1; %pause time
            T = dt*N; %total time of measurment
            error = zeros(1,N);
            fprintf('Calculating RMS. Wait for %f seconds\n', T);
            for n = 1:N
                tmp = obj.getOutput(2); %2 is the output channel for laser error. The returned value is a char array. We want chars 3 to end.
                %                 tmp = str2num(tmp(3:end));
                error(1,n) = str2double(tmp);
                pause(dt);
            end
            rmsError = rms(error);
            if rmsError > 0.1
                fprintf(['RMS error: %f [V]\n' inputname(1) ' Laser Lock failed\n'],rmsError);
                laserLockStat=0;
            else
                fprintf(['RMS error: %f [V]\n' inputname(1) ' Laser Lock success!\n'],rmsError);  
                laserLockStat=1;
            end
        end
        %%  temp control board function
        
        function success=comTest(obj)
            stat=obj.sendSerialCommand('#Status');
            if (strcmp(stat(1:2),'On'))
                success=1;
            else
                success=0;
            end
            
            
        end
        
        function stat=getTempLockServoStat(obj,chan)
            %             this function checks if we are servoing temp in
            %             specified chan and checks for both if none
            %             specified
           
            obj.sendSerialCommand('#Slave 1');
            if nargin ==1
            t1stat=obj.sendSerialCommand(['Servo? ' obj.T1chan]);
            
            t2stat=obj.sendSerialCommand(['Servo? ' obj.T2chan]);
            
            disp(['t1 stat is ' num2str(t1stat)]);
            disp(['t2 stat is ' num2str(t2stat)]);
            else
                stat=obj.sendSerialCommand(['Servo? ' num2str(chan)]);
                disp(['chan ' num2str(chan) ' stat is ' num2str(stat)]);
            end
        end
        
        function stat=getTempLockStat(obj)
            %             this function checks if our error signal on temp is tight
            %             enough to turn on a laser. and also checks servoing.
            % Check if temp servo is on
            if obj.getTempLockServoStat(obj.T2chan) == 0
                disp('Temp Servo is not engaged');
                stat = 0;
                return
            end
            
            %Check if Terror is less then 50mK. if Not then temp is not stable
            if abs(str2double(obj.tempError(obj.T2chan))) > 0.05
                disp('Temperture is not stable')
                stat = 0;
                return
            end
            stat = 1;
        end
        
        function stat=setTemp(obj,setTemp)
            obj.sendSerialCommand('#Slave 1');
            stat=obj.sendSerialCommand(['TempSet ' obj.coolingChan ' ' num2str(setTemp)]);
            
        end
        
        function stat=setTempLock(obj,chan,bool)
            %          enable/disable the temp lock loop on channel chan. (bool 'On'/'Off')
            bool = obj.boolChck(bool); %Check that bool is 'on' or 'off'
            obj.sendSerialCommand('#Slave 1');
            stat=obj.sendSerialCommand(['Servo ' num2str(chan) ' ' bool]);
            
        end
        
        function stat=tempError(obj,chan)
            %          enable/disable the temp lock loop on channel chan. (bool 'On'/'Off')
            obj.sendSerialCommand('#Slave 1');
            stat=obj.sendSerialCommand(['TError? ' num2str(chan)]);
            
            
        end
        
        function temp = getTemp(obj)
            %          Returns the set temperature of chanel chan
            obj.sendSerialCommand('#Slave 1');
            temp=obj.sendSerialCommand(['Temp? ' obj.coolingChan]);
            
        end
        
        function stat=setTempMin(obj,setMin)
            obj.sendSerialCommand('#Slave 1');
            stat=obj.sendSerialCommand(['TempMin ' obj.coolingChan ' ' num2str(setMin)]);
            
        end
        
        function stat=getTempMin(obj)
            fopen(obj.s);
            fprintf(obj.s,'#Slave 1');
            fprintf(obj.s,['TempMin? ' obj.coolingChan]);
            stat=fscanf(obj.s);
            fclose(obj.s);
        end
        
        function stat=getTempGain(obj)
            fopen(obj.s);
            fprintf(obj.s,'#Slave 1');
            fprintf(obj.s,['Gain? ' obj.coolingChan]);
            stat=fscanf(obj.s);
            fclose(obj.s);
        end
        
        function stat=setTempGain(obj,gain)
            fopen(obj.s);
            fprintf(obj.s,'#Slave 1');
            fprintf(obj.s,['Gain ' obj.coolingChan ' ' num2str(gain)]);
            stat=fscanf(obj.s);
            fclose(obj.s);
        end
        
        function stat=setMaxTECcurr(obj,curr)
            fopen(obj.s);
            fprintf(obj.s,'#Slave 1');
            fprintf(obj.s,['MaxCurr ' obj.coolingChan ' ' num2str(curr)]);
            stat=fscanf(obj.s);
            fclose(obj.s);
        end
        
        function stat=getMaxTECcurr(obj)
            fopen(obj.s);
            fprintf(obj.s,'#Slave 1');
            fprintf(obj.s,['MaxCurr? ' obj.coolingChan]);
            stat=fscanf(obj.s);
            fclose(obj.s);
        end
        
        %% laser control board functions
        function stat=getLaserStat(obj)
            obj.sendSerialCommand(['#Slave ' obj.slot]);
            stat=obj.sendSerialCommand('Laser?');                    
        end
        
        function stat=setLaserStat(obj,bool)
            %This function turnes on\off the laser. Before it does this it checks
            %if the temp of the laser is stabliezd.
       
            bool = obj.boolChck(bool); %Check that bool is 'on' or 'off'
            
            obj.sendSerialCommand(['#Slave ' obj.slot]);
            if strcmpi(bool,'off')
                stat=obj.sendSerialCommand(['Laser ' bool]);
            else
                if obj.getTempLockStat == 0
                    error('Temp unlocked. cannot turn on laser.');
                else
                    obj.sendSerialCommand(['#Slave ' obj.slot]);
                    stat=obj.sendSerialCommand(['Laser ' bool]);
                end
                
            end
            
            
            
            
            
        end
        
        function stat=getCurrSet(obj)
            
            obj.sendSerialCommand(['#Slave ' obj.slot]);
            stat=obj.sendSerialCommand('CurrSet?');
            
        end
        
        function stat=setCurr(obj,Current)
            
            obj.sendSerialCommand(['#Slave ' obj.slot]);
            stat=obj.sendSerialCommand(['CurrSet ' num2str(Current)]);
            
        end
        
        function stat=getCurrLim(obj)
            obj.sendSerialCommand(['#Slave ' obj.slot]);
            stat=obj.sendSerialCommand('CurrLim?');
           
        end
        
        function stat=setCurrLim(obj,CurrentLim)
            obj.sendSerialCommand(['#Slave ' obj.slot]);
            stat=obj.sendSerialCommand(['CurrLim ' num2str(CurrentLim)]);
            
        end
        
        %% offset lock functions
        
        function N=getMultiplyer(obj)
            obj.sendSerialCommand(['#Slave ' obj.slot]);
            N=str2double(obj.sendSerialCommand('N?'));
            
            
            
        end
        
        function N=setPhaseLockMultiplyer(obj,mult)
            if (mult~=8 && mult~=16 && mult~=32 && mult~=64)
                error('Wrong multiplyer value!');
            end
            
            obj.sendSerialCommand(['#Slave ' obj.slot]);
            N=obj.sendSerialCommand(['N ' num2str(mult)]);
            
        end
        
        function invertStat=getInvertBool(obj)
            obj.sendSerialCommand(['#Slave ' obj.slot]);
            obj.sendSerialCommand('Invert?');
            
            
        end
        
        function invertStat=setInvert(obj, bool)
            
            bool = obj.boolChck(bool); %Check that bool is 'on' or 'off'
            
            obj.sendSerialCommand(['#Slave ' obj.slot]);
            obj.sendSerialCommand(['Invert ' bool]);
            
            
            
        end
        
        function intRefStat=getIntRefStatus(obj)
            %             is the laser using internal clock reference?
            obj.sendSerialCommand(['#Slave ' obj.slot]);
            intRefStat=obj.sendSerialCommand('IntRef?');
            
        end
        
        function intRefStat=setIntRef(obj, bool)
            %             turn internal clock ref on or off
            bool = obj.boolChck(bool); %Check that bool is 'on' or 'off'
            obj.sendSerialCommand(['#Slave ' obj.slot]);
            intRefStat=obj.sendSerialCommand(['IntRef ' bool]);
            
        end
        
        function intFreq=getIntFreq(obj)
            %This function returns the inturnal vco frequency in MHz. Remember
            %that the actual signal in the PLL is multiplied by the multiplier.
            obj.sendSerialCommand(['#Slave ' obj.slot]);
            intFreq=obj.sendSerialCommand('IntFreq?');
            
        end
        
        function intRefStat=setIntFreq(obj, freq)
            %This function sets the inturnal vco frequency in MHz. Remember
            %that the actual signal in the PLL is multiplied by the multiplier.
            obj.sendSerialCommand(['#Slave ' obj.slot]);
            intRefStat=obj.sendSerialCommand(['IntFreq ' num2str(freq)]);
        end
        
        function laserServo=getLaserServoStat(obj)
            obj.sendSerialCommand(['#Slave ' obj.slot]);
            laserServo=obj.sendSerialCommand('Servo?');
            
        end
        
        function laserServo=setLaserServoStat(obj, bool)
            bool = obj.boolChck(bool); %Check that bool is 'on' or 'off'
            
            
            
            obj.sendSerialCommand(['#Slave ' obj.slot]);
            laserServo=obj.sendSerialCommand(['Servo ' bool]);
            
          
            if strcmp(bool,'On')
                if obj.getFreqLockStat == 0
                    obj.sendSerialCommand(['Servo ' 'Off']);
           
                    error('Lock failed!')
                end
            end
            
            
            
        end
    
    
    
    function val=getOutput(obj,outputChan)
    %This function returnes the value of the output channel with respect to the following table:
    % 1 - Servo Out
    % 2 - Error Signal
    % 3 - NA
    % 4 - NA
    % 5 - Laser Current (1V = 1A)
    % 6 - +2.5V Ref
    % 7 - NA
    % 8 - Ground
    
    obj.sendSerialCommand(['#Slave ' obj.slot]);
    val=obj.sendSerialCommand(['ReadVolt ' num2str(outputChan)]);
    
    end
    
end
end






