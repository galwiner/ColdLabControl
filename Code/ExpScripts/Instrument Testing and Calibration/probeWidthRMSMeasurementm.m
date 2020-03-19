clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=0;
p.hasPicturesResults = 0;
p.hasTTresults = 0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.calcTemp=0;
p.DEBUG=DEBUG;
initinst
initr
p.looping=1;
%%
% scp = keysightScope('10.10.10.127',[],'ip');

for ind=1:50
scp.setState('run');
pause(0.5);
p.expName = 'ProbeWidthRMSMeasurement';
inst.DDS.setFreq(2,220.7470,0,0)
scp.setState('stop');
data = scp.getChannels(3);
figure(1)

h = histogram(data(:,4),150);
V = h.BinEdges+h.BinWidth/2;
V(end) = [];
counts = h.BinCounts;
figure;
plot(V,counts,'o')
x = V';
y = counts';
initParams = [1e3,0.01,0.4];
fitFunc = @(Amp,cent,sigma,x) Amp*exp(-(x-cent).^2/(2*sigma^2));
ft = fittype(fitFunc,'independent','x', 'dependent','y','coefficients',{'Amp','cent','sigma'});

opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
p0 = initParams;
opts.Exclude = find(y==0);
opts.StartPoint = p0;
[fitobject,gof,output] =fit(x,y,ft,opts);
fitParams(1) = fitobject.Amp;
fitParams(2) = fitobject.cent;
fitParams(3) = fitobject.sigma;

hold on
plot(fitobject)



end



