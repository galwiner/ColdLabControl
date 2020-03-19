clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults = 1;
p.chanList = [3,4];
initinst
initr
p.expName = 'Zeeman pump polarization tranzient';
%%

p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.ZEEMANSwitch,'duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.ZeemanShutter,'duration',0,'value','high'});
p.s.addBlock({p.compoundActions.TrigScope});
p.s.run;
p.s=sqncr();
p.s.addBlock({'setDigitalChannel','channel',p.chanNames.ZEEMANSwitch,'duration',0,'value','low'});
p.s.runStep
%%
t0Ind = 704;
t0 = r.scopeRes{1}(t0Ind,1);
r.scopeRes{1}(1:t0Ind-1,:) = nan;
figure;
t = tiledlayout('flow');
nexttile
yyaxis left
plot(r.scopeRes{1}(:,1)-t0,r.scopeRes{1}(:,4))
ylabel('P polarization signal [V]')
yyaxis right
plot(r.scopeRes{1}(:,1)-t0,r.scopeRes{1}(:,5))
ylabel('S polarization signal [V]')
xlabel('Time from AOM turn on [s]')
set(gca,'fontsize',14)
nexttile
plot(r.scopeRes{1}(:,1)-t0,r.scopeRes{1}(:,5)+r.scopeRes{1}(:,4))
ylabel('S+P polarizations signals [V]')
xlabel('Time from AOM turn on [s]')
title(t,'Polarization transient due to AOM turn on','fontsize',14) 
set(gca,'fontsize',14)