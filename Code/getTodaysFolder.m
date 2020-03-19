function todaysPath=getTodaysFolder()
% fileparts(mfilename('fullpath'))
basePath=fullfile(fileparts(which('basicImports')),'..','..','..','Measurements');
month=datestr(datetime('now'),'mm');
year=datestr(datetime('now'),'YYYY');
day=datestr(datetime('now'),'dd');
% file_base=datestr(datetime('now'),'ddmmYY');
todaysPath=fullfile(basePath,year,month,day);
if exist(fullfile(basePath,year))~=7 %7 is the return value for an existing folder
    mkdir(fullfile(basePath,year))
end
if exist(fullfile(basePath,year,month))~=7
    mkdir(fullfile(basePath,year,month))
end
if exist(fullfile(basePath,year,month,day))~=7
    mkdir(fullfile(basePath,year,month,day))
end
end