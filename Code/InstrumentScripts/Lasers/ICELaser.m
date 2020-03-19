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
            comport=upper(comport);
            obj.slot=num2str(slot);
            obj.T1chan=num2str(T1chan);
            obj.T2chan=num2str(T2chan);
            obj.comport=comport;
            devices=instrfind('Port',comport); %This gets all the serial objects with port = comport
            if isempty(devices)
                obj.s=serial(comport,'BaudRate',115200,'StopBits',1,'Parity','none','timeout',0.5,'Terminator','LF');
                fopen(obj.s);
                devices=instrfind('Port',comport); %This gets all the serial objects with port = comport
            end
            if ~any(strcmpi(devices.Status,'open')) %Check if there is an open serial connection for comport. 
                try
                    obj.s=serial(comport,'BaudRate',115200,'StopBits',1,'Parity','none','timeout',0.5,'Terminator','LF');
                    fopen(obj.s);
                catch err
                    error(err.identifier,'Error while opening serial connection.\n %s,',err.message);
                end
            else %if there is an open serial connection, set the serial object to be that of the open one.
               obj.s=devices(find(strcmpi(devices.Status,'open')));
            end
            %             try
            %                 fopen(obj.s); %open the serial connection
            %             catch err
            %                 if strcmpi(err.identifier,'MATLAB:serial:fopen:opfailed')
            %                     warning('Connection already open');
            % %                     fclose(instrfind);
            % %                     fopen(obj.s);
            %                 else
            %                     warning(['Problem opening serial connection:' err.identifier]);
            %                 end
            %             end
            
%             fclose(obj.s);
        end
        
                function delete(obj)
                    fclose(obj.s);
                    disp(['serial connection closed in Laser: ' inputname(1)]);
                end
        
        function staus=get.LasingStatus(obj)
            staus=obj.getLaserStat;
        end
        
        function unlock(obj)
            obj.setLaserServoStat('off');
            fprintf('unlocked\n');
        end
        
        function lock(obj)
            obj.setLaserServoStat('on');
            fprintf('locked\n');
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
        
        function resp=sendSerialCommand(obj,command)

            if strcmpi(obj.s.Status,'closed')
                try
                    fopen(obj.s);
                catch err
                    warning(['Cannot communicate with laser:' err.identifier]);
                end
            end
%                     
%                                         fclose(instrfind);
%                                         fopen(obj.s);
%                 end
%             else
%                 command=strjoin(varargin,' ');
%                 fopen(obj.s);
                command = [command char(13)];
%                 disp(command)
                fprintf(obj.s,['#Slave ' num2str(obj.slot) char(13)]);
                fscanf(obj.s);
                fprintf(obj.s,command);
                resp=fscanf(obj.s);
                resp=resp(1:end-1);
%                 fclose(obj.s);
%             end
        end
        
        
        
        function [laserLockStat,rmsError] = getFreqLockStat(obj)
            %This function checks the quality of the laser lock.
            %The function takes the RMS of the laser error signal, over N=15 measurments with dt = 100ms difference.
            %If the error is above the threshhold of 0.1?(Make sure this is true!!) then is it rejected.
            N = 10; %Number of samples
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
            fprintf(obj.s,['#Slave 1' char(13)]);
            resp=fscanf(obj.s);
            if nargin ==1
%                 t1stat=obj.sendSerialCommand(['Servo? ' obj.T1chan]);
                fprintf(obj.s,['Servo? ' num2str(obj.T1chan) char(13)]);
                resp=fscanf(obj.s);
                t1stat=resp(1:end-1);
                fprintf(obj.s,['Servo? ' num2str(obj.T2chan) char(13)]);
                resp=fscanf(obj.s);
                t2stat=resp(1:end-1);
                stat={t1stat,t2stat};
%                 t2stat=obj.sendSerialCommand(['Servo? ' obj.T2chan]);
                
                disp(['t1 stat is ' t1stat]);
                disp(['t2 stat is ' t2stat]);
            else
