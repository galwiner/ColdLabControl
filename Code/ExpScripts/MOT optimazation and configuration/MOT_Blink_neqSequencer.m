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
p.expName='MOT Blink';

%%
p.circCurrent = 220;
p.MOTLoadTime = 100e3;
for ii = 1:50
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'Release MOT'});
p.s.run();
pause(1)
end

