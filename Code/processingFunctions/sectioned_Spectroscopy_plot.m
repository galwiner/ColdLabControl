%script to plot OD at different gate super-gate lengths
clear abso
clear PhotPerCycle
clear fitList gof_list
clear gamma
% p.supergateNum=5;
noise=0;
% bg=3000;
if ~isfield(p,'supergateNum')
    p.supergateNum=25;
end

idxList=[];
delta=floor(p.gateNum/p.supergateNum);
if p.supergateNum==1
idxList=[1,delta];
else
for ind=1:p.supergateNum-1
idxList(ind,:)=[1+(ind-1)*delta,delta*ind];
end
idxList(end+1,:)=[1+(ind)*delta,p.gateNum];

end



freqs=linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum);
fitList={};
gof_list={};
OD=[];
rsquared=[];
PhotPerCycle={};
abso={};
cycleTime = (p.gateTime/2)*p.gateNum;
for ind=1:p.supergateNum
gmax=idxList(ind,2);
gmin=idxList(ind,1);
local_chN_phot_cycles{1,ind}=chN_phot_cycles{1}(chN_phot_gc{1}(:,2)<=gmax & chN_phot_gc{1}(:,2)>=gmin);
local_chN_phot_cycles{2,ind}=chN_phot_cycles{2}(chN_phot_gc{2}(:,2)<=gmax&chN_phot_gc{2}(:,2)>=gmin);
if isempty(local_chN_phot_cycles{1,ind})||isempty(local_chN_phot_cycles{2,ind})
    PhotPerCycle{end+1} = nan;
    abso{end+1} = nan;
    continue
end
PhotPerCycle{end+1}=removeBadCyclesandMean({local_chN_phot_cycles{:,ind}},p.NAverage);
if ~isfield(p,'noiseRate')
    p.noiseRate = 0;
end
if ~isfield(p,'bgRate')
    p.bgRate = probePower2CountRate(p.probePower);
end

% bgRate=1;
abso{end+1} = (PhotPerCycle{ind}-p.noiseRate/p.supergateNum*cycleTime)./(p.bgRate/p.supergateNum*cycleTime-p.noiseRate/p.supergateNum*cycleTime);
% abso{end+1} = PhotPerCycle{:,ind};
end
freqs=linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum);
minLength = inf;
for ii=1:length(abso)
    if length(abso{ii})<minLength
        minLength = length(abso{ii});
    end
end
figure;
for ind=1:length(abso)    
plot(freqs(1:minLength),abso{ind}(1:minLength),'-.')
hold on
end
xlabel('delta [MHz]');
ylabel('Transmission');
% ylim([0,1.1])
title(sprintf('probe spectroscopy averaged over %d gates',delta));
clear absoMat

for ii=1:length(abso)
    absoMat(:,ii) = abso{ii}(1:minLength);
end

gateNums = (p.gateNum/p.supergateNum/2):p.gateNum/p.supergateNum:...
(p.gateNum/p.supergateNum/2+(p.supergateNum-1)*p.gateNum/p.supergateNum);
figure;
imagesc(gateNums,freqs(1:minLength),absoMat)
