clear all

global p
global inst
global r

%initialize experiment data structure
initp

%% Experiment Name.
ExpName='MOTStability';

%% preparation
ExpFile=fullfile('experiments\pBank\',[ExpName '.mat']);
load(ExpFile,'p');

%load instruments and set up results data structure (order matters)
initinst
initr
%% modifications

%% RUN
% while 1
% p.s.run
% pause(6)
% end
p.s.run
%% data processing and display
% figure;
% imagesc(r.images{1});
% imageViewer([],[],squeeze(r.images{1}))
%  figure;
%  subplot(1,2,1)
%  imagesc(p.loopVals{1},p.loopVals{2}*220/10,r.Tx{1});
%  xlabel(p.loopVars{1});
%  ylabel(p.loopVars{2});
%  title('Tx');
% colormap('jet')
%  colorbar
%   set(gca,'FontSize',22)
% 
%   
%   subplot(1,2,2)
%  imagesc(p.loopVals{1},p.loopVals{2}*220/10,r.Ty{1});
%  xlabel(p.loopVars{1});
%  ylabel(p.loopVars{2});
%  title('Ty');
% colormap('jet')
%  colorbar
%  set(gca,'FontSize',22)
%  
%  r.atomNum = squeeze(atomNumberFromCollectionParams(inst.cameras('pixelfly').getExposure)*...
%      r.fitParams{1}(7,1,:,:));
% r.peakDensity=r.atomNum./squeeze(r.fitParams{1}(6,1,:,:))./squeeze(r.fitParams{1}(5,1,:,:).^2)/((2*pi)^(3/2)); %in 1/m^3
% r.peakDensity = r.peakDensity*1e-6; %in cm^-3;
% figure;
% subplot(1,2,1)
% imagesc(p.loopVals{1},p.loopVals{2}*220/10,r.atomNum);
% xlabel(p.loopVars{1});
% ylabel(p.loopVars{2});
% title('Atom Number');
% colormap('jet')
% colorbar
% set(gca,'FontSize',22)
% 
% subplot(1,2,2)
% imagesc(p.loopVals{1},p.loopVals{2}*220/10,r.peakDensity);
% xlabel(p.loopVars{1});
% ylabel(p.loopVars{2});
% title('r.peakDensity [cm^{-3}]');
% colormap('jet')
% colorbar
% set(gca,'FontSize',22)
%  
% %% Plot OD measurments from 070218 (see onenote)
% messNum = 3;
% fileName = ['D:\Box Sync\Lab\ExpCold\Measurements\2018\02\07\070218_0' num2str(messNum),'.mat'];
% data=load(fileName);
% probe = data.Trace_1(:,2);
% time = data.Trace_1(:,1);
% SAS = data.Trace_3(:,2);
% t0 = 0.0002656;
% dt = 0.0005318-0.0002656;
% df = 133;
% freq = df/dt*(time-t0);
% 
% figure;
% yyaxis left
% plot(freq,probe,'b')
% ylabel('probe transmission');
% set(gca,'FontSize',16)
% 
% yyaxis right
% plot(freq,SAS,'r')
% ylabel('SAS');
% set(gca,'FontSize',16)
% 
% xlabel('Detuning[MHz]')
