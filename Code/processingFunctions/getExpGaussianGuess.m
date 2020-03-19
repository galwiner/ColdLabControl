function p0 = getExpGaussianGuess(y)
%this function guesses the fit parameters of an expGauss fit
%(A,bg,x0,sigma)
mx = max(y);
mi = min(y);
uT = (8*mx+2*mi)/10;
lT = (8*mi+2*mx)/10;
w1 = find(y<lT,1,'first');
w2 = find(y<lT,1,'last');
p0 = [mean(y(y>uT)),mean(y(y<lT)),(w1+w2)/2,(w2-w1)/4];
end