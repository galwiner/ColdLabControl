%test pixelfly trigger mechanism

clear all
global p

global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
% p.circCurrent = 150*10/220;
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=10;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
initinst
initr
%% test 
%NOTE: the minimum pause between trigger pulses is around 40mS!!.

p.s=sqncr();
for ind=1:p.picsPerStep
p.s.addBlock({'setDigitalChannel','channel','pixelflyTrig','duration',20,'value','High','description','picture:trigger photo'});
p.s.addBlock({'pause','duration',0.4e5});
end

p.looping = int16(1);
p.s.run();

assert(size(r.images{1},3)==p.picsPerStep,'Did not get correct number of images')
disp('Test passed');
% figure;
% subplot(3,1,1)
% imagesc(r.images{1}