function dat = readPressureFile(path)
% basePath=fullfile(fileparts(which('basicImports')),'..','..','..','Measurements');
basePath=path;
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

fname=fullfile(basePath,year,month,day,[file_base '_pressure.csv']);
try
dat=dlmread(fname);
catch
    disp('cannot open file');
    dat=[nan,nan];
end

rowNum=size(dat,1);
if rowNum>1000
    dat=dat(end-999:end,:);
end

end

