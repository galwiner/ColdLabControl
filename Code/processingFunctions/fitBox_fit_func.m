function y = fitBox_fit_func(x,A,bg,w,y0)
y = zeros(size(x));
for ii = 1:length(x)
    if x(ii)>(y0+w/2)
        y(ii) = A;
    elseif x(ii)<(y0-w/2)
        y(ii) = A;
    else
        y(ii) = bg;
    end
end
end