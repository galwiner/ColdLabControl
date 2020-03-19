clear all
global p
global r
global inst
DEBUG=0;
initp
p.FunctionGen = 1;
p.hasScopResults=0;
p.chanList = 1;
p.runSettlingLoop=0;
initinst
initr
inst.BiasFieldManager.I=[0.0500   -0.0895    0.100];
p.expName = 'depletion_spectroscopy';
inst.scopes{1} = keysightScope('10.10.10.118',[],'ip');

%%
inst.scopes{1}.setState('stop')
inst.scopes{1}.setState('single');
p.trigPulseTime = 100;
p.rigolSpan = 5; %in V
p.UpcanTime = 30; %in s
p.dounScanTime = 300;
p.s=sqncr();
p.s.addBlock({p.asyncActions.configRigolRampBurst,'freq',1/(p.UpcanTime+p.dounScanTime),'amp',p.rigolSpan,'offset',0,'phase',20,'symm',10,'chan',1,'nCyc',1});
p.s.runStep();
p.s=sqncr();
pause(1)
p.s.addBlock({p.asyncActions.configRigolRampBurst,'freq',1/(p.UpcanTime+p.dounScanTime),'amp',p.rigolSpan,'offset',0,'phase',20,'symm',10,'chan',2,'nCyc',1});
p.s.runStep();
pause(1)
p.s=sqncr();
p.s.addBlock({p.compoundActions.TrigScope});
p.s.runStep();
inst.scopes{1}.forceTrig
r.wlmRes  = zeros(1,p.dounScanTime/0.1);
for ii = 1:ceil(p.dounScanTime/0.1)
    if mod(ii,50)==0
        fprintf('step %0.0f out of %0.0f\n',ii,p.dounScanTime/0.1)
    end
    r.wlmRes(ii) = getWLMFreq(8);
    pause(0.1);
end
r.scopeRes = inst.scopes{1}.getChannels(1);
r.scopeDigRes = inst.scopes{1}.getDigitalChannels;
customsave;

%AUTO_PLOTTING_STAGE (DO NOT CHANGE THIS LINE)
%%
t0Ind = 2*find(r.scopeDigRes(:,1)==1);
tmpRes = r.scopeRes(t0Ind+1:end,2);

scanEndInd = 2457;
tvec = (0:p.dounScanTime/0.1-1)*0.1;
time = r.scopeRes(t0Ind+1:end,1)-r.scopeRes(t0Ind,1);
% tmpRes(time>tvec(end)) = [];
% time(time>tvec(end)) = [];
figure;
yyaxis left
plot(time,tmpRes)
yyaxis right
plot(tvec,r.wlmRes)
% blueDets = interpVec((r.wlmRes-r.wlmRes(1))*2*1e3); %interpulated dets in GHz
% motVals = zeros(1,length(blueDets));
% allMOTvals = r.scopeRes(t0Ind+1,2);
% motVals(1) = mean(allMOTvals(time<tvec(2)));
% for ii = 1:length(blueDets)
%     
% end
%%
% meanScpRes = squeeze(mean(r.scopeRes{1}(:,2,:),1));
% meanScpRes(meanScpRes==0) = nan;
% p.LightBG = 0.7334;
% notmSpect = (meanScpRes-p.LightBG)/(p.MOTRefVal-p.LightBG);
% plotVals = (r.TisaphFreqs-r.TisaphFreqs(1))*2*1e3;
% co = colororder;
% figure;
% plot(plotVals,notmSpect,'o-','MarkerEdgeColor',co(1,:))
% hold on
% ylims = ylim;
% nList = 85:97;
% sn = nList;
% d32n = sn;
% d52n = sn;
% sLines = (getRydbergTransFreq(nList)-r.TisaphFreqs(1)*2)*1e3;
% d32Lines = (getRydbergTransFreq(nList,2,3/2)-r.TisaphFreqs(1)*2)*1e3;
% d52Lines = (getRydbergTransFreq(nList,2,5/2)-r.TisaphFreqs(1)*2)*1e3;
% plotLims = [min(plotVals)-(max(plotVals)-min(plotVals))*0.01,max(plotVals)+(max(plotVals)-min(plotVals))*0.01];
% sn(sLines<plotLims(1)|sLines>plotLims(2)) = [];
% d32n(d32Lines<plotLims(1)|d32Lines>plotLims(2)) = [];
% d52n(d52Lines<plotLims(1)|d52Lines>plotLims(2)) = [];
% sLines(sLines<plotLims(1)|sLines>plotLims(2)) = [];
% d32Lines(d32Lines<plotLims(1)|d32Lines>plotLims(2)) = [];
% d52Lines(d52Lines<plotLims(1)|d52Lines>plotLims(2)) = [];
% for ii = 1:length(sLines)
%        plot(sLines(ii)*ones(1,100),linspace(ylims(1),ylims(2),100),'--k')
%        text(sLines(ii),ylims(1)+(ylims(2)-ylims(1))*0.1,sprintf(' %0.0fS',sn(ii)),'fontsize',12)
% end
% % plot(plotVals,spect2,'o-','MarkerEdgeColor',co(1,:),'Color',co(1,:))
% % plot(plotVals,spect3,'o-','MarkerEdgeColor',co(1,:),'Color',co(1,:))
% 
% for ii = 1:length(d32Lines)
%        plot(d32Lines(ii)*ones(1,100),linspace(ylims(1),ylims(2),100),'--k')
%        text(d32Lines(ii),ylims(1)+(ylims(2)-ylims(1))*0.1,sprintf(' %0.0fD_{3/2}',d32n(ii)),'fontsize',12)
% end
% for ii = 1:length(d52Lines)
%        plot(d52Lines(ii)*ones(1,100),linspace(ylims(1),ylims(2),100),'--k')
%        text(d52Lines(ii),ylims(1)+(ylims(2)-ylims(1))*0.2,sprintf(' %0.0fD_{5/2}',d52n(ii)),'fontsize',12)
% end
% % set(gca,'XTick',linspace(min(plotVals),max(plotVals),20))
% % set(gca,'XTickLabel',round(linspace(0,(max(plotVals)-min(plotVals))*1e3,20),1))
% xlabel(sprintf('Blue laser frequency relative to %0.5f [THz]', r.TisaphFreqs(1)*2));
% ylabel('Relative MOT intensity');
% set(gca,'fontsize',30)
% legend('Depletion spectroscopy','Literature','fontsize',20)
% ylim([0,1.2])
% grid('minor')
