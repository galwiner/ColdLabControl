function status=tt_customsave(app)
%function to manage comms. with TTDump class
maxFileSize=1e9; %in # time tags = X16 in Bytes 

global p
% global r

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

if exist(fullfile(basePath,year,month,day,'tt'))~=7
    mkdir(fullfile(basePath,year,month,day,'tt'))
end


addpath(fullfile(basePath,year,month,day,'tt'));
savepath;
fnum=1;
fname=fullfile(basePath,year,month,day,'tt',[file_base '_' num2str(fnum,'%02d') '.bin']);
if exist(fname,'file')
    s=dir(fname);
end

while(exist(fname,'file') && s.bytes>maxFileSize)
    %only make a new file if the previous one is larger than maxFileSize
    fnum=fnum+1;
    fname=fullfile(basePath,year,month,day,'tt',[file_base '_' num2str(fnum,'%02d') '.bin']);
end

fname=fullfile(basePath,year,month,day,'tt',['tt_' file_base '_' num2str(fnum,'%02d') '.bin']);

if exist('p','var')
    if isfield(p,'expName')
        expname=p.expName;
    else
        expname='no exp name';
%         warning('tt_customsave ran without expName.')
        %     return;
    end
end



logname=fullfile(basePath,year,month,day,'tt','log.txt');
if ~exist(fname,'file')
    logger(logname,fname,expname);
end
dat=app.currDataFile;

if ~exist(fname,'file')
%     h5create(fname,'/tt',[2,Inf],'ChunkSize',[2,app.getBunchSize])
end
start=[1 (1+app.getBunchSize*app.getBunchNum*fnum)];
count=[2 app.getBunchSize];
% disp(app.getBunchNum)

if ~isempty(dat)
%     h5write(fname,'/tt',dat,start,count);
    app.incBunchNum;
end

status=1;