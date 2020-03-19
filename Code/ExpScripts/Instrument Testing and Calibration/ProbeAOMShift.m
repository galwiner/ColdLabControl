clear all
global p
global r
global inst
initp
p.hasTTresults = 1;
p.ttDumpMeasurement=1;
p.hasScopResults=1;
p.chanList = [1,2];
initinst
initr
scp = keysightScope('10.10.10.19',[],'ip');
fclose(scp.sc);
scp.sc.InputBufferSize = 5000000;
fopen(scp.sc);
scp.setNumPoints(1e8);
inst.scopes{1} = scp;
%%
p.expName = 'Probe AOM shift';
p.gateNum = 4000;
p.loopVals{1} = 1:50:(p.gateNum-50+1);
% p.loopVals{1} = 1:300:(p.gateNum-50+1);
% p.loopVals{1}=1;
p.loopVars{1} = 'preGates';
p.preGates = p.INNERLOOPVAR;
p.gateTime = 20;
p.trigPulseTime  = 10;
p.s=sqncr();
p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'forEnd','value',p.preGates});   
p.s.addBlock({'forStart'});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','high','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'setDigitalChannel','channel','ControlSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',p.gateTime/2});
p.s.addBlock({'forEnd','value',50});
p.s.addBlock({'TrigScope'});
p.s.run();
%
data = r.scopeRes{1};
s = {}; %spectrograms of channel 2: beatnote

s2 = {}; %spectrograms of channel 1: DDS output

dt=(data(2,1)-data(1,1));
for ii = 1:length(p.loopVals{1})
% figure;
% subplot(2,1,1)
[s{end+1},w,t] = spectrogram(data(:,3,ii),10000,[],[],1/(data(2,1)-data(1,1)));
[s2{end+1},w,t] = spectrogram(data(:,2,ii),10000,[],[],1/(data(2,1)-data(1,1)));
% xlim([100 120]*1e-3);
% subplot(2,1,2)
% spectrogram(data(:,2,ii),10000,[],[],1/(data(2,1)-data(1,1)));
% xlim([100 120]*1e-3);
end
%
wmin = 100e6;
wmax = 260e6;
dataDB = pow2db(abs(s{1}(w>wmin&w<wmax,:)));
for ii = 2:length(p.loopVals{1})
    dataDB = [dataDB pow2db(abs(s{ii}(w>wmin&w<wmax,:)))];
end
figure
subplot(2,2,1)
imagesc(w(w>wmin&w<wmax)*1e-6,linspace(0,20*max(t),size(dataDB,2)),dataDB')
title('Beatnote spectrogram (after 220kHZ High Pass Filter)');
xlabel('Freq [MHz]')
ylabel('t [s]')
h=colorbar;
ylabel(h, 'dB')
dataDB2 = pow2db(abs(s2{1}(w>wmin&w<wmax,:)));

for ii = 2:length(p.loopVals{1})
    dataDB2 = [dataDB2 pow2db(abs(s2{ii}(w>wmin&w<wmax,:)))];
end
subplot(2,2,2)
imagesc(w(w>wmin&w<wmax)*1e-6,linspace(0,20*max(t),size(dataDB2,2)),dataDB2')
title('DDS output spectrogram');
xlabel('Freq [MHz]')
ylabel('t [s]')
h=colorbar;
ylabel(h, 'dB')

subplot(2,2,3:4)
yyaxis left
plot(data(:,2,1),'DisplayName','DDS output');
yyaxis right
plot(data(:,3,1),'o-');
title('Time domain trace of channels 1,2','DisplayName','filtered beatnote');
xlabel('time [s]');
ylabel('Channel signal [V]');

