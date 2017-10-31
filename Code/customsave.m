function customsave(saveVarsList)
%function to save variables in a specified folder, without overwriting

basePath=fullfile(fileparts(which('basicImports')),'..','..','..','..','Measurements');
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

fnum=1;

while(exist(fullfile(basePath,year,month,day,[file_base '_' num2str(fnum,'%02d') '.mat']),'file'))
fnum=fnum+1;
end
fname=fullfile(basePath,year,month,day,[file_base '_' num2str(fnum,'%02d') '.mat']);
if nargin==0
    
    evalin('caller',sprintf('save("%s")',fname));
else
    evalin('caller',sprintf('save("%s","%s")',fname,saveVarsList{:}));
end

logname=fullfile(basePath,year,month,day,'log.txt');
logger(logname,fname);

