classdef keysightScope < handle
    %KEYSIGHTSCOPE object
    
    properties
        sc
        connType
        waveform
        scopename
        easyname %set easy name for the scope
        sampleRate  
    end
    
    methods
        function obj = keysightScope(scopename,easyname,TYPE)
            %KEYSIGHTSCOPE Construct an instance of this class
            if nargin==1
                obj.scopename=scopename;
                obj.easyname=scopename;
                obj.connType='USB';
            elseif nargin==2
                obj.easyname=easyname;
                obj.connType='USB';
                obj.scopename=scopename;
            else
                obj.easyname=easyname;
                obj.connType=TYPE;
                obj.scopename=scopename;
                
            end
            
            %             if easyname
            %
            if strcmpi(obj.connType,'ip')
                obj.scopename=sprintf('TCPIP::%s::inst0::INSTR',scopename);
            end
            %             obj.sc = visa('agilent',obj.scopename);
            obj.sc = visa('agilent',obj.scopename);
            obj.sc.InputBufferSize = 200000;
            obj.sc.Timeout = 0.2; % in sec?
            obj.sc.ByteOrder = 'littleEndian';
            fopen(obj.sc);
            %             fprintf(obj.sc,'*RST');
            %             fprintf(obj.sc,':WAVEFORM:SOURCE CHAN1');
            fprintf(obj.sc,':WAV:POINTS:MODE MAXimum'); %if not set to max then the max num of points is 62k
            fprintf(obj.sc,':WAV:POINTS 100000');
            obj.sampleRate=obj.getSampleRate;
            obj.setProbeRatio(1,1);
            obj.setProbeRatio(2,1);
            obj.setProbeRatio(3,1);
            obj.setProbeRatio(4,1);
        end
        
        function getStoppedChan(obj,chanum)
            obj.setState('stop');
            query(obj.sc,':WAV:DATA?')
        end
        
        function setBase(obj)
            obj.setChan(1,1);
            obj.setChan(2,1);
            obj.setChan(3,1);
            obj.setChan(4,1);
            obj.setVrange(1,1);
            obj.setVrange(2,1);
            obj.setVrange(3,1);
            obj.setVrange(4,1);
            obj.setTimebase(1);
            obj.setTrigger(1,1,'POS');
        end
        
        function setTimeMode(obj,mode)
            modes={'MAIN','WIND','XY','ROLL'};
            if ~any(strcmpi(modes,mode))
                error('mode must be MAIN,WIND,XY,ROLL')
            else
                fprintf(obj.sc,[':TIMebase:MODE ' upper(mode)])
            end
        end
        function Mode = getTimeMode(obj)
            Mode = query(obj.sc,':TIMebase:MODE?');
        end
        function setTimebase(obj,time)
            fprintf(obj.sc,[':TIMebase:RANGe ' num2str(time)]);
        end
        
        function setTimeOffset(obj,offset)
            fprintf(obj.sc,[':TIM:POS ' num2str(offset)]);
        end
        function fullScreenTime=getTimebase(obj)
            t=regexp(query(obj.sc,':TIM?'),'(?<=MAIN:RANG ).+;','match');
            t=str2double(t{1}(1:end-1));
            fullScreenTime=t;
        end
        function rate=getSampleRate(obj)
            rate=str2double(query(obj.sc,':ACQ:SRAT?'));
        end
        
        function setDelay(obj,time)
            fprintf(obj.sc,[':TIMebase:DELay ' num2str(time)]);
        end
        function bool=isTrigged(obj)
            rsp=query(obj.sc,'*STB?');
              bool=bitget(str2double(rsp),1);
%             bool=query(obj.sc,'TER?');
%             bool=str2double(bool);
%             
%             if bool
%                 obj.trigFlag=bool;
%                 disp('Triged Scope');
%             end
%             
%             trigFlag=obj.trigFlag;
% %             
        end
        
        function forceTrig(obj)
            fprintf(obj.sc,':TRIGger:FORCe');
