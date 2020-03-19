clear all
instrreset
dds = Shovach;
messNum = 20;
freqs = linspace(225,375,messNum);
for ii = 1:messNum
dds.setFreq(4,freqs(ii),0,0);
pause(1)
Value = MeasPowerMeter;
power(ii) = mean(Value);
end
save('D:\Box Sync\Lab\ExpCold\Measurements\2018\07\15\071518_01','freqs','power','totPower');
%%
figure;
plot(freqs,power/totPower,'-o','LineWidth',2)
xlabel('RF frequency [MHz]');
ylabel('1^{st} order efficiency [%]')
set(gca,'FontSize',16)