function [chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell2(sortedPulses,cycleTime,thresholdTime)

%generate a structure under MIT naming and data structure. see onenote
%page: "Structure of MIT data for G2 post processing"

%first row is gate times
% chN_phot_cycles=0;
% chN_phot_time=0;
if nargin==2
    thresholdTime=0.5;
end

phot_per_cycle=0;

gateTags(1,:)=double(sortedPulses{1})*1e-6; %to uS
lastGateInCycleIdx=find(diff(gateTags(1,:))>cycleTime)+1; 
% find((diff(gateTags(1,:))>cycleTime/4))+1;
chN_phot_time=cell(1,length(sortedPulses)-1);
% chN_phot_masked=chN_phot_time;

if ~isempty(lastGateInCycleIdx)
%     lastGateInCycleIdx = length(gateTags(1,:));
cycleStopTimes=gateTags(1,lastGateInCycleIdx); %this isn't the cycle stop time though... it's either the last gate time or the first gate time, but not the cycle stop time. whatever it should be
else
    cycleStopTimes = [];
end
%second row is cycleNumber
% cycleStopTimes=gateTags(1,lastGateInCycleIdx); %finding at what time a cycles increments

% gateTags(2,find(gateTags(1,:)<=cycleStopTimes(1),inf,'last')) = 1;

chN_gates_each_cycle{1}=histcounts(gateTags(1,:),[gateTags(1,1) cycleStopTimes inf]);
chN_gates_each_cycle{2}=chN_gates_each_cycle{1}; %for MIT backwards compatibility
repl=@(a,b) repmat(a,1,b); %function to zip two vectors together

for detInd=2:length(sortedPulses)
    fprintf('starting detector %d\n',detInd);
    times=double(sortedPulses{detInd})*1e-6; %to uS
    times([false diff(times)<25e-3])=[]; %kill parasitic photons (<25nS apart)
    times(times-gateTags(1,1)<0)=[];
    chN_phot_time{detInd-1}=zeros(length(times),2);
    chN_gates_each_cycle{detInd-1}=chN_gates_each_cycle{1};
    
%     chN_phot_masked{detInd-1}=zeros(length(times));
    
    photons_per_gate=histcounts(times,[gateTags(1,:) inf]);
    %03/10/19 - This line takes up most of the time of the script! 25 out of 33
    %seconds, for both detectors. Could we improve it?
    gc=arrayfun(repl,[1:length(gateTags(1,:))]',photons_per_gate','UniformOutput',false);
    chN_phot_gc{detInd-1}(:,1)=[gc{:}]';
    cycle_edges=[gateTags(1,1) cycleStopTimes inf];
    chN_phot_per_cycle{detInd-1}=histcounts(times,cycle_edges);
    cycleNum=length(chN_phot_per_cycle{detInd-1});
    pc=arrayfun(repl,[1:cycleNum]',chN_phot_per_cycle{detInd-1}','UniformOutput',false);
    chN_phot_cycles{detInd-1}=[pc{:}]';
%     phot_per_cycle=phot_per_cycle+chN_phot_per_cycle{detInd-1};
    photNum=length(times);
    for photInd=1:photNum %looping over the photons
        if mod(photInd,1e5)==0
            fprintf('photon num %d of %d in detector %d\n',photInd,photNum,detInd)
        end

        chN_phot_time{detInd-1}(photInd,1)=times(photInd)-cycle_edges(chN_phot_cycles{detInd-1}(photInd));
        chN_phot_time{detInd-1}(photInd,2)=times(photInd)-gateTags(1,chN_phot_gc{detInd-1}(photInd,1));
%         if chN_phot_time{detInd-1}(photInd,2)<0.5
%             chN_phot_masked{detInd-1}=1;
%         end
        if photInd==1
            chN_phot_gc{detInd-1}(photInd,2)=1;
            jumpVal=1;
        else 
            if (chN_phot_cycles{detInd-1}(photInd)-chN_phot_cycles{detInd-1}(photInd-1))==1
                chN_phot_gc{detInd-1}(photInd,2)=1;
                jumpVal=chN_phot_gc{detInd-1}(photInd,1);
            else
                chN_phot_gc{detInd-1}(photInd,2)=chN_phot_gc{detInd-1}(photInd,1)-jumpVal;
            end
        end
    end
%     cycleTime
    gateTime=(gateTags(1,2)-gateTags(1,1))/2;
    %changed on 03/10/19 to remove phoons from gateTime/2*1.5 (15 mus) and
    %not gateTime/2. This is to see if the probe shuts down fast.
%     missedGatesIdx=chN_phot_time{detInd-1}(:,2)>gateTime|chN_phot_time{detInd-1}(:,2)<thresholdTime;
    missedGatesIdx=chN_phot_time{detInd-1}(:,2)>gateTime*1.5|chN_phot_time{detInd-1}(:,2)<thresholdTime;
    
    
    
    chN_phot_time{detInd-1}(missedGatesIdx,:)=[];
    chN_phot_gc{detInd-1}(missedGatesIdx,:)=[];
    times(missedGatesIdx) = [];
%     parasiticPulseIdx=logical(vertcat(false,diff(chN_phot_time{detInd-1}(:,1)<25e-3)));
%     sum(parasiticPulseIdx==true)
%     chN_phot_time{detInd-1}(parasiticPulseIdx,:)=[];
%     chN_phot_gc{detInd-1}(parasiticPulseIdx,:)=[];
%     times(parasiticPulseIdx)=[];
    
%     phot_per_cycle=0;
    chN_phot_per_cycle{detInd-1}=histcounts(times,cycle_edges);
    cycleNum=length(chN_phot_per_cycle{detInd-1});
    pc=arrayfun(repl,[1:cycleNum]',chN_phot_per_cycle{detInd-1}','UniformOutput',false);
    chN_phot_cycles{detInd-1}=[pc{:}]';
    phot_per_cycle=phot_per_cycle+chN_phot_per_cycle{detInd-1};
    
    
    
    
end


end
