function [fname,lastFileInd,prefix]=getLastpFile(Date)
if ~exist('Date','var')
    Date = today;
else
    Date = datenum(Date,'dd/mm/yyyy');
end
basePath=fullfile(fileparts(which('basicImports')),'..','..','..','Measurements');
month=datestr(Date,'mm');
year=datestr(Date,'YYYY');
day=datestr(Date,'dd');
file_base=datestr(Date,'ddmmYY');
if exist(fullfile(basePath,year))~=7 %7 is the return value for an existing folder
    mkdir(fullfile(basePath,year))
end
if exist(fullfile(basePath,year,month))~=7
    mkdir(fullfile(basePath,year,month))
end
if exist(fullfile(basePath,year,month,day))~=7
    mkdir(fullfile(basePath,year,month,day))
end
addpath(fullfile(basePath,year,month,day));
savepath;
d=dir([fullfile(basePath,year,month,day) '\*.mat']);
if isempty(d)
    fname = [];
    lastFileInd = [];
    prefix = [];
    warning('No data found on %s\\%s\\%s',day,month,year)
    return
end
maxNum = 0;
maxInd = 0;
for ii = 1:length(d)
    reg=regexp(d(ii).name,'\_','split');
    tmpNum = str2double(reg{2});
    if tmpNum>maxNum
        maxNum = tmpNum;
        maxInd = ii;
    end
end
fname=d(maxInd).name;
prefix =fullfile(basePath,year,month,day,[file_base '_']);%prefix is the file name without the index, i.e 110919_
lastFileInd = maxNum;
end
