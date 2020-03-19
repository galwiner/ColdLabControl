%calibrate etalon to freq

m2=m2ctrl();
% m2.setEtalonLock('on');
% pause(1)
m2.setECDLock('on');
pause(1)
% m2.setResonatorPercentage(1)
freqs=[];
for ind=50:70
    disp(ind)
%     while ~strcmpi(m2.getECDLock,'on')
%         pause(0.4);
%     end
    m2.setResonatorPercentage(ind)
    pause(1);
    f=getWLMFreq();
    freqs(ind)=f(8);
end

figure;
plot(1:100,freqs,'o')
p=polyfit(1:100,freqs,1);
hold on;
plot(1:100,p(1).*[1:100]+p(2),'-r');
text(50,312.76,sprintf('slope=%.2f [MHz/percent]',p(1)*1e6))
xlabel('Resonator tune %')
ylabel('WLM reading [THz]')
