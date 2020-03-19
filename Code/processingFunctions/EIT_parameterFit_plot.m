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
if ~isfield(p,'startGate')
    p.startGate = 0;
end
idxList=[];
delta=floor(p.gateNum/p.supergateNum);
if p.supergateNum==1
idxList=[1,delta]++p.startGate;
else
for ind=1:p.supergateNum-1
idxList(ind,:)=[1+(ind-1)*delta,delta*ind]+p.startGate;
end
idxList(end+1,:)=[1+(ind)*delta,p.gateNum]+p.startGate;
end



freqs=linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,p.freqNum);
fitList={};
gof_list={};
OD=[];
rsquared=[];
PhotPerCycle={};
abso={};
cycleTime = (p.gateTime/2)*p.gateNum;
% [OD,gamma,maxVal,Omega_c,gamma_s,bias,delta0_p,delta0_c]
initParams = [p.OD,p.Gamma,1.12,10,0.5,0,p.deltap,0];
lower = [0.5,p.Gamma,1.1,3,0.1,0,p.deltap,-30];
upper = [100,p.Gamma,1.2,15,10,0,p.deltap,30];
lastParams = zeros(p.supergateNum,8);
for ind=p.supergateNum:-1:1
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

abso{end+1} = (PhotPerCycle{end}-p.noiseRate/p.supergateNum*cycleTime)./(p.bgRate/p.supergateNum*cycleTime-p.noiseRate/p.supergateNum*cycleTime);
freqs=linspace(p.probeCenterOffset-p.probeRampSpan/2,p.probeCenterOffset+p.probeRampSpan/2,length(abso{end}));
if ~ind == p.supergateNum
    initParams = lastParams(ind+1,:);
end
% [OD,gamma,maxVal,Omega_c,gamma_s,bias,delta0_p,delta0_c]
idx = isfinite(abso{end});
[fitList{end+1},gof_list{end+1}]=fitEIT(freqs(idx)',abso{end}(idx),initParams,lower,upper);
lastParams(ind,:) = coeffvalues(fitList{end});
end
minLength = inf;
for ii=1:length(abso)
    if length(abso{ii})<minLength
        minLength = length(abso{ii});
    end
end
figure;
fitFreqs = linspace(min(freqs),max(freqs),1e3);
for ind=1:length(abso)
    if length(abso)==1
        plot(freqs(1:minLength),abso{ind}(1:minLength),'-.')
        hold on
        plot(fitFreqs,fitList{ind}(fitFreqs))
    else
        subplot(ceil(p.supergateNum/5),5,ind)
        plot(freqs(1:minLength),abso{ind}(1:minLength),'-.')
        hold on
        plot(fitFreqs,fitList{ind}(fitFreqs))
        ylim([0,1.1])
    end
end
xlabel('delta [MHz]');
ylabel('Transmission');
ylim([0,1.1])
% title(sprintf('probe spectroscopy averaged over %d gates',delta));
clear absoMat

for ii=1:length(abso)
absoMat(:,ii) = abso{ii}(1:minLength);
end
gateNums = (p.gateNum/p.supergateNum/2):p.gateNum/p.supergateNum:...
    (p.gateNum/p.supergateNum/2+(p.supergateNum-1)*p.gateNum/p.supergateNum);
figure;
imagesc(gateNums,freqs(1:minLength),fliplr(absoMat))
ylabel('Detuning [MHz]','fontsize',16)
xlabel('Gate Number','fontsize',16)
title('Transmission  vs detuning and gate number','fontsize',16)
colorbar
figure;
subplot(2,2,1)
plot(gateNums,lastParams(:,1))
title('OD','fontsize',16)
xlabel('gate number','fontsize',16)
ylabel('OD from fit','fontsize',16)
subplot(2,2,2)
plot(gateNums,lastParams(:,4))
title('\Omega_c','fontsize',16)
xlabel('gate number','fontsize',16)
ylabel('\Omega_c from fit [MHz]','fontsize',16)
subplot(2,2,3)
plot(gateNums,lastParams(:,5))
title('\gamma_r','fontsize',16)
xlabel('gate number','fontsize',16)
ylabel('\gamma_r from fit [MHz]','fontsize',16)
subplot(2,2,4)
plot(gateNums,lastParams(:,8))
title('\delta_c','fontsize',16)
xlabel('gate number','fontsize',16)
ylabel('\delta_c from fit [MHz]','fontsize',16)
figure;
subplot(1,2,1)
plot(freqs,abso{end})
title('Max OD Spectrum, normelized')
subplot(1,2,2)
plot(freqs,PhotPerCycle{end}/(delta*p.gateTime/2))
title('Max OD Spectrum, phot/\mus')