%             obj.trigFlag = 1;
            disp('Triged Scope');

        end
        
        function setState(obj,state)
            if strcmpi(state,'run')
                fprintf(obj.sc,':RUN');
            elseif strcmpi(state,'stop')
                fprintf(obj.sc,':stop');
            elseif strcmpi(state,'single')
                fprintf(obj.sc,':single');
                query(obj.sc,'TER?'); %this clears the trigger event bit
            else
                error('no such state');
                
            end
            
        end
        
        function clearState(obj)
            fprintf(obj.sc,'*CLS');
        end
        
        function [x,y,Error]=getChan(obj,chanum,waitForTrig)
            timeMode = obj.getTimeMode;
            timeMode(end) = [];
            if ~strcmpi(timeMode,'MAIN')
                error(sprintf('Time Mode must be Normal (MAIN)!\nUse setTimeMode to change'))
            end
            %             if length(chanum)==1
            %                 fprintf(obj.sc,[':WAVEFORM:SOURCE CHAN' num2str(chanum)]);
            %             else
            %                 for i=1:length(chanum)
            %                     fprintf(obj.sc,[':WAVEFORM:SOURCE CHAN' num2str(chanum(i))]);
            %                 end
            %             end
            if nargin==2
                waitForTrig=0;
            end
            
            %             t=0;
            
            %             while ~obj.isTrigged
            %                 t=t+1;
            %                 pause(0.1)
            %                 fprintf('scope:%s -waiting for trigger\n',obj.easyname);
            %                 if t>1
            %                     error=1;
            %                     fprintf('scope:%s - returned data without being triggered\n',obj.easyname);
            %                     break
            %
            %                 end
            %             end
            fullScreenTime=obj.getTimebase;
            t=tic;
            dataCollectedFlag=0;
            maxDelay=5*fullScreenTime;
            if maxDelay<1
                maxDelay=1;
            end
