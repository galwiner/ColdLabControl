function [m,n] = getLayout(N)
%this function returns the m lines and n columns needed to display N
%figures in subplot. The aspect ratio is kept similar to 3:4, unless m*n=N;
if rem(sqrt(N),1)==0
    n = sqrt(N);
    m = sqrt(N);
    return
end
divis = divisors(N);
if length(divis)>2
    pairs = zeros(2,length(divis)/2);
    for ii = 1:size(pairs,2)
        pairs(1,ii) = divis(ii);
        pairs(2,ii) = divis(end-ii+1);
    end
    [~,ind] = min(sum(pairs,1));
    n = max(pairs(:,ind));
    m = min(pairs(:,ind));
    if n-m<3
        return
    end
end
n = round(sqrt(4*N/3));
if rem(n*3/4,1)==0.5
    m = floor(n*3/4);
else
    m = round(n*3/4);
end
if m*n<N
    n = n+1;
end
end