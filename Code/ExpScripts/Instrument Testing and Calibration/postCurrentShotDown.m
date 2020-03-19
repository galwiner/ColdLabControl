clear all
global p

global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
% p.circCurrent = 150*10/220;
p.hasScopResults=1;
p.hasPicturesResults=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
initinst
initr
% inst.scopes{1}.setProbeRatio(2,10) %set chan 2 probe ratio to 10
p.expName='Post current shot down';

%%
nsteps = 30;
circCurrentVals = linspace(30,220,nsteps);
p.circCurrent = p.INNERLOOPVAR;
p.loopVals{1} = circCurrentVals;
p.loopVars{1} = 'circCurrent';
p.MOTLoadTime = 100e3;
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'Release MOT'});
p.s.run();

%%
clear locs
clear pks
clear smData
clear goodData
clear goodDataInds
data = squeeze(r.scopeRes{1}(:,2,:));
smFactor = 30;
for ii = 1:size(data,2)
smData(:,ii) = smooth(data(:,ii),smFactor);
end
time = r.scopeRes{1}(:,1,1);
smTime = smooth(time,smFactor);
% plot(time,data(:,2))
% hold on;
% plot(smTime,smData(:,2))
for ii = 1:size(data,2)
[tmpPks,tmpLocs]=findpeaks(smData(:,ii),'MinPeakProminence',0.04);
if length(tmpPks)~= 1||length(tmpLocs)~=1
warning(sprintf('on ii = %d, %d peaks found',ii,length(tmpPks)));
pks(ii) = nan;
locs(ii) = nan;
else
   pks(ii) = tmpPks;
   locs(ii) = tmpLocs;
end
end
noNans =find(~isnan(pks));
noNanLocs = locs(noNans);
noNanPks = pks(noNans);
subplot(1,2,1)
plot(p.loopVals{1}(noNans),(smTime(noNanLocs)-6.5e-5)*1e6,'-o')
ylabel('Current spike appearance time [\mus]')
xlabel('Initial coil current [A]')
set(gca,'FontSize',22)
subplot(1,2,2)
hold on
%LEM A/V ratio was deduced from data to be 30A/0.72V=41.66A/V
LEMA2V = 30/0.72;
data = smData;
time = smTime;
for ii = 1:nsteps
    goodDataInds = find(data(:,ii)*LEMA2V<5);
    plot(time(goodDataInds)*1e6,data(goodDataInds,ii)*LEMA2V+(ii-1)*5,'-');
    if ~isnan(locs(ii))
    plot(smTime(locs(ii))*1e6,smData(locs(ii),ii)*LEMA2V+(ii-1)*5,'ko','markers',4)
    end
end
ylim([(min(data(:)*LEMA2V))-5 max(data(goodDataInds,ii)*LEMA2V)+(nsteps)*5])
xlabel('Time after current shut-off[\mus]')
ylabel('Coli current [A]')
set(gca,'FontSize',22)
% hold on;
% plot(locs,pks)