% inst.BiasFieldManager.configBpulse([-0.1797,-0.5,0.5239],1e5);
% scp = keysightScope('10.10.10.118',[],'ip');
% scp.setState('single')
clear all
global p
global inst;
initp
p.hasScopResults = 0;
initinst
initr
p.expName = 'testBiasPSUOscillationsRemoval';

% inst.BiasFieldManager.abortTrigger;
% inst.BiasCoils{2}.setCurrent(1,0.03)
% firstB = [nan,nan,-0.01*inst.BiasFieldManager.conversionFactors(3)];
% secondB = [-0.1797,-0.5,0.5239];
% inst.BiasFieldManager.configDoubleBpulse(firstB,secondB,2e3,1e5);
p.biasField = -0.5;
p.runSettlingLoop = 0;
p.MagneticPulseTime = 1e5;
p.NAverage = 20;
p.s = sqncr;
% p.s.addBlock({p.compoundActions.LoadMOT});
% p.s.addBlock({p.compoundActions.TrigScope});
% % p.s.addBlock({'pause','duration',2e3});
% p.s.addBlock({p.compoundActions.ReleaseMOT});
% p.s.addBlock({'setDigitalChannel','channel','BIASPSU_TRIG','duration',1,'value','high'})
% p.s.addBlock({p.atomicActions.GenPause,'duration',1e6});
p.s.addBlock({p.compoundActions.LoadDipoleTrapAndPump});
% p.s.addBlock({p.compoundActions.TrigScope});
p.s.run;

% data = scp.getChannels;
% digData = scp.getDigitalChannels;
% save('D:\Box Sync\Lab\ExpCold\Measurements\2020\01\24\JumpToZeroBefore','data','p','digData');
% figure;
% plot(data(:,1),data(:,3))
figure;
plot(r.scopeRes{1}(:,1)*1e3,r.scopeRes{1}(:,3))
