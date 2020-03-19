%this scan is in two stages. data is saved to vars: data_stage1 and
%data_stage2. stage 1 has control on during the whole sqncr run. stage 2
%has control on half the time.

clear all
global p
global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
% p.circCurrent = 150*10/220;
p.hasScopResults=1;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
initinst
initr
% fclose(inst.DDS.s)
% SHU2_initial_2016(1,0,1)
% DRG_LAB_2(100,80,4e-6,4e-6,10000,10000)
p.probeRampUpTime = 400;
p.probeRampDownTime = 20;

p.probeRampSpan = 75;
% p.probeLockCenter = probeDetToFreq(0,1);
p.probeLockCenter = 400;
inst.DDS.setupSweepMode(4,p.probeLockCenter,p.probeRampSpan,p.probeRampUpTime,2,0,p.probeRampDownTime)
p.looping=1;

p.expName = 'RydbergEITFastMode';
%%
inst.DDS.setFreq(1,341.6,0,0);
p.repumpTime = 1;
p.DepumpTime= 400;
% p.loopVals{1} = [linspace(0.045,0.055,5),linspace(0.065,0.1,5)];
% p.loopVars{1} = 'DTParams.repumpLoadingPower';
% p.DTParams.repumpLoadingPower = p.INNERLOOPVAR;
p.tofTime = 1;
p.probeNDList=[1,2];
p.NAverage = 20;
p.probePower = 5e-9; %in mW
%% stage 1: control on for first and socond ramps
p.s=sqncr();
p.s.addBlock({'setProbePower','duration',0,'value',p.probePower,'channel','PRBVVAN'})
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
%repump
p.s.addBlock({'setRepumpDetuning','duration',0,'value',0});
p.s.addBlock({'setRepumpPower','duration',0,'value',18});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','high','description','REPUMP ON'});
% p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','high'});
p.s.addBlock({'pause','duration',100});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low','description','REPUMP OFF'});
p.s.addBlock({'pause','duration',p.tofTime});
% p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});

%turn on probe and control and wait a bit (20 us) for transient to settle
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',20});
p.s.addBlock({'TrigScope'});
%perform scan: full scan up and down and up again
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','high'});
p.s.addBlock({'pause','duration',p.probeRampUpTime});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','low'});
p.s.addBlock({'pause','duration',p.probeRampDownTime});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',20});
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','high'});

p.s.addBlock({'pause','duration',p.probeRampUpTime+50});
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',0,'value','low'});
%start depump
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
p.s.addBlock({'setCoolingPower','duration',0,'value',690});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'});
p.s.addBlock({'setDigitalChannel','channel','repumpSwitch','duration',0,'value','low'});
p.s.addBlock({'pause','duration',p.DepumpTime});
%cloud depumped, probe turn on so we can measure the base power
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','low'});
p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high'});
p.s.addBlock({'pause','duration',20});
%scan up again
p.s.addBlock({'setDigitalChannel','channel','DDS4_DRGCTRL','duration',p.probeRampUpTime+50,'value','high'});
p.s.addBlock({'pause','duration',p.probeRampUpTime+50});

%making sure DT is off
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
% p.s.addBlock({'pause','duration',4.1e3});
p.s.run();

data_stage1 = squeeze(r.scopeRes{1});
digData_stage1=squeeze(r.scopeDigRes{1});

p.s.run()
data_stage2 = squeeze(r.scopeRes{1});
digData_stage2=squeeze(r.scopeDigRes{1});
% processing
data_stage1=mean(data_stage1,3);
digData_stage1=mean(digData_stage1,3);
data_stage2=mean(data_stage2,3);
digData_stage2=mean(digData_stage2,3);
[freqs,startInds,endInds]=getDDSUpRampFreqVec(data_stage1(:,1,:),digData_stage1(:,3,:),digData_stage1(:,9,:),p.probeRampSpan,0);
up1_stage1=data_stage1(startInds(1):endInds(1),5); %first sweep, stage 1, probe ramp freq. towards + direction. 
up2_stage1=data_stage1(startInds(2):endInds(2),5);%2nd sweep, stage 1, probe ramp freq. towards + direction. 
norm_stage1=data_stage1(startInds(3):endInds(3),5);

minLen=min([length(norm_stage1),length(up1_stage1),length(up2_stage1)]);
% figure;
% plot(freqs{1}(1:minLen),up1_stage1(1:minLen)./norm_stage1(1:minLen),'r');
% hold on
% plot(freqs{2}(1:minLen),up2_stage1(1:minLen)./norm_stage1(1:minLen),'b');
% legend({'1st sweep','2nd sweep'})
% 
[freqs2,startInds,endInds]=getDDSUpRampFreqVec(data_stage2(:,1,:),digData_stage2(:,3,:),digData_stage2(:,9,:),p.probeRampSpan,0);
up1_stage2=data_stage2(startInds(1):endInds(1),5); %first sweep, stage 1, probe ramp freq. towards + direction. 
up2_stage2=data_stage2(startInds(2):endInds(2),5);%2nd sweep, stage 1, probe ramp freq. towards + direction. 
norm_stage2=data_stage2(startInds(3):endInds(3),5);
%
minLen2=min([length(norm_stage2),length(up1_stage2),length(up2_stage2)]);
% figure;
% plot(freqs2{1}(1:minLen2),up1_stage2(1:minLen2)./norm_stage2(1:minLen2),'r');
% hold on
% plot(freqs2{2}(1:minLen2),up2_stage2(1:minLen2)./norm_stage2(1:minLen2),'b');
% legend({'1st sweep','2nd sweep'})

figure;
plot(freqs{2}(1:minLen),up1_stage1(1:minLen)./norm_stage1(1:minLen),'r');
hold on
plot(freqs2{2}(1:minLen2),up1_stage2(1:minLen2)./norm_stage2(1:minLen2),'b');
legend({'1st sweep 1st stage','1st sweep 2nd stage'})

% 
% figure;
% plot(data_stage1,'b')
% hold on
% plot(data_stage2,'r')
% meanData = mean(data,2);
% 
% figure
% plot(meanData)
% 
% [Upfreq,UpStartInd,UpEndInd] = getDDSUpRampFreqVec(r.scopeRes{1}(:,1,1,1,1),r.scopeDigRes{1}(:,3,1,1,1),r.scopeDigRes{1}(:,9,1,1,1),75/2,200);
% [Downfreq,DownStartInd,DownEndInd] = getDDSDownRampFreqVec(r.scopeRes{1}(:,1,1,1,1),r.scopeDigRes{1}(:,3,1,1,1),r.scopeDigRes{1}(:,9,1,1,1),75/2,200);
% data2 = meanData(UpStartInd:UpEndInd);
% % data = smooth(data,100);
% bg = fliplr(meanData(DownStartInd:DownEndInd)')';
% % bg = smooth(bg,100);
% % bg = (r.scopeRes{1}(DownStartInd:DownEndInd,5,ii));
% if length(bg)>length(data2)
%     bg((length(data2)+1):end) = [];
% elseif length(bg)<length(data2)
%     data2((length(bg)+1):end) = [];
%     Upfreq((length(bg)+1):end) = [];
% end
% absor = data2./bg;
% plot(Upfreq-200,absor)
% xlabel('probe Detuning [MHz]')
% ylabel('Transmission')
% set(gca,'fontsize',16)
% 
% 