%                 stat=obj.sendSerialCommand(['Servo? ' num2str(chan)]);
                fprintf(obj.s,['Servo? ' num2str(chan) char(13)]);
                stat=fscanf(obj.s);
                stat=stat(1:end-1);
                
                disp(['chan ' num2str(chan) ' stat is ' stat]);
            end
        end
        
        function num=getEventNumber(obj)
            %returns the number of configured events in the table
            resp=obj.sendSerialCommand('EvtNum?');
            num=str2double(resp);
        end 
        function stat=getTempLockStat(obj)
            %             this function checks if our error signal on temp is tight
            %             enough to turn on a laser. and also checks servoing.
            % Check if temp servo is on
            if strcmpi(obj.getTempLockServoStat(obj.T2chan),'off') || strcmpi(obj.getTempLockServoStat(obj.T1chan),'off')
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
        
        function temp = getTemp(obj,chan)
            %          Returns the set temperature of chanel chan
%             obj.sendSerialCommand('#Slave 1');
%             temp=obj.sendSerialCommand(['Temp? 1']);
            fprintf(obj.s,['#Slave 1' char(13)]);
            resp=fscanf(obj.s);
            fprintf(obj.s,['Temp? ' num2str(chan) char(13)]);
            resp=fscanf(obj.s);
            temp=str2num(resp(1:end-1));
        end
        
        function stat=setTempMin(obj,setMin)
            obj.sendSerialCommand('#Slave 1');
            stat=obj.sendSerialCommand(['TempMin ' obj.coolingChan ' ' num2str(setMin)]);
            
        end
        
        function stat=getTempMin(obj)
%             fopen(obj.s);
            fprintf(obj.s,'#Slave 1');
            fprintf(obj.s,['TempMin? ' obj.coolingChan]);
            stat=fscanf(obj.s);
%             fclose(obj.s);
        end
        
        function stat=getTempGain(obj)
%             fopen(obj.s);
            fprintf(obj.s,'#Slave 1');
            fprintf(obj.s,['Gain? ' obj.coolingChan]);
            stat=fscanf(obj.s);
%             fclose(obj.s);
        end
        
        function stat=setTempGain(obj,gain)
%             fopen(obj.s);
            fprintf(obj.s,'#Slave 1');
            fprintf(obj.s,['Gain ' obj.coolingChan ' ' num2str(gain)]);
            stat=fscanf(obj.s);
%             fclose(obj.s);
        end
        
        function stat=setMaxTECcurr(obj,curr)
%             fopen(obj.s);
            fprintf(obj.s,'#Slave 1');
            fprintf(obj.s,['MaxCurr ' obj.coolingChan ' ' num2str(curr)]);
            stat=fscanf(obj.s);
%             fclose(obj.s);
        end
        
        function stat=getMaxTECcurr(obj)
%             fopen(obj.s);
            fprintf(obj.s,'#Slave 1');
            fprintf(obj.s,['MaxCurr? ' obj.coolingChan]);
            stat=fscanf(obj.s);
%             fclose(obj.s);
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
%             fopen(obj.s);
            fprintf(obj.s,['#Slave ' obj.slot char(13)]);
            %             obj.sendSerialCommand(['#Slave ' obj.slot]);
            resp=fscanf(obj.s);
            resp=resp(1:end-1);
            fprintf(obj.s,['N?' char(13)]);
            resp=fscanf(obj.s);
            resp=resp(1:end-1);
%             fclose(obj.s);
            N=str2double(resp);
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
            %             is the laser using internal RF reference?
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
            intFreq=str2double(intFreq);
        end
        
        function intRefStat=setIntFreq(obj, freq)
            if (freq>=240 || freq<=50)
                error(['cannot set internal frequency ' num2str(freq) ' MHz'])
            end
            %This function sets the inturnal vco frequency in MHz. Remember
            %that the actual signal in the PLL is multiplied by the multiplier.
            obj.sendSerialCommand(['#Slave ' obj.slot]);
            intRefStat=obj.sendSerialCommand(['IntFreq ' num2str(freq)]);
