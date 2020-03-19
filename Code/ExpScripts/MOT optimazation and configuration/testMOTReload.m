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
% p.HHXCurrent = 0.055;
p.HHXCurrent = -0.05;
initinst
initr
p.s = sqncr;
%get bg scope
% p.s.addBlock({'Release MOT'})
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high','description','MW spectro:cooling laser on'});
% p.s.addBlock({'pause','duration',10e3});
% p.s.addBlock({'TrigScope'});
% p.s.run;
% r.bgscope = r.scopeRes{1};
p.expName = 'Test MOT reload';
% scp = keysightScope('10.10.10.118','MOTSCOPE','ip');
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.runStep;
p.NAverage = 1;
%%



p.s=sqncr();
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'Release MOT'})
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'Release MOT'})
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'Release MOT'})
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'GenPause','duration',500e3});
p.looping = int16(1);
runtmr = tic;
p.s.run();
toc(runtmr)

%%
% bgres = mean(r.bgscope(:,3));
% transferEffitiency = squeeze(max(r.scopeRes{1}(:,3,:,:),[],1))-bgres;
% % [fitobject,gof,output] = fitRabiOscilations(p.loopVals{1},transferEffitiency,initParams,lower,upper);
% % time = linspace(p.loopVals{1}(1),p.loopVals{1}(end),300);
% detuning  = (p.loopVals{1} - 34.678261)*1000;
% figure;
% hold on
% if length(p.loopVals{2})>1
%     for ii=1:length(p.loopVals{2})
%         plot(detuning,transferEffitiency(ii,:)+(ii-1)*0.1,'-o','LineWidth',2)
%         legendList{ii} = sprintf('HHY current %0.2f [mA]',p.loopVals{2}(ii)*1e3);
%     end
%     legend(legendList); 
% else
%     plot(detuning,transferEffitiency,'-o','LineWidth',2)
% end
% xlabel('Deduning from theoretical resonance [kHz]')
% set(gca,'FontSize',22)