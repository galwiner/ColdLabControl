function N = MOT_Loading(a,b,g,t)
tmpN = a./b.*(1-exp(-b.*t));
N = zeros([size(tmpN),length(g)]);
for ii = 1:length(g)
    if g(ii) == 0
        N(1:size(tmpN,1),1:size(tmpN,2),ii) = a./b.*(1-exp(-b.*t));
    else
        N0 = b./(2*g(ii)).*(sqrt(1+4*a.*g(ii)./(b.^2))-1);
        b2 = b+2*g(ii).*N0;
        N(1:size(tmpN,1),1:size(tmpN,2),ii) = N0+1./((g(ii)./b2-1./N0).*exp(b2.*t)-g(ii)./b2);
    end
end
end