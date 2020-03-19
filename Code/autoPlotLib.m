function autoPlotLib(varargin)
p=inputParser;
defaultRange=[];
defaultPath=getCurrentMeasFolder;
addParameter(p,'expRange',defaultRange,@isnumeric)
addParameter(p,'path',defaultPath)
parse(p,varargin{:})

d=dir([p.Results.path '\*.mat']);

for ind=1:length(d)
    disp(d(ind).name)
    
end
end
