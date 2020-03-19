%CW mot raman feature measurement


clear all
% global p

% global r
% global inst
DEBUG=0;
% init(DEBUG);

scp=keysightScope('10.10.10.118','scope','ip');
cooling=ICELaser('COM8',2,3,4);
initp;
initr;
gamma=linspace(-6,-1,15)*p.consts.Gamma;
for ind=1:length(gamma)
cooling.setIntFreq(coolingDetToFreq(gamma(ind),8));
pause(1);
r.dat(ind,:,:)=scp.getChannels;
end
customsave;

figure
for ind=1:length(gamma)
    time(ind,:)=r.dat(ind,:,1);
    probe(ind,:)=r.dat(ind,:,5);
    sas(ind,:)=r.dat(ind,:,2);
    plot(time(ind,:),probe(ind,:));
    hold on;
    
end

plot(time(ind,:),sas(ind,:));

% 
% % s=sqncr();
% initp
% p.hasScopResults=1;
% p.hasPicturesResults=0;
% p.pfLiveMode=1;
% p.tcLiveMode=1;
% p.postprocessing=0;
% p.DEBUG=DEBUG;
% initinst
% initr
% p.s.addBlock({'Load MOT'})
% p.looping = int16(1);
% p.s.run();
