%cooling power sweep with fast mode spectroscopy
clear all
global p

global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
p.hasScopResults=1;
p.hasPicturesResults=0;
p.picsPerStep = 0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
p.circCurrent = 40;
initinst
initr
p.expName = 'Dipole Trap depth via probe';
%% 
inst.BiasCoils{1}.configTriggedPulse(-0.0744,-0.08,2e6);
p.trapTime = 200e3;
p.MWPulseTime = 110;
resFreq = 34.678261;
detVals = linspace(-70e-3,-35e-3,15);
p.loopVals{1} = resFreq+detVals;
p.loopVars{1} = 'MWFreq';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.s=sqncr();
p.s.addBlock({'SetMWFreq','frequency',p.MWFreq});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','low','duration',0});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','value','high','channel','BIASPSU_TRIG','duration',100});
p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','value','high','duration',1000});
p.s.addBlock({'pause','duration',40e3});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});

p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',10});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','high','duration',0});
p.s.addBlock({'setDigitalChannel','channel','MWSourceSwitch','value','high','duration',p.MWPulseTime});
p.s.addBlock({'pause','duration',p.MWPulseTime});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',10});
p.s.addBlock({'pause','duration',10});
p.s.addBlock({'pause','duration',p.trapTime});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.run();
%
pulses = {};
data = squeeze(r.scopeRes{1}(:,5,:));
for ii = 1:size(data,2)
    smData(:,ii) = smooth(data(:,ii),10);
    tmpPulses = findPulses(smData(:,ii));
    pulses{ii} = tmpPulses;
    refLev(ii) = mean(data(tmpPulses{1}(1):tmpPulses{1}(2),ii));
    absoLev(ii) = mean(data(tmpPulses{2}(1):tmpPulses{2}(2),ii));
end

% midPoint = round(size(data,1)/2);
% refLev = max(data(1:midPoint,:),[],1);
% absLev = max(data(midPoint:end,:),[],1);
abso = log(refLev./absoLev);
figure;
plot(detVals,abso)

