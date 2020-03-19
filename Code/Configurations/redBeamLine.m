function beam = redBeamLine(xvals,scale)
%26.06.18 LD. This function returns the red beam line, as seen from the
%top pixelfly.
%The line equation is y =-1.09378*x+316.9378
if nargin ==1
    scale = 1;
end
beam = scale*(-1.09378*xvals/scale + 316.9378);
end