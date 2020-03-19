clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=1;
p.chanList = [1,2];
p.runSettlingLoop=0;
p.kdc = 1;
initinst
initr

%%
p.measTime = 3e6;
p.trigPulseTime = 1e4;
inst.scopes{1}.setAcquisitionType('HRES');
inst.scopes{1}.setTimebase(p.measTime*1e-6)
inst.scopes{1}.setDelay(p.measTime*1e-6/2-0.05);
inst.BiasFieldManager.I=p.Blue_Killer_I;
p.expName = 'MOT_decay_vs_control_power';
p.MOTLoadTime=0.25e6;
p.loopVals = {};
p.loopVars = {};
p.s=sqncr();
p.s.addBlock({p.compoundActions.ReleaseMOT});
p.s.addBlock({'pause','duration',1e5});
p.s.addBlock({p.compoundActions.TrigScope});
p.s.run
p.NoLightVal = mean(r.scopeRes{1}(:,2));
p.s=sqncr();
p.s.addBlock({p.compoundActions.ReleaseMOT});
p.s.addBlock({'pause','duration',1e5});
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.coolingSwitch,'value','high','duration',0})
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.repumpSwitch,'value','high','duration',0})
p.s.addBlock({p.compoundActions.TrigScope});
p.s.run
p.NoAtomsVal = mean(r.scopeRes{1}(:,2));
p.MOTLoadTime=3e6;
p.s=sqncr();
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.ControlSwitch,'value','low','duration',0})
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.CTRL480Shutter,'value','low','duration',0})
p.s.addBlock({'pause','duration',1e4});
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.ControlSwitch,'value','high','duration',0})
p.s.addBlock({p.compoundActions.TrigScope});
p.s.addBlock({p.compoundActions.LoadMOT});
p.s.run
p.bare_MOT_loading = r.scopeRes{1}(:,2);
pause(10);
p.M2scanMode = 0;
p.NAverage=1;
p.min_power = 1.6;
p.max_power = 85;
% p.min_power = 0.01;
% p.max_power = 1.5;
p.rabis = logspace(log10(sqrt(p.min_power)),log10(sqrt(p.max_power)),40);
p.loopVals{1} = p.rabis.^2;
p.loopVars{1} = 'controlPower';
p.controlPower = p.INNERLOOPVAR;
% p.controlND = [16];
p.controlND = [];
p.level = '91S';
if isempty(p.controlND)
  p.control_pd_gain = 40;
    p.control_pd_nd = '2_01';  
else
p.control_pd_gain = 30;
p.control_pd_nd = '0';
end
p.s=sqncr();
if isempty(p.controlND)
p.s.addBlock({p.asyncActions.setControlPower,'power',p.controlPower})
else
    p.s.addBlock({p.asyncActions.setControlPower,'power',p.controlPower,'ND',p.controlND})
end
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.ControlSwitch,'value','low','duration',0})
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.CTRL480Shutter,'value','high','duration',0})
p.s.addBlock({'pause','duration',1e4});
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.ControlSwitch,'value','high','duration',0})
p.s.addBlock({p.compoundActions.TrigScope});
p.s.addBlock({'pause','duration',p.measTime})
p.s.addBlock({p.atomicActions.setDigitalChannel,'channel',p.chanNames.CTRL480Shutter,'value','low','duration',0})
p.s.addBlock({p.atomicActions.GenPause,'duration',1e6});
p.s.run();



%AUTO_PLOTTING_STAGE (DO NOT CHANGE THIS LINE)

plot_MOT_decay_vs_control_power;
% sm = 100;
% 
% % title(sprintf('Control power = %2.2f [mW]',p.controlPower))
% t0Ind = find(r.scopeDigRes{1}(:,2,1)==1,1)*2+100;
% t0 = r.scopeRes{1}(t0Ind,1,1);
% tf = 1.5+t0;
% tfInd = find(r.scopeRes{1}(:,1,1)>tf,1)-100;
% figure;
% hold on
% leg = {};
%   sm = 100;
%   ip = [0,0.5];
%   fos = {};
%   r2 = zeros(1,length(p.loopVals{1}));
%   N0 = r2;
%   coefs = zeros(2,length(p.loopVals{1}));
% 
% T = r.scopeRes{1}(t0Ind:tfInd,1,1)-t0;
% for ii = 1:length(p.loopVals{1})
%     plot(smooth(r.scopeRes{1}(t0Ind:tfInd,1,1),sm),smooth(squeeze(r.scopeRes{1}(t0Ind:tfInd,2,ii)-p.NoAtomsVal),sm))
% D = r.scopeRes{1}(t0Ind:tfInd,2,ii);
% if ii==24
%     coefs(:,ii) = nan(2,1);
%     continue
% end
% [fos{end+1},gof,output] = fitMOTDecay(T,D-p.NoAtomsVal,ip);
% r2(ii) = gof.rsquare;
% coefs(:,ii) = coeffvalues(fos{end});
% N0(ii) = mean(D(1:101));
% 
% leg{end+1} = num2str(p.loopVals{1}(ii),'%0.3f');
%     plot(T,fos{end}(T),'--')
%     leg{end+1} = 'fit';
% 
% end
% 
% 
% legend(leg)
% xlabel('time [s]');
% ylabel('MOT signal');
% set(gca,'fontsize',14)
% coefs_sorted = coefs;
% Nf = coefs_sorted(1,:);
% betta = coefs_sorted(2,:);
% rabi = getRabiRb87Sn(p.loopVals{1}*1e-3,13*1e-3,101);
% figure;
% yyaxis left
% plot(p.loopVals{1},Nf./N0,'-o','LineWidth',2)
% ylabel('N_f/N_0');
% yyaxis right
% plot(p.loopVals{1},betta,'-o','LineWidth',2)
% xlabel('control power [mW]');
% ylabel('decay rate [s^-1]');
% title('Fit modle: N=(N_0-N_f)*e^{-\beta*t}+N_f. N_f and \beta fit params')
% set(gca,'fontsize',14)
% 
% 
% figure;
% yyaxis left
% plot(rabi,Nf./N0,'-o','LineWidth',2)
% ylabel('N_f/N_0');
% yyaxis right
% plot(rabi,betta,'-o','LineWidth',2)
% xlabel('control rabi [MHz]');
% ylabel('decay rate [s^-1]');
% title('Fit modle: N=(N_0-N_f)*e^{-\beta*t}+N_f. N_f and \beta fit params')
% set(gca,'fontsize',14)
% 
