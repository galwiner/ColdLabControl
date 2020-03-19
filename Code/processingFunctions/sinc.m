function sincVals = sinc(x,amp,center,period,background)
% sincVals = zeros(size(x));
% for ii = 1:length(x)
% if x(ii)==center
%     sincVals(ii) =amp+ background;
%     continue
% end
% sincVals(ii) = amp*(sin(period*(x(ii)-center))./(period*(x(ii)-center))).^2+background;
sincValstmp = amp*(sin(period*(x-center))./(period*(x-center))).^2+background;
sincValstmp(~isfinite(sincValstmp)) = amp+background;
sincVals = sincValstmp;
end