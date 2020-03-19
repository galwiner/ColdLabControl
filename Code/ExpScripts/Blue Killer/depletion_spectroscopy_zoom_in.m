clear all
global p
global r
global inst
DEBUG=0;
initp
p.kdc = 1;
p.hasScopResults=1;
p.chanList = 1;
p.runSettlingLoop=0;
p.numOfScopPoints = 5e3;
initinst
initr
setControlPower('min');
inst.scopes{1}.sc.Timeout = 1;
inst.BiasFieldManager.I=p.Blue_Killer_I;
p.expName = 'depletion_spectroscopy_zoom_in';

p.MOTLoadTime=0.2e6;
p.loopVals = {};
p.loopVars = {};
p.s=sqncr();
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.CTRL480Shutter,'value','low','duration',0});
p.s.addBlock({p.compoundActions.LoadMOT});
p.s.addBlock({p.compoundActions.TrigScope});
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.CTRL480Shutter,'value','high','duration',0});
p.s.run
p.MOTRefVal = mean(r.scopeRes{1}(:,2));
p.s=sqncr();
p.s.addBlock({p.compoundActions.LoadMOT});
p.s.addBlock({p.compoundActions.ReleaseMOT});
p.s.addBlock({'pause','duration',1e5})
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.coolingSwitch,'value','high','duration',0});
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.repumpSwitch,'value','high','duration',0});
p.s.addBlock({'pause','duration',3e5})
p.s.addBlock({p.compoundActions.TrigScope});
p.s.addBlock({'pause','duration',3e5})
p.s.addBlock({p.compoundActions.LoadMOT});
p.s.run
p.LightBG = mean(r.scopeRes{1}(:,2));
%%
p.M2scanMode = 0;
p.NAverage=1;
% p.line = '92S';
p.line = '89D';
startVAl = 1255;
endVal = 1250;
p.loopVals{1}=startVAl:-1:endVal;
p.loopVars{1} = 'synthHDFreq';
p.(p.loopVars{1})=p.INNERLOOPVAR;
p.MOTLoadTime=0.2e6;
p.endPauseTime = 50e3;
resetControlLock(startVAl,'E')
p.s=sqncr();
p.s.addBlock({p.asyncActions.setSynthHDFreq,'freq',p.synthHDFreq})
p.s.addBlock({p.compoundActions.LoadMOT});

p.s.addBlock({p.compoundActions.TrigScope});
p.s.addBlock({p.atomicActions.GenPause,'duration',p.endPauseTime})
p.s.run();
% resetSolsTissResonatorSlow(Vend,Vstrat);
%AUTO_PLOTTING_STAGE (DO NOT CHANGE THIS LINE)
meanScpRes = squeeze(mean(r.scopeRes{1}(:,2,:),1));
meanScpRes(meanScpRes==0) = nan;
notmSpect = (meanScpRes-p.LightBG)/(p.MOTRefVal-p.LightBG);
switch p.line
    case '89D'
        p.plotVals = synthHDFreq2RydbergDet(p.loopVals{1},89,2,-1);
    case '92S'
        p.plotVals = synthHDFreq2RydbergDet(p.loopVals{1},92);
    case '90F'
       p.plotVals = synthHDFreq2RydbergDet(p.loopVals{1},90,3,-1);
    case '90P'
        p.plotVals = synthHDFreq2RydbergDet(p.loopVals{1},90,1,1);
end
figure;
plot(p.plotVals,notmSpect,'o-')
xlabel('Detuning [MHz]')
ylabel('Normalized MOT signal')
title(sprintf('Zoom in on %s line',p.line))
set(gca,'fontsize',14)
% xlim([-50 max(p.plotVals)])
customsave_fig()
