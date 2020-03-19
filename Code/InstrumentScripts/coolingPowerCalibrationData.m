%
% 
% clear all
% global p
% 
% global r
% global inst
% DEBUG=0;
% % init(DEBUG);
% 
% % s=sqncr();
% initp
% % p.circCurrent = 150*10/220;
% p.hasScopResults=0;
% p.hasPicturesResults=1;
% p.picsPerStep=4;
% p.pfLiveMode=1;
% p.tcLiveMode=1;
% p.postprocessing=0;
% p.calcTemp=0;
% p.DEBUG=DEBUG;
% p.TOFtimes=[300,1000,5000,10000];
% p.cameraParams{1}.E2ExposureTime=400;
% initinst
% initr

%probe power calibration curve

V=[0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,1,1.2,1.5,1.6,1.8,2,2.3,2.4,2.5,2.8,3,3.4,3.5,3.6]; %V
pwr=[]; %mW
%power measured after DPAOM 

% for ind=1:length(V)
% fprintf('voltage: %f\n',V(ind));
%     voltage=V(ind);
% p.s=sqncr();
% p.s.addBlock({'setAnalogChannel','channel','PRBVVAN','value',voltage/2,'duration',0});
% p.hasScopResults=0;
% p.s.run();
% pause(5);
% end

pwr(1)=55e-3;
pwr(2)=55e-3;
pwr(3)=55e-3;
pwr(4)=55e-3;
pwr(5)=55e-3;
pwr(6)=55e-3;
pwr(7)=55e-3;
pwr(8)=67e-3;
pwr(9)=1.34;
pwr(10)=3.24;
pwr(11)=6.68;
pwr(12)=7.87;
pwr(13)=10.25;
pwr(14)=12.57;
pwr(15)=16.00;
pwr(16)=17.16;
pwr(17)=18.3;
pwr(18)=21.57;
pwr(19)=23.55;
pwr(20)=26.81;
pwr(21)=27.49;
pwr(22)=28.03;


