%script for the fast mode spectroscopy plot
global r
clear abso
clear fitList gof_list
clear gamma
if ~isfield(p,'supergateNum')
    p.supergateNum=1;
end
cycleTime=p.gateTime/2*p.gateNum;
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




% PhotPerCycle{end}=removeBadCyclesandMean({local_chN_phot_cycles{:,p.supergateNum}},p.NAverage);

%noise rate is in units of [photons per us]
if ~isfield(p,'noiseRate') 
    p.noiseRate = 0;
end
% if ~isfield(p,'bgRate')
%     p.bgRate = max(PhotPerCycle{end});
% end
% abso{end} = (PhotPerCycle{p.supergateNum}-p.noiseRate/p.supergateNum*cycleTime)./(p.bgRate/p.supergateNum*cycleTime-p.noiseRate/p.supergateNum*cycleTime);
% [OD,Gamma,maxVal,bias,delta0]

%looping over supergates (frequencies in this case)
PhotPerFreq=[];
abso=[];

for ind=1:p.supergateNum
gmax=idxList(ind,2);
gmin=idxList(ind,1);
chN_phot_freq{1,ind}=sum(chN_phot_gc{1}(:,2)<=gmax & chN_phot_gc{1}(:,2)>=gmin);
chN_phot_freq{2,ind}=sum(chN_phot_gc{2}(:,2)<=gmax&chN_phot_gc{2}(:,2)>=gmin);
PhotPerFreq(ind)=chN_phot_freq{1,ind}+chN_phot_freq{2,ind};
if ~isfield(p,'noiseRate')
    p.noiseRate = 0;
end
% p.bgRate = probePower2CountRate(p.probePower);

% [OD,Gamma,maxVal,bias,delta0]
end
if ~isfield(p,'plotSmooth')
    p.plotSmooth = 1;
end
origPhotPerFreq = PhotPerFreq;
PhotPerFreq = smooth(PhotPerFreq,p.plotSmooth);
p.bgRate = max(PhotPerFreq)*p.supergateNum/cycleTime;
abso = (PhotPerFreq-p.noiseRate/p.supergateNum*cycleTime)./(p.bgRate/p.supergateNum*cycleTime-p.noiseRate/p.supergateNum*cycleTime);
freqs = smooth(freqs,p.plotSmooth);
if ~isfield(p,'EIT')||p.EIT==0
initParams = [20,3,1,8e-3,-3];
lowPar = [0,3,0.9,0,-6];
upPar = [100,3,1.1,1e-2,4];

[f,gof,~,~]=fitExpLorentzian(freqs',abso',initParams,lowPar,upPar);
idx=size(r.OD,2)+1;
r.OD(1,idx)=f.OD;
err=confint(f);
r.OD(2,idx)=err(1,1);
r.OD(3,idx)=err(2,1);

figure(FigNumber);
subplot(2,1,1)
hold off
plot(freqs,abso,'-')
% plot(freqs,PhotPerFreq,'-')
ylim([-0.05 1.1]);
xlabel('delta [MHz]');
ylabel('T');
hold on
plot(freqs,f(freqs))
str = sprintf('OD=%.2f',r.OD(1,idx));
title(str)
subplot(2,1,2)
% errorbar(1:size(r.OD,2),r.OD(1,:),r.OD(2,:),r.OD(3,:),'o-')
plot(1:size(r.OD,2),r.OD(1,:),'o-')
elseif p.EIT==1
    figure(FigNumber);
    plot(freqs,abso,'-')
    ylim([-0.05 1.1]);
end
% gamma(ind)=fitList{ind}.Gamma;
% rsquared(ind)=gof_list{ind}.rsquare;
% lastParams(1) = fitList{end}.OD;
% lastParams(2) = fitList{end}.Gamma;
% lastParams(3) = fitList{end}.maxVal;
% lastParams(4) = fitList{end}.bias;
% lastParams(5) = fitList{end}.delta0;
% 
% end
% minLength = inf;
% for ii=1:length(abso)
%     if length(abso{ii})<minLength
%         minLength = length(abso{ii});
%     end
% end
% figure;
% % hold all
% subplot(1,2,1);
% for ind=1:length(abso)    
% plot(freqs(1:minLength),abso{ind}(1:minLength),'-.')
% hold on
% end
% xlabel('delta [MHz]');
% ylabel('Transmission');
% title(sprintf('probe spectroscopy averaged over %d gates',delta));
% subplot(1,2,2);
% plot(mean(idxList,2),OD,'-o');
% xlabel('center gate #');
% ylabel('OD');
% title(sprintf('OD averaged over %d gates, plotted at center gate num',delta));
% 
% % figure;
% % for ind=1:p.supergateNum
% %      subplot(ceil(p.supergateNum/4),4,ind);
% %     plot(freqs(1:length(abso{ind})),abso{ind},'o');
% %     hold on
% %     plot(linspace(freqs(1),freqs(end),1000),fitList{ind}(linspace(freqs(1),freqs(end),1000)),'-');
% % end
% clear absoMat
% for ii=1:length(abso)
%     absoMat(:,ii) = abso{ii}(1:minLength);
% end
% figure;
% gateNums = (p.gateNum/p.supergateNum/2):p.gateNum/p.supergateNum:...
%     (p.gateNum/p.supergateNum/2+(p.supergateNum-1)*p.gateNum/p.supergateNum);
% TimeFromForStart = p.gateTime*gateNums;
% imagesc(TimeFromForStart,freqs(1:minLength),absoMat)
% 
% figure;
% subplot(2,2,1)
% plot(gateNums,OD)
% title('OD','fontsize',12)
% xlabel('Gate #','fontsize',12)
% subplot(2,2,2)
% plot(gateNums,gamma)
% title('\gamma','fontsize',12)
% xlabel('Gate #','fontsize',12)
% subplot(2,2,3)
% plot(gateNums,rsquared)
% title('rsquared','fontsize',12)
% xlabel('Gate #','fontsize',12)
% 
