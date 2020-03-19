%script to plot OD at different gate super-gate lengths
clear abso
clear PhotPerCycle
clear fitList gof_list
clear gamma
if ~isfield(p,'supergateNum')
    p.supergateNum=1;
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
gof_list=cell(1,p.supergateNum);
OD=zeros(1,p.supergateNum);
rsquared=zeros(1,p.supergateNum);
PhotPerCycle=cell(1,p.supergateNum);
abso=cell(1,p.supergateNum);
cycleTime = 10*p.gateNum;
gmax=idxList(p.supergateNum,2);
gmin=idxList(p.supergateNum,1);
local_chN_phot_cycles{1,p.supergateNum}=chN_phot_cycles{1}(chN_phot_gc{1}(:,2)<=gmax & chN_phot_gc{1}(:,2)>=gmin);
local_chN_phot_cycles{2,p.supergateNum}=chN_phot_cycles{2}(chN_phot_gc{2}(:,2)<=gmax&chN_phot_gc{2}(:,2)>=gmin);
if isempty(local_chN_phot_cycles{1,p.supergateNum})||isempty(local_chN_phot_cycles{2,p.supergateNum})
    PhotPerCycle{end} = nan;
    abso{end} = nan;
end
PhotPerCycle{end}=removeBadCyclesandMean({local_chN_phot_cycles{:,p.supergateNum}},p.NAverage);
if ~isfield(p,'noiseRate')
    p.noiseRate = 0;
end
if ~isfield(p,'bgRate')
    p.bgRate = max(PhotPerCycle{end});
end
abso{end} = (PhotPerCycle{p.supergateNum}-p.noiseRate/p.supergateNum*cycleTime)./(p.bgRate/p.supergateNum*cycleTime-p.noiseRate/p.supergateNum*cycleTime);
% [OD,Gamma,maxVal,bias,delta0]
initParams = [5,3.05,1,-0.02,-3];
lowPar = [0,3.05,0.9,-0.04,-6];
upPar = [100,3.05,1.1,-0.01,4];
[fitList{p.supergateNum},gof_list{p.supergateNum},~,~]=fitExpLorentzian(freqs',abso{p.supergateNum},initParams,lowPar,upPar);
OD(end)=fitList{p.supergateNum}.OD;
gamma(p.supergateNum)=fitList{p.supergateNum}.Gamma;
rsquared(end)=gof_list{p.supergateNum}.rsquare;
lastParams(1) = fitList{end}.OD;
lastParams(2) = fitList{end}.Gamma;
lastParams(3) = fitList{end}.maxVal;
lastParams(4) = fitList{end}.bias;
lastParams(5) = fitList{end}.delta0;


for ind=1:p.supergateNum-1
gmax=idxList(ind,2);
gmin=idxList(ind,1);
local_chN_phot_cycles{1,ind}=chN_phot_cycles{1}(chN_phot_gc{1}(:,2)<=gmax & chN_phot_gc{1}(:,2)>=gmin);
local_chN_phot_cycles{2,ind}=chN_phot_cycles{2}(chN_phot_gc{2}(:,2)<=gmax&chN_phot_gc{2}(:,2)>=gmin);
if isempty(local_chN_phot_cycles{1,ind})||isempty(local_chN_phot_cycles{2,ind})
    PhotPerCycle{ind} = nan;
    abso{ind} = nan;
    continue
end
PhotPerCycle{ind}=removeBadCyclesandMean({local_chN_phot_cycles{:,ind}},p.NAverage);
if ~isfield(p,'noiseRate')
    p.noiseRate = 0;
end
if ~isfield(p,'bgRate')
    p.bgRate = max(PhotPerCycle{end});
end
abso{ind} = (PhotPerCycle{ind}-p.noiseRate/p.supergateNum*cycleTime)./(p.bgRate/p.supergateNum*cycleTime-p.noiseRate/p.supergateNum*cycleTime);
% [OD,Gamma,maxVal,bias,delta0]
if ind == 1
initParams = [20,gamma(p.supergateNum),1,-0.02,-3];
lowPar = [0,gamma(p.supergateNum),0.9,-0.04,-6];
upPar = [100,gamma(p.supergateNum),1.1,-0.01,4];

else
initParams = lastParams;
end
[fitList{ind},gof_list{ind},~,~]=fitExpLorentzian(freqs',abso{ind},initParams,lowPar,upPar);
OD(ind)=fitList{ind}.OD;
gamma(ind)=fitList{ind}.Gamma;
rsquared(ind)=gof_list{ind}.rsquare;
lastParams(1) = fitList{end}.OD;
lastParams(2) = fitList{end}.Gamma;
lastParams(3) = fitList{end}.maxVal;
lastParams(4) = fitList{end}.bias;
lastParams(5) = fitList{end}.delta0;

end
minLength = inf;
for ii=1:length(abso)
    if length(abso{ii})<minLength
        minLength = length(abso{ii});
    end
end
figure;
% hold all
subplot(1,2,1);
for ind=1:length(abso)    
plot(freqs(1:minLength),abso{ind}(1:minLength),'-.')
hold on
end
xlabel('delta [MHz]');
ylabel('Transmission');
title(sprintf('probe spectroscopy averaged over %d gates',delta));
subplot(1,2,2);
plot(mean(idxList,2),OD,'-o');
xlabel('center gate #');
ylabel('OD');
title(sprintf('OD averaged over %d gates, plotted at center gate num',delta));

% figure;
% for ind=1:p.supergateNum
%      subplot(ceil(p.supergateNum/4),4,ind);
%     plot(freqs(1:length(abso{ind})),abso{ind},'o');
%     hold on
%     plot(linspace(freqs(1),freqs(end),1000),fitList{ind}(linspace(freqs(1),freqs(end),1000)),'-');
% end
clear absoMat
for ii=1:length(abso)
    absoMat(:,ii) = abso{ii}(1:minLength);
end
figure;
gateNums = (p.gateNum/p.supergateNum/2):p.gateNum/p.supergateNum:...
    (p.gateNum/p.supergateNum/2+(p.supergateNum-1)*p.gateNum/p.supergateNum);
TimeFromForStart = p.gateTime*gateNums;
imagesc(TimeFromForStart,freqs(1:minLength),absoMat)

figure;
subplot(2,2,1)
plot(gateNums,OD)
title('OD','fontsize',12)
xlabel('Gate #','fontsize',12)
subplot(2,2,2)
plot(gateNums,gamma)
title('\gamma','fontsize',12)
xlabel('Gate #','fontsize',12)
subplot(2,2,3)
plot(gateNums,rsquared)
title('rsquared','fontsize',12)
xlabel('Gate #','fontsize',12)

