function customsave_fig(varargin)
if nargin<1
    how_meany=1;
else
    how_meany = varargin{1};
end
global p
origDir = cd;
figs = findobj('type','figure');
folder = [getCurrentSaveFolder '\..\figs'];
if ~exist(folder,'dir')
    mkdir(folder)
    cd(folder)
else
    cd(folder)
end
[~,pfileInd] = getLastpFile;
date_base=datestr(datetime('now'),'ddmmYY');
if ~isfield(p,'expName')
    p.expName = 'no exp name';
end
if ~isfield(p,'loopVals') || isempty(p.loopVals)
file_name = [date_base '_' num2str(pfileInd,'%02.0f') '_' p.expName];
elseif length(p.loopVals)==1
    file_name = [date_base '_' num2str(pfileInd,'%02.0f') '_' p.expName '_' p.loopVars{1} '_' num2str(p.loopVals{1}(1),'%5.3f') '_' num2str(p.loopVals{1}(end),'%5.3f')];
else
    file_name = [date_base '_' num2str(pfileInd,'%02.0f') '_' p.expName '_' p.loopVars{1} '_' num2str(p.loopVals{1}(1),'%5.3f') '_' num2str(p.loopVals{1}(end),'%5.3f') '_' p.loopVars{2} '_' num2str(p.loopVals{2}(1),'%5.3f') '_' num2str(p.loopVals{2}(end),'%5.3f')];
end
for ii = 1:how_meany
    file_name = [file_name '_' num2str(ii)];
    orig_file_name = file_name;
    ctr = 1;
    while exist([file_name '.fig'],'file')
        file_name = [orig_file_name '_' num2str(ctr)];
        ctr = ctr + 1;
    end
    savefig(figs(ii),[file_name '.fig']);
end
cd(origDir)
end