%             assert(abs(str2double(obj.getIntFreq)-freq)<0.01)
        end
        
        function intRefStat=setExtFreq(obj, freq)
            %This function sets the vco frequency in MHz as the requested frequency divided by the internal multiplier.
            intRefStat=obj.setIntFreq(freq/obj.getMultiplyer);
        end
        
        function laserServo=getLaserServoStat(obj)
            obj.sendSerialCommand(['#Slave ' obj.slot]);
            laserServo=obj.sendSerialCommand('Servo?');
            
        end
        
        function laserServo=setLaserServoStat(obj, bool)
            %servo is the freq lock
            bool = obj.boolChck(bool); %Check that bool is 'on' or 'off'
            if strcmpi(obj.s.Status,'closed')
                fopen(obj.s);
            end
%             
            obj.sendSerialCommand(['#Slave ' obj.slot]);
            laserServo=obj.sendSerialCommand(['Servo ' bool]);
            
            
            if strcmp(bool,'On')
                if obj.getFreqLockStat == 0
                    pause(2)
                    if obj.getFreqLockStat == 0
                    obj.sendSerialCommand(['Servo ' 'Off']);
                    
                    error('Lock failed!')
                    end
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
        
        function sucsess=setEventData(obj,freq,row,mode,feedFwd)
            %This function updates the trigger event table.
            %row is the rwo in the table (1-7).
            %mode is the mode of the laser (0-15) by the folowing table:
%             Mode	N	Invert	Internal VCO
%             0     8	Off         Off
%             1     8	Off         On
%             2     8	On          Off
%             3     8	On          On
%             4     16	Off         Off
%             5     16	Off         On
%             6     16	On          Off
%             7     16	On          On
%             8     32	Off         Off
%             9     32	Off         On
%             10	32	On          Off
%             11	32	On          On
%             12	64	Off         Off
%             13	64	Off         On
%             14	64	On          Off
%             15	64	On          On
            obj.sendSerialCommand(sprintf('EvtData %d %d %f',row,0,mode));
            obj.sendSerialCommand(sprintf('EvtData %d %d %f',row,1,freq));
            obj.sendSerialCommand(sprintf('EvtData %d %d %f',row,2,feedFwd));
            obj.sendSerialCommand('Save');%if we don't save then this wont work
            sucsess=1;
        end
        
        function setNum=setEventNum(obj,num)
            %sets the number of events in the table
            if strcmpi(obj.s.Status,'closed')
                fopen(obj.s);
            end
            setNum=obj.sendSerialCommand(sprintf('EvtNum %d',num));
        end
        
        function address=setAddress(obj,addressNum)
            if ~any(addressNum==0:7)
                error('address must be 0 - 7');
            end
            address=obj.sendSerialCommand(sprintf('EvtJump %d',addressNum));
        end
        function address=getAddress(obj)
            address=obj.sendSerialCommand(sprintf('EvtJump?'));
        end
        function currRow=getCurrentEvent(obj)
            nextRow=str2double(obj.sendSerialCommand(sprintf('EvtJRow?')));
            evtNum=str2double(obj.sendSerialCommand(sprintf('EvtNum?')));
            if nextRow==1
                    currRow=evtNum;
                else
                    currRow=nextRow-1;
            end
        end
        
        function currRow=setCurrentEvent(obj,row)
            ctr=0;
            nextRow=str2double(obj.sendSerialCommand(sprintf('EvtJRow?')));
            evtNum=str2double(obj.sendSerialCommand(sprintf('EvtNum?')));
            if nextRow==1
                currRow=evtNum;
            else
            currRow=nextRow-1;
            end
            
            while currRow~=row
                obj.sendSerialCommand(sprintf('#DoEvent 7')); %this is the nump
                nextRow=str2double(obj.sendSerialCommand(sprintf('EvtJRow?')));
                
                if nextRow==1
                    currRow=evtNum;
                else
                    currRow=nextRow-1;
                end
                ctr=ctr+1;
                if ctr>evtNum+1
                    error('error in setting ICE current event');
                end
                
            end
            
        end
        
        function data=getEventData(obj,eventNum)
            mode=obj.sendSerialCommand(sprintf('EvtData? %d 0',eventNum));
            freq=obj.sendSerialCommand(sprintf('EvtData? %d 1',eventNum));
            feedFwd=obj.sendSerialCommand(sprintf('EvtData? %d 2',eventNum));
            data=[str2double(mode),str2double(freq),str2double(feedFwd)];
        end
        
    end
end






