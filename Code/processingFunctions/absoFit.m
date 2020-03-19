x = linspace(-50,50,1e2);
OD = 1;
sig = 10;
cld = OD*exp(-x.^2/(2*sig^2));
noise = normrnd(0,6/1000,size(x));
abso = exp(-cld)+noise;
fp = fitAbsImCrossections(abso,abso,[],x,x);
fitPlot = absoImageCrossfit_func(x,fp,0);
figure;
plot(x,abso,'o');
hold on
plot(x,fitPlot);
legend('data','fit');

% figure;
% plot(x,real(-log(abso)));