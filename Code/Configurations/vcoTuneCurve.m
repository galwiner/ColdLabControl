load('COOLVCO_CAL.mat');
V=COOLVCO_CAL(:,1);
freq=COOLVCO_CAL(:,2);
[f,p]=fit(V,freq,'poly1');
figure;
hold on
plot(V,freq,'x');
plot(V,f(V),'r-');
xlabel('VCO TUNE[V]')
ylabel('VCO freq[MHz]')

title(['Cooling AOM VCO tuning curve f=' num2str(f.p1,'%.2f') 'V+' num2str(f.p2,'%.2f') 'MHz'] );
set(gcf,'color','w');




