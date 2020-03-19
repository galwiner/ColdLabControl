function runAutoPlot()
global s
global r
global p
if length(s)==2
    eval(s{2});
else
    warning('no auto plotting found!');
end
%TODO find a way to expose all the autoplotting variables to the calling
%namespace
end
