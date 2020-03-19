%This experiment tests the bias boils 

clear all
imaqreset
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
p.picsPerStep=15;
if mod(p.picsPerStep,2)==0
    error('picsPerStep must be odd!')
end
p.pfPlaneLiveMode=0;
p.pfTopLiveMode=0;
p.postprocessing=0;
p.DEBUG=DEBUG;
p.expName = 'biasCoilVerificationViaMolsses';
p.cameraParams{1}.E2ExposureTime = 500;
p.cameraParams{2}.E2ExposureTime = 800;
initinst
initr
p.s.getbgImg;
%% setup seq

p.SettleTime = 10;
p.TimeBetweenPics=80e3;

p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'pause','duration',p.SettleTime});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','pixelflyTrig','duration',20,'value','High','description','picture:trigger photo'});
p.s.addBlock({'setDigitalChannel','channel','ThorcamTrig','duration',20,'value','High','description','picture:trigger photo'});
for ii = 1:(p.picsPerStep-1)/2
p.s.addBlock({'pause','duration',p.TimeBetweenPics});
p.s.addBlock({'setDigitalChannel','channel','pixelflyTrig','duration',20,'value','High','description','picture:trigger photo'});
p.s.addBlock({'setDigitalChannel','channel','ThorcamTrig','duration',20,'value','High','description','picture:trigger photo'});
p.s.addBlock({'pause','duration',p.TimeBetweenPics});
p.s.addBlock({'setDigitalChannel','channel','pixelflyTrig','duration',20,'value','High','description','picture:trigger photo'});
p.s.addBlock({'setDigitalChannel','channel','ThorcamTrig','duration',20,'value','High','description','picture:trigger photo'});
end
p.looping = int16(1);
p.s.run();
% Ploting
% yPos = r.fitParams{1}(3,:);
% yPos(yPos==0)=[];
% zPos = r.fitParams{1}(4,:);
% zPos(zPos==0)=[];
imageViewer(r.images{1}-r.bgImg{1});
% suptitle(sprintf('I_x=%.4f A I_y=%.4f A I_z=%.4f A',p.HHXCurrent,p.HHYCurrent,p.HHZCurrent))
% figure;
% subplot(2,1,1)
% plot(0:40:(length(yPos)-1)*40,yPos,'-o','LineWidth',2);
% ylabel('Cloud y position');
% set(gca,'FontSize',16)
% 
% subplot(2,1,2)
% plot(0:40:(length(zPos)-1)*40,zPos,'-o','LineWidth',2);
% xlabel('Time [ms]')
% ylabel('Cloud z position');
% suptitle(sprintf('Cloud center vs time during molasses. I_y = %s I_z = %s',num2str(p.HHYCurrent),num2str(p.HHZCurrent)))
% set(gca,'FontSize',16)

imageViewer(r.images{2}-r.bgImg{2},[],[],[],[],1);
% suptitle(sprintf('I_x=%.4f A I_y=%.4f A I_z=%.4f A',p.HHXCurrent,p.HHYCurrent,p.HHZCurrent))