%             if maxDelay>20
%                 warning('delay time is long: %f s. are you sure?',maxDelay);
%             end
            
            while toc(t)< maxDelay
                
                if obj.isTrigged && ~obj.isRunning
                    timeOut = obj.getTimeout;
                    obj.setChan(chanum,1); %set chanel to chanum
                    fprintf(obj.sc,[':WAV:SOURCE CHANNEL' num2str(chanum)]);
                    %             fprintf(obj.sc,[':DIGITIZE CHAN' num2str(chanum)]);
                    % Wait till complete
                    operationComplete = str2double(query(obj.sc,'*OPC?'));
                    OCtic = tic;
                    while ~operationComplete || toc(OCtic)>timeOut
                        operationComplete = str2double(query(obj.sc,'*OPC?'));
                    end
                    % Get the data back as a WORD (i.e., INT16), other options are ASCII and BYTE
                    fprintf(obj.sc,':WAVEFORM:FORMAT WORD');
                    % fprintf(sc,':WAV:FORM ASCii');
                    % Set the byte order on the instrument as well
                    fprintf(obj.sc,':WAVEFORM:BYTEORDER LSBFirst');
                    
                    preambleBlock = query(obj.sc,':WAVEFORM:PREAMBLE?');
                    fprintf(obj.sc,':WAV:DATA?');      
                    % read back the BINBLOCK with the data in specified format and store it in
                    % the waveform structure. FREAD removes the extra terminator in the buffer
                    obj.waveform.RawData = binblockread(obj.sc,'uint16'); fread(obj.sc,1);
                    % Read back the error queue on the instrument
                    instrumentError = query(obj.sc,':SYSTEM:ERR?');
                    errorTic = tic;
                    while ~isequal(instrumentError,['+0,"No error"' char(10)])||toc(errorTic)>timeOut
                        disp(['Instrument Error: ' instrumentError]);
                        instrumentError = query(obj.sc,':SYSTEM:ERR?');
                    end                    
                    maxVal = 2^16;
                    
                    %  split the preambleBlock into individual pieces of info
                    preambleBlock = regexp(preambleBlock,',','split');
                    
                    % store all this information into a waveform structure for later use
                    obj.waveform.Format = str2double(preambleBlock{1});     % This should be 1, since we're specifying INT16 output
                    obj.waveform.Type = str2double(preambleBlock{2});
                    obj.waveform.Points = str2double(preambleBlock{3});
                    obj.waveform.Count = str2double(preambleBlock{4});      % This is always 1
                    obj.waveform.XIncrement = str2double(preambleBlock{5}); % in seconds
                    obj.waveform.XOrigin = str2double(preambleBlock{6});    % in seconds
                    obj.waveform.XReference = str2double(preambleBlock{7});
                    obj.waveform.YIncrement = str2double(preambleBlock{8}); % V
                    obj.waveform.YOrigin = str2double(preambleBlock{9});
                    obj.waveform.YReference = str2double(preambleBlock{10});
                    obj.waveform.VoltsPerDiv = (maxVal * obj.waveform.YIncrement / 8);      % V
                    obj.waveform.Offset = ((maxVal/2 - obj.waveform.YReference) * obj.waveform.YIncrement + obj.waveform.YOrigin);         % V
                    obj.waveform.SecPerDiv = obj.waveform.Points * obj.waveform.XIncrement/10 ; % seconds
                    obj.waveform.Delay = ((obj.waveform.Points/2 - obj.waveform.XReference) * obj.waveform.XIncrement + obj.waveform.XOrigin); % seconds
                    
                    % Generate X & Y Data
                    % waveform.XData = (waveform.XIncrement.*(1:length(waveform.RawData))) - waveform.XIncrement;
                    % waveform.YData = (waveform.YIncrement.*(waveform.RawData - waveform.YReference)) + waveform.YOrigin;
                    x = (obj.waveform.XIncrement.*(1:length(obj.waveform.RawData))) - obj.waveform.XIncrement;
                    y = (obj.waveform.YIncrement.*(obj.waveform.RawData - obj.waveform.YReference)) + obj.waveform.YOrigin;
                    dataCollectedFlag=1;
                    break
                end   
            end
            
            if ~dataCollectedFlag
                warning('Trigger not received and/or acquisition not complete within alloted time');
            end
        end
        function [data,Error] =getDigitalChannels(obj)
            timeMode = obj.getTimeMode;
            timeMode(end) = [];
            if ~strcmpi(timeMode,'MAIN')
                error(sprintf('Time Mode must be Normal (MAIN)!\nUse setTimeMode to change'))
            end
            if nargin==2
                waitForTrig=0;
            end
            fullScreenTime=obj.getTimebase;
            t=tic;
            dataCollectedFlag=0;
            maxDelay=5*fullScreenTime;
            if maxDelay<1
                maxDelay=1;
            end
            while toc(t)< maxDelay
                if obj.isTrigged && ~obj.isRunning
                    fprintf(obj.sc,':WAV:SOURCE POD1');
                    % Wait till complete
                    operationComplete = str2double(query(obj.sc,'*OPC?'));
                    while ~operationComplete
                        operationComplete = str2double(query(obj.sc,'*OPC?'));
                    end
                    % Get the data back as a BYTE (i.e., INT8)
                    fprintf(obj.sc,':WAVEFORM:FORMAT BYTE');
                    % Set the byte order on the instrument as well
                    fprintf(obj.sc,':WAVEFORM:BYTEORDER LSBFirst');
                    preambleBlock = query(obj.sc,':WAVEFORM:PREAMBLE?');
                    fprintf(obj.sc,':WAV:DATA?');
                    % read back the BINBLOCK with the data in specified format and store it in
                    % the waveform structure. FREAD removes the extra terminator in the buffer
                    obj.waveform.RawData = binblockread(obj.sc,'uint8'); fread(obj.sc,1);
                    % Read back the error queue on the instrument
                    instrumentError = query(obj.sc,':SYSTEM:ERR?');
                    while ~isequal(instrumentError,['+0,"No error"' char(10)])
                        disp(['Instrument Error: ' instrumentError]);
                        instrumentError = query(obj.sc,':SYSTEM:ERR?');
                    end
                    maxVal = 2^16;
                    %  split the preambleBlock into individual pieces of info
                    preambleBlock = regexp(preambleBlock,',','split');              
                    % store all this information into a waveform structure for later use
                    obj.waveform.Format = str2double(preambleBlock{1});     % This should be 1, since we're specifying INT16 output
                    obj.waveform.Type = str2double(preambleBlock{2});
                    obj.waveform.Points = str2double(preambleBlock{3});
                    obj.waveform.Count = str2double(preambleBlock{4});      % This is always 1
                    obj.waveform.XIncrement = str2double(preambleBlock{5}); % in seconds
                    obj.waveform.XOrigin = str2double(preambleBlock{6});    % in seconds
                    obj.waveform.XReference = str2double(preambleBlock{7});
                    obj.waveform.YIncrement = str2double(preambleBlock{8}); % V
                    obj.waveform.YOrigin = str2double(preambleBlock{9});
                    obj.waveform.YReference = str2double(preambleBlock{10});
                    obj.waveform.VoltsPerDiv = (maxVal * obj.waveform.YIncrement / 8);      % V
                    obj.waveform.Offset = ((maxVal/2 - obj.waveform.YReference) * obj.waveform.YIncrement + obj.waveform.YOrigin);         % V
                    obj.waveform.SecPerDiv = obj.waveform.Points * obj.waveform.XIncrement/10 ; % seconds
                    obj.waveform.Delay = ((obj.waveform.Points/2 - obj.waveform.XReference) * obj.waveform.XIncrement + obj.waveform.XOrigin); % seconds
                    data = zeros(length(obj.waveform.RawData),9);
                    data(:,1) = (obj.waveform.XIncrement.*(1:length(obj.waveform.RawData))) - obj.waveform.XIncrement;
                    data(:,2:9) = de2bi(obj.waveform.RawData,8);
                    dataCollectedFlag=1;
                    break
                end   
            end
            if ~dataCollectedFlag
                warning('Trigger not received and/or acquisition not complete within alloted time');
            end
        end
        
        function plotChan(obj,chanum)
            figure;
            
            [x,y]=obj.getChan(chanum);
            plot(x,y);
            xlabel('T[s]');
            ylabel('V[V]');
            title([obj.scopename ' ' datestr(now)]);
            
        end
        
        function dat=getChannels(obj,chanList)
            %             chan list is a list of channel numbers we want to get
            dat=[];
            if nargin==1
                chanList=[1,2,3,4];
            end
            chanList=sort(chanList);
            for ii=1:length(chanList)
                %changed by L.D on 24/04/19 to retrive data only from
                %channels in chanList
                    if ii==1
                        [x,y]=obj.getChan(chanList(ii));
                        dat = zeros(length(y),5);
                        dat(:,1) = x';
                        dat(:,chanList(ii)+1) = y;
                    else
                        [~,y]=obj.getChan(chanList(ii));
                        dat(:,chanList(ii)+1) = y;
                    end
