function customsave()
%function to save variables in a specified folder, without overwriting


% if nargin==0
% error('callingScriptName missing');
% end
global p 
global r
global s

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
addpath(fullfile(basePath,year,month,day));
savepath;
% fnum=1;
% file_format=[file_base '_' num2str(fnum,'%02d') '_' p.expName '.mat']
d=dir([fullfile(basePath,year,month,day) '\*.mat']);
files=d(~[d.isdir]);
exp_name=p.expName;
file_num = 0;
for ind=1:length(files)
    reg=regexp(files(ind).name,'\.','split');
    
    if strcmpi(reg{2},'mat')
        reg=regexp(reg{1},'\_\_','split');
        
        
        curr_file_name=reg{1};
        reg=regexp(curr_file_name,'\_','split');
        if length(reg)>1&&strcmpi(reg{2},'CRASHBACKUP')
            curr_file_name=reg{1};
        end
        curr_file_num=str2double(reg{2});
        if curr_file_num>file_num
            file_num=curr_file_num;
        end
        %         fprintf('next file num = %d\n',file_num+1);
%         next_file_name=sprintf([reg{1} '_' reg{2} '_%02d__' exp_name '.mat'],file_num+1);
%         last_file_name=sprintf([reg{1} '_' reg{2} '_%02d__' exp_name '.mat'],file_num);
    end
end
% while(exist(fullfile(basePath,year,month,day,[file_base '_' num2str(file_num,'%02d') '.mat']),'file'))
%     file_num=file_num+1;
% end

% fname=fullfile(basePath,year,month,day,[file_base '_' num2str(fnum,'%02d') '.mat']);
fname=fullfile(basePath,year,month,day,sprintf([file_base '_' '%02d__' exp_name '.mat'],file_num+1));
p.fname=fname;
% 
% if nargin==1
%     save(fname,'p','r');
% %     evalin('caller',sprintf('save("%s")',fname));
% else
%     evalin('caller',sprintf('save("%s","%s")',fname,saveVarsList{:}));
% end
if isfield(p,'expName')
    expname=p.expName;
else
    %expname='No experiment name';
    warning('Customsave ran without expName. No data saved!')
    return;
end
stack=dbstack;
try
   s=parseS(fileread(stack(length(stack)).file));
catch
   
s = 'problem with forming s';
end
save(fname,'p','r','s','-v7.3');
logname=fullfile(basePath,year,month,day,'log.txt');
disp(fname)
logger(logname,fname,expname);

