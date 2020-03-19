function status=tt_dumpManager(app)

%function to manage comms. with TTDump class
max_tags=1e9; %in # time tags = X16 in Bytes 
% max_file_size=1e9;
global p
% global r

[folder,file_base]=getCurrentSaveFolder(); %#ok<ASGLU>
[next_file_name,this_file_name]=getNextDumpFileName(folder);

if exist('p','var')
    if isfield(p,'expName')
        expname=p.expName;
    else
        expname='no exp name';
    end
end

fnum=app.currFileNum; %#ok<NASGU>
% file_name=['tt_' file_base '_' num2str(fnum,'%02d') '__' expname '.bin'];
% fname=fullfile(folder,file_name);
app.currentfilenameEditField.Value=this_file_name;

logname=fullfile(folder,'log.txt');
logger(logname,this_file_name,expname);
% if ~exist(this_file_name,'file')
%     logger(logname,this_file_name,expname);
% end

if ~strcmpi(class(app.dump),'TTDump')
    disp('no TTDump obj,making it.');
    app.dump=TTDump(app.tt,this_file_name,max_tags,[1,2,3]);
    
end

if boolean(app.nextDumpFlag)
%     file_name=['tt_' file_base '_' num2str(fnum+1,'%02d') '__' expname '.bin'];
    if exist('p','var') && ~strcmpi(this_file_name,'')
        parts=split(this_file_name,'.');
        fname=parts{1};
        save(fullfile(folder,['p_' fname(4:end) '.mat']),'p');
    else
        warning('no p variable. saving empty .mat file');
        parts=split(next_file_name,'.');
        fname=parts{1};
        p=[];
        save(fullfile(folder,['p_' fname(4:end) '.mat']),'p');
    end
    fname=fullfile(folder,next_file_name);
    
    app.dump=TTDump(app.tt,fname,max_tags,[1,2,3]);
    app.nextDumpFlag=0;
end



if ~isempty(this_file_name) && ~isempty(dir(fullfile(folder,this_file_name)))
    s=dir(fullfile(folder,this_file_name));
    app.currentSizeEdit.Value=s.bytes/1e6;
    maxSize=str2double(app.autoDumpsizeDropDown.Value);
    if app.autoDumpFlag && s.bytes/1e6>maxSize
        app.nextDump;
    end
    
end


status=1;