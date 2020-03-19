% 'Thorcam trigger test'

clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=0;
p.hasPicturesResults=1;
p.pfLiveMode=1;
p.tcLiveMode=0;
p.postprocessing=1;
p.DEBUG=DEBUG;
% p.expName='bias compensation with strong and week MOT';
numSteps = 1;
% p.loopVals = {linspace(-0.05,0.05,numSteps)};
% p.loopVars = {'HHXCurrent'};
% p.loopVars = {'settleTime'};
p.picsPerStep=14;
% numSteps=10;
p.NAverage=1;
% settleTimes = linspace(10,1e3,numSteps);
% p.loopVals={settleTimes};
% p.(p.loopVars{1})=p.INNERLOOPVAR;
initinst
initr
%%
% sc=keysightScope('10.10.10.118','MOTSCOPE','ip');
% sc.setState('single');
% p.cameraParams{2}.exposure=10000;
% updateThorcam
% tc=inst.cameras('thorcam');
% tc.clearTriggerCount
% tc.clearSeqMemory
% tc.setHWTrig;
pause(1)
p.s=sqncr();
% p.s.addBlock({'setDigitalChannel','value','low','channel','ThorcamTrig','duration',0});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'TakePic'});
for ii = 1:p.picsPerStep-1
p.s.addBlock({'pause','duration',500e3});
p.s.addBlock({'TakePic'});
end
p.s.addBlock({'GenPause','value','none','channel','none','duration',5e5});
p.s.run;

for ind=1:size(r.images{2},3)
    assert(1~=(all(all(r.images{2}(:,:,ind)==0))))
end
