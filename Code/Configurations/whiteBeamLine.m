function beam = whiteBeamLine(xvals,scale)
%26.06.18 LD. This function returns the white beam line, as seen from the
%top pixelfly.
%The line equation is y = 1.05*x-14.8
if nargin ==1
    scale = 1;
end
beam = (1.05*xvals/scale - 14.8)*scale;
end