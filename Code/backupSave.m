function backupSave()
%function to save a backup file during a run, after each runstep


% if nargin==0
% error('callingScriptName missing');
% end
global p 
global r

basePath=fullfile(fileparts(which('basicImports')),'..','..','..','Measurements');
month=datestr(datetime('now'),'mm');
year=datestr(datetime('now'),'YYYY');
day=datestr(datetime('now'),'dd');
file_base=datestr(datetime('now'),'ddmmYY');
if exist(fullfile(basePath,year))~=7 %7 is the return value for an existing folder
    mkdir(fullfile(basePath,year))
end
if exist(fullfile(basePath,year,month))~=7
    mkdir(fullfile(basePath,year,month))
end
if exist(fullfile(basePath,year,month,day))~=7
    mkdir(fullfile(basePath,year,month,day))
end

fname=fullfile(basePath,year,month,day,[file_base '_CRASHBACKUP.mat']);

save(fname,'p','r');