%                     [x,y]=obj.getChan(ii,ii==1);
%                     if ii==1
%                         if isempty(find(ii==chanList))
%                             y=y*0;
%                         end
%                         dat=horzcat(dat,x',y);
%                     else
%                         if isempty(find(ii==chanList))
%                             y=y*0;
%                         end
%                         dat=horzcat(dat,y);
%                     end
             end
        end
        
        function plotScreen(obj)
            figure;
            hold on
            for i=1:4
                [x,y]=obj.getChan(i);
                plot(x,y,'o');
            end
            xlabel('T[s]');
            ylabel('V[V]');
            title([obj.scopename ' ' datestr(now)]);
        end
        
        function out=SCPISend(obj,msg)
            fprintf(obj.sc,msg);
            %     out=fscanf(obj.sc);
        end
        
        function labelChan(obj,chanum,label)
            fprintf(obj.sc,[':CHANnel' num2str(chanum) ':LABel "' label '"']);
        end
        
        function setOffset(obj,chanum,offset)
            fprintf(obj.sc,[':CHANnel' num2str(chanum) ':OFFSet ' num2str(offset) 'V']);
            
        end
        
        function setProbeRatio(obj,chanum,ratio)
            fprintf(obj.sc,[':CHANnel' num2str(chanum) ':PROBe ' num2str(ratio)]);
        end
        function setVrange(obj,chanum,range)
            fprintf(obj.sc,[':CHANnel' num2str(chanum) ':RANGe ' num2str(range) 'V']);
        end
        
        function setDVM(obj,state)
            fprintf(obj.sc,['DVM:ENABLE ' state]);
        end
        
        function state=isRunning(obj)
            %%0 is stopped. 1 is run/single
            state=bitget(str2num(dec2bin(str2num(query(obj.sc,'OPER:COND?')),14)),4);
        end
        function setTrigger(obj,chanum,level,slope)
            if strcmpi(slope,'POS') || strcmpi(slope,'NEG') || strcmpi(slope,'EITHER')
                fprintf(obj.sc,['TRIGGER:MODE EDGE']);
                fprintf(obj.sc,['TRIGGER:EDGE:SLOPE ' slope]);
            else
                error('slope has to be POS, NEG or EITHER');
            end
            if strcmpi(chanum,'EXT')
                fprintf(obj.sc,['TRIGGER:EDGE:SOURCE EXT']);
            else
                fprintf(obj.sc,['TRIGGER:EDGE:SOURCE CHANNEL' num2str(chanum)]);
            end
            fprintf(obj.sc,['TRIGGER:EDGE:LEVEL ' num2str(level)]);
            
        end
        
        function setChan(obj,chanum,state)
            fprintf(obj.sc,[':CHANNEL' num2str(chanum) ':DISPLAY ' num2str(state)]);
        end
        
        function chans=getActiveChans(obj)
            chans=zeros(1,4);
            for i=1:4
                chans(i)=str2num(query(obj.sc,[':CHANNEL' num2str(i) ':DISPLAY?']));
            end
        end
        function setTimeout(obj,timeout)
            %timeout is in s
            obj.sc.Timeout = timeout;
        end
        
        function timeout=getTimeout(obj)
            %timeout is in s
            timeout=obj.sc.Timeout;
        end
        function maxPoints = getMaxPoints(obj)
            %this function retrives the maximal number of points which can
            %be retrived. Based on the sampling rate and the screan time
            maxPoints = obj.getTimebase*obj.getSampleRate;          
        end
        function setNumPoints(obj,numPoints)
            %this function sets the number of points to be sampled.
            %If this number is larger then the maximal number, it givs a
            %warning
             fprintf(obj.sc,sprintf(':WAV:POINTS %d',numPoints));
             maxPoints = obj.getMaxPoints;
             if numPoints>maxPoints
                 warning('Maximal number of points is %d, you requested %d. Number of points set to maximum.\n',maxPoints,numPoints)
             end
        end
        function numPoints = getNumPoints(obj)
            %this function retrives the maximal number of points which can
            %be retrived. Based on the sampling rate and the screan time
            numPoints = str2double(query(obj.sc,':WAV:POINTS?'));
        end
        function AcqType = getAcquisitionType(obj)
            %this function returns the Acquisition type of the scope
            %(NORMal | AVERage |HRESolution | PEAK)
             AcqType = query(obj.sc,'ACQuire:TYPE?');
             AcqType(end) = [];
        end
        function AcqType = setAcquisitionType(obj,type)
           %this function sets the Acquisition type of the scope
            % options are NORMal | AVERage |HRESolution | PEAK
            if ~any(strcmp(type,{'NORM','NORMal','AVER','AVERage','HRES','HRESolution','PEAK'}))
                error('type=%s and it must be : [NORM|NORMal|AVER|AVERage|HRES|HRESolution|PEAK]')
            end
             fprintf(obj.sc,['ACQuire:TYPE ' type]);
             AcqType = obj.getAcquisitionType;
        end
        function delete(obj)
            fclose(obj.sc);
            disp(['closed connection to scope: ' obj.scopename]);
        end
        
    end
end
