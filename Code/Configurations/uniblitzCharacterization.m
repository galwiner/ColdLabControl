clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.picsPerStep=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
p.trigPulseTime=100;
p.NAverage=10;
initinst
initr
p.looping=1;
p.expName = 'uniblitz shutoff time';
%%
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','value','low','duration',0})
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','value','low','duration',0})
p.s.addBlock({'pause','duration',100e3});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'GenPause','duration',1e6});
p.s.run();

%%

dat=mean(r.scopeRes{1},5);
digDat=mean(r.scopeDigRes{1},5);
figure
yyaxis 'left'
plot(dat(:,1),dat(:,3))
hold on
yyaxis 'right'
plot(digDat(:,1),digDat(:,2))
% ylim([-0.1,1.2])
% t=digDat(:,1);
% t(find(digDat(:,2),1));

V=dat(:,3);
top=mean(V(t<0.00117))
t=dat(:,1);
tslice=t(t>0.001202);
Vslice=V(t>0.001202);
yyaxis 'left'
line([0 2e-3],[top ,top],'linewidth',4,'color','r')
line([0 2e-3],[top/3/exp(1) top/3/exp(1)],'linewidth',4,'color','r')