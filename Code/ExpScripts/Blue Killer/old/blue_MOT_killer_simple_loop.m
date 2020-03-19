% 5/1/2019 

steps=50;
startF=200;
stopF=220;
freqs=linspace(startF,stopF,steps);
revFreqs=linspace(stopF,startF,steps);

clear DDS
clear sc
DDS=IOnitDDS(0,0,1,0,1,0,'COM19');
freq=stopF;
% while freq>20
%     DDS.setFreq(freq)
%     freq=freq-2.5;
%     pause(1)
% end

sc=keysightScope('10.10.10.118','','ip');
sc.setNumPoints(50000);
dat=zeros(steps,50000,5);

for ind=1:steps
%     t=tic;
    DDS.setFreq(freqs(ind));
    pause(2);
    sc.setState('stop');
    dat(ind,:,:)=sc.getChannels();
    sc.setState('run');
%     ellapsed_time=toc(t);
%     if ellapsed_time<2
%         pause(2-ellapsed_time)
%     end
    pause(2);
end

avg_pmt=mean(dat(:,:,2),2);
figure;
plot(freqs,avg_pmt,'o-')
xlabel('DDS freq [MHz]')
ylabel('PMT [V]')
title('MOT fluorescence(Blue offset)')
