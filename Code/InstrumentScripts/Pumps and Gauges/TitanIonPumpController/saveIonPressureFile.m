function saveIonPressureFile(time,pressure,path)
%function to save variables in a specified folder, without overwriting
dat=[time,pressure];


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

fname=fullfile(basePath,year,month,day,[file_base '_ionpressure.csv']);

try
dlmwrite(fname,dat,'-append','precision',14)
catch err
disp(err)
pause(1);
end

end

