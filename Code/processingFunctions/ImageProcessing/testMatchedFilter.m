noise=poissrnd(150,100,100);
x=linspace(-100,100,100);
% y=linspace(-1,1,100);
[Y,X]=meshgrid(x,x);
sx=10;
sy=10;
gauss=5000.*(1/2/pi/5).*exp(-X.^2/10).*exp(-Y.^2/10);
figure;
imagesc(gauss+noise)
sim=gauss+noise;
bg=poissrnd(150,100,100);
[x,y]=gaussianMatchedFilter(sim,bg);