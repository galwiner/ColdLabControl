clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=1;
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
p.expName = 'ProbeLineWidthWithPolarizationLocking';
inst.scopes{1}.setState('single')
pause(0.3)
r.scopeRes{1} = inst.scopes{1}.getChannels([1,2,3]);
r.scopeDigRes{1} = inst.scopes{1}.getDigitalChannels;
customsave;
%%
load('100719_03.mat')
dvdf = 0.0348; %taken from 100719_02.mat
h = histogram(r.scopeRes{1}(:,2),200);
V = h.BinEdges+h.BinWidth/2;
V(end) = [];
counts = h.BinCounts;
figure;
plot(V,counts,'o')
x = V';
y = counts';
initParams = [2e3,-0.017,0.01];
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
plot(fitobject);

sigma = fitobject.sigma;
width = sigma/dvdf;