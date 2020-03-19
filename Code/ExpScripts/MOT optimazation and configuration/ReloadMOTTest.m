%fast mode spectroscopy on a cold cloud, in live camera mode
clear all
global p

global r
global inst
DEBUG=0;
initp
p.hasScopResults=1;
p.hasPicturesResults=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
p.picsPerStep = 1;
p.HHXCurrent = -0.050;
p.HHZCurrent = 0.087;
initinst
initr
% r.LightBg = max(r.scopeRes{1}(:,3));
p.expName = 'Reload MOT Test';


%%
p.MOTReloadTime = 30e3;
p.MOTReleaseTime = 2e3;

p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'forStart'})
p.s.addBlock({'Release MOT'})
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'forEnd','value',300});
p.s.addBlock({'Release MOT'})
% p.s.addBlock({'Reload MOT'});
% p.s.addBlock({'Release MOT'})
% p.s.addBlock({'Reload MOT'});
% p.s.addBlock({'Release MOT'})
% p.s.addBlock({'Reload MOT'});
% p.s.addBlock({'Release MOT'})
% p.s.addBlock({'Reload MOT'});
% p.s.addBlock({'Release MOT'})
% p.s.addBlock({'Reload MOT'});
p.looping = int16(1);
p.s.run();