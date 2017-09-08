classdef Pulse
    % file: Pulse.m
    %------------------------------------------------------
    % This class has two main roles
    % 1. create the basic object 'Pulse' which has the following
    %    parameters :
    %      Channel - the channel is some hardware that this pulse refere to
    %      Tstart  - at time Tstart the pulse switch to On
    %      Width    - after a time  Width the pulse switch to Off
    %      Freq    -  set freq is execute before Tstart
    %      Phase   -  set phase is execute before Tstart
    %      Amp     -  set amplitude is execute before Tstart
    %     -------------!!!!  TIME IS IN MICRO-SECONDS !!!! -----------
    %  syntex P=Pulse(Ch,Tstart,Width)
    %         P=Pulse(Ch,Tstart,width,'freq',f,'Phase',ph)
    %         Ch can be the number or name  as appear in PulseChannelInfo
    % All the information necessery to relate abstarct pulses to
    % their real implementation on the FPGA is in PulseChannelInfo
    % Function
    %
    %------------------------------------------------------
    
    properties (Constant = true)
        
        
        Timing=struct('VCOSetFreq',1,...
            'DDSsetFreq',1,...
            'DDSsetPhase',1);
        
    end
    
    % Public properties
    properties
        Channel;
        Tstart=0;
        Tend=0;
        Freq;
        setFreq=false;
        Phase;
        setPhase=false;
        Amp;
        setAmp=false;
        analog=false;
    end
    % Class methods
    methods
        
        function obj = Pulse(ch,ts,width,varargin)
            % Construct a Pulse object using the coefficients supplied
            % if width is 0 than the pulse is only an On at ts
            % if width is -1 than the pulse is only an Off at ts
            % if width > 0 than the pulse is on at ts and off at ts+width
            % Tstart and Tend are in clock cycles (25 nS ) so we need to
            % multiply by 40 to make it all in microseconds
            obj.Tstart = (ts*40);
            obj.Tend = (ts*40+width*40);
            if ischar(ch)
                ch=PulseChannelInfo(ch);
            end
            obj.Channel = ch;
            for i=1:2:size(varargin,2)
                switch lower(char(varargin(i)))
                    case 'freq'
                        obj.Freq=varargin{i+1};
                        obj.setFreq=true;
                    case 'phase'
                        obj.Phase=varargin{i+1};
                        obj.setPhase=true;
                    case 'amp'
                        obj.Amp=varargin{i+1};
                        obj.setAmp=true;
                end; %switch
            end;%for loop
        end % pulse
        
        function P=Shift(obj,t)
            %t is the time you want to shift the pulse by, in microseconds.
            %takes a pulse, returns the exact same pulse, shifted by t.
            P=obj;
            P.Tstart=(obj.Tstart+t*40);
            P.Tend=(obj.Tend+t*40);
        end
        
    end % methods
    
    methods(Static)
        
        function timearray = Sequence2TimeLine(pulses)
            % get array of pulses
            % TimeLine Structure [ time channel operation  parameter]
            % operation : start=1, stop=2, setfreq=3,setphase=4 and donothing=5.
            % !! here TIME is in clock cycles !!!
            numofpulses=size(pulses,2);
            timearray=zeros(numofpulses*4,4); %every pulse takes up 4 rows
            index=1;
            precede=20; %= 0.5 mus ->setting the freq/phase/amp command timing
            for i=1:numofpulses
                ts=pulses{i}.Tstart;
                te=pulses{i}.Tend;
                ch=pulses{i}.Channel;
                if (te-ts)==0
                    % only ON pulse
                    timearray(index,:)=[ts,ch,1,0];
                    index=index+1;
                elseif (te-ts)<0
                    % only Off pulse
                    timearray(index,:)=[ts,ch,2,0];
                    index=index+1;
                    precede=0;
                else
                    timearray(index,:)=[ts,ch,1,0];
                    timearray(index+1,:)=[te,ch,2,0];
                    index=index+2;
                end
                if (pulses{i}.setFreq)
                    timearray(index,:)=[ts-precede,ch,3,pulses{i}.Freq];
                    precede=precede+20;
                    index=index+1;
                end
                if (pulses{i}.setAmp)
                    timearray(index,:)=[ts-precede,ch,5,pulses{i}.Amp];
                    precede=precede+20;
                    index=index+1;
                end
                if (pulses{i}.setPhase)
                    timearray(index,:)=[ts-precede,ch,4,pulses{i}.Phase];
                    index=index+1;
                end
                
                if (pulses{i}.analog)
                    if (te-ts)==0
                        % only ON pulse
                        timearray(index,:)=[ts,ch,1,pulses{i}.voltage];
                        index=index+1;
                    elseif (te-ts)<0
                        % only Off pulse
                        timearray(index,:)=[ts,ch,2,0];
                        index=index+1;
                        precede=0;
                    else
                        timearray(index,:)=[ts,ch,1,pulses{i}.voltage];
                        timearray(index+1,:)=[te,ch,2,0];
                        index=index+2;
                    end
                    
                end
                %
            end
            timearray(index:end,:)=[];
            timearray=sortrows(timearray);
        end %Sequence2TimeLine
        
        function PlotTimeLine(timearray)
            %timearray as retuerned by Sqeuqnce2TimeLine
            % This function is currently BROKEN channelInfo used to be stored inside
            % Pulse but it is not a PulseChannelInfo object. need to fix this if we
            % want to use this functionality.
            p=Pulse(1,1,1); % only for the ChannelInfo
            channels=sort(unique(timearray(:,2)));
            numofchannels=size(channels,1);
            timelength=size(timearray,1);
            y=zeros(timelength,numofchannels);
            ch=find(channels == timearray(1,2));
            y(1,ch)=(timearray(1,3)==1)*1+(timearray(1,3)==2)*0;
            for i=2:timelength
                y(i,:)=y(i-1,:);
                ch=find(channels == timearray(i,2));
                y(i,ch)=(timearray(i,3)==1)*1+(timearray(i,3)==2)*0;
            end
            % add zeros at t=0;
            timearray=[0 ;timearray(:,1)];
            y=[zeros(1,numofchannels); y];
            % shift channels in the y axis
            y=y+2*ones(size(y,1),1)*(1:numofchannels);
            stairs(timearray/10,y);
            xlabel('Time[\mus]');
            grid;
            
            %add legend
            for i=1:numofchannels
                text(10,i*2+0.5,p.ChannelInfo(channels(i)).ChannelName);
            end
            legend(p.ChannelInfo(channels).ChannelName);
            a=axis;
            axis([a(1) a(2) a(3)-1 a(4)+3]);
        end % plottimeline
        
    end % methods static
    
end % classdef

