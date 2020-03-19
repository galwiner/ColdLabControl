function [chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell(sortedPulses,gateTime,cycleTime)

%generate a structure under MIT naming and data structure. see one note
%page: "Structure of MIT data for G2 post processing"
%chN_phot_time is cell array with (det Number) matrices. each has N rows and 2 cols.
%col 1 has photon arrival times from cycle start.
%col 2 has phton arrival times from previous gate.
%gateTime is the SPCM data collection time, cycleTime is roughly the duration of
%dipole trap pulsing

gateTags(1,:)=double(sortedPulses{1});
lastGateInCycleIdx=find(diff(gateTags(1,:))>cycleTime*1e6/4)+1;
% find((diff(gateTags(1,:))>cycleTime/4))+1;
if isempty(lastGateInCycleIdx)
    lastGateInCycleIdx = length(gateTags(1,:));
% else
%     cycleStopTimes=gateTags(1,lastGateInCycleIdx); %finding at what time a cycles increments
end
cycleStopTimes=[gateTags(1,lastGateInCycleIdx) sortedPulses{2}(end)]; %finding at what time a cycles increments
gateTags(2,find(gateTags(1,:)<=cycleStopTimes(1),inf,'last')) = 1;
for cInd = 2:length(cycleStopTimes)
    gateTags(2,find(and(gateTags(1,:)<=cycleStopTimes(cInd),...
        gateTags(1,:)>cycleStopTimes(cInd-1)),inf,'last')) = cInd;
end
gateTags(2,find(gateTags(1,:)>cycleStopTimes(end))) = cInd+1;
firstGateInCycleIdx = [1 find(diff(gateTags(2,:))==1)];
firstGateTimes=gateTags(1,firstGateInCycleIdx);
%allocating empty strucutres
chN_phot_cycles=cell(1,length(sortedPulses)-1);
chN_phot_gc=cell(1,length(sortedPulses)-1);
chN_phot_time=cell(1,length(sortedPulses)-1);
phot_per_cycle=0;
chN_gates_each_cycle=cell(1,length(sortedPulses)-1);
%cycling over the detectors
for detInd=2:length(sortedPulses)
    times=double(sortedPulses{detInd});
    if isempty(times)
       warning('No Photons recived in channel %0.0d',detInd)
       chN_phot_cycles{detInd-1} = 0;
       chN_phot_gc{detInd-1} = 0;
       chN_phot_time{detInd-1} = 0;
       chN_gates_each_cycle{detInd-1} = 0;
       continue
    end
    if isrow(times)
        times=times';
    end
    
    chN_phot_cycles{detInd-1}=zeros(size(times));
    chN_phot_gc{detInd-1}=zeros(size(times));
    chN_phot_time{detInd-1}=zeros(size(times));
    chN_phot_gateTags{detInd-1}=zeros(size(times));
    chN_phot_firstGateInCycle{detInd-1}=zeros(size(times));
    %looping over all time tags in the detector and telling each photon
    %which cycles is his (or hers)
    for cInd=1:length(cycleStopTimes)-1
        if cInd==1
            chN_phot_cycles{detInd-1}(times<=cycleStopTimes(cInd))=cInd;
        else
            thisCycleIdx=and(times<cycleStopTimes(cInd),times>cycleStopTimes(cInd-1));
            chN_phot_cycles{detInd-1}(thisCycleIdx)=cInd;
        end
        if length(length(cycleStopTimes))==1
            chN_phot_cycles{detInd-1}(times>cycleStopTimes(end))=length(cycleStopTimes);
        else
%         chN_phot_cycles{detInd-1}(times>cycleStopTimes(end))=length(cycleStopTimes)+1;
        chN_phot_cycles{detInd-1}(times>cycleStopTimes(end))=length(cycleStopTimes)+1;
        end
        chN_phot_firstGateInCycle{detInd-1}(chN_phot_cycles{detInd-1}==cInd)=firstGateTimes(cInd);
    end
    if length(cycleStopTimes)~=1
    chN_phot_firstGateInCycle{detInd-1}(chN_phot_cycles{detInd-1}==cInd+1)=firstGateTimes(cInd); %+1
    end
    %     chN_phot_time{detInd-1}(:,1) = times
    %find gate number in run (run is a file)
    photonDistance=abs(times-gateTags(1,:))*1e-6; %in uS
%     plot(photonDistance(:,1:10)) %this plot shows the reasoning quite clearly
%     hold off
    gPos=[];
    gc=[];
    for ind=1:size(photonDistance,2)
        
        gate=find(diff(photonDistance(:,ind))<0,1,'last');
        if isempty(gate)
            gate=0;
        end
        
        gPos(end+1)=gate;
    end
    repl=@(a,b) repmat(a,1,b);
    gc=arrayfun(repl,[1:size(photonDistance,2)]',[diff(gPos) size(photonDistance,1)-sum(diff(gPos))]','UniformOutput',false);
    chN_phot_gc{detInd-1}=[gc{:}]';
    
% 
%     for pInd=1:length(times)
% %         chN_phot_gc{detInd-1}(pInd,1)=find(times(pInd)>gateTags(1,:),1,'last');
%         chN_phot_gc{detInd-1}(pInd,1)=find(abs(times(pInd)-gateTags(1,:))*1e-6<0.1,1,'last');
%         
% %         ofr 
%     end
%     minInd = 1;
%     maxInd = find(times>gateTags(1,2),1)-1;
%     chN_phot_gc{detInd-1}(minInd:maxInd,1)=1;
%     for gInd=2:length(gateTags(1,:))-1
%         minInd = maxInd+1;
%         maxInd = find(times>gateTags(1,gInd+1),1)-1;
%         chN_phot_gc{detInd-1}(minInd:maxInd,1)=gInd;
%     end
%     chN_phot_gc{detInd-1}(maxInd+1:end,1)=gInd+1;
    
    %find gate number in cycle
    prev_cIdx=chN_phot_cycles{detInd-1}==1;
    %set gates in 1st cycle to be gates in run, matching 1st cycle
    chN_phot_gc{detInd-1}(prev_cIdx,2) = chN_phot_gc{detInd-1}(prev_cIdx,1);
    prev_cycleVals=chN_phot_gc{detInd-1}(prev_cIdx,1);
    
    %     chN_phot_time{detInd-1}(prev_cIdx,1)=times(prev_cIdx)-gateTags(1,:)(1);
    %     prev_cycletimes=times(prev_cIdx);
    %for each cycle number, find the indices of this cycle. then find the
    %gate numbers in the run of this cycle. deduct the largest gate number
    %from the previous cycle (in run) from the first gate number (in run)
    %of this cycle.
    chN_phot_gateTags{detInd-1}(prev_cIdx)=gateTags(1,chN_phot_gc{detInd-1}(prev_cIdx,1));
    chN_phot_time{detInd-1}(prev_cIdx,2)=times(prev_cIdx)-chN_phot_gateTags{detInd-1}(prev_cIdx,1);
    
    %     gateIdx=find(chN_phot_gc{detInd-1}(prev_cIdx,2)==1,1);
    %     chN_phot_time{detInd-1}(prev_cIdx,2)=times(prev_cIdx)-chN_phot_gateTags{detInd-1}(gateIdx,1);
    %
    for cInd=2:length(cycleStopTimes)+1
        cIdx=chN_phot_cycles{detInd-1}==cInd;
        chN_phot_gc{detInd-1}(cIdx,2)=chN_phot_gc{detInd-1}(cIdx,1)-max(prev_cycleVals);
        prev_cycleVals=chN_phot_gc{detInd-1}(cIdx,1);
        
        chN_phot_gateTags{detInd-1}(cIdx)=gateTags(1,chN_phot_gc{detInd-1}(cIdx,1));
        chN_phot_time{detInd-1}(cIdx,2)=times(cIdx)-chN_phot_gateTags{detInd-1}(cIdx,1);
        
        %         gateIdx=find(chN_phot_gc{detInd-1}(cIdx,2)==1,1);
        
        %         chN_phot_time{detInd-1}(cIdx,2)=times(cIdx)-chN_phot_gateTags{detInd-1}(gateIdx,1);
    end
    
    chN_phot_time{detInd-1}(:,1)=times-chN_phot_firstGateInCycle{detInd-1};
    %
%     for cIdx=firstGateInCycleIdx
%     chN_gates_each_cycle{detInd-1}=
    
    phot_per_cycle=phot_per_cycle+hist(chN_phot_cycles{detInd-1},max(chN_phot_cycles{1}));
    
    %find the gates per cycle per detector
    for ind=1:max(chN_phot_cycles{detInd-1})
        idx=chN_phot_cycles{detInd-1}==ind; %indices for this cycle
        chN_gates_each_cycle{detInd-1}(end+1)=max(chN_phot_gc{detInd-1}(idx,2));
    end
    
end
end
