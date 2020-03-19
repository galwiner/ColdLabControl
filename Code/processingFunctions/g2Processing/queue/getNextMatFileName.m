function [next_file_name,last_file_name]=getNextMatFileName(folder,mod,ext)
global p 
if nargin==1
    ext='.bin';
    mod='';
end
d=dir(folder);
files=d(~[d.isdir]);
next_file_name=''; %TODO: Write code to find all bin files and check if they have corresponding mat files.
file_num=0;
for ind=1:length(files)
%     fprintf('%s\n',files(ind).name);
    r=regexp(files(ind).name,'\.','split');
    if strcmpi(r{2},'bin')
        r=regexp(r{1},'\_\_','split');
        exp_name=r{2};
%         fprintf('exp name = %s\n',exp_name);
        curr_file_name=r{1};
        r=regexp(curr_file_name,'\_','split');
        curr_file_num=str2double(r{3});
        if curr_file_num>file_num
            file_num=curr_file_num;
        end
%         fprintf('next file num = %d\n',file_num+1);
        next_file_name=sprintf([r{1} '_' mod r{2} '_%02d__' exp_name ext],file_num+1);
        last_file_name=sprintf([r{1} '_' mod r{2} '_%02d__' exp_name ext],file_num);
    end

    
end
if exist('p','var')
    if isfield(p,'expName')
        expname=p.expName;
    else
        expname='no exp name';
    end
end

if strcmpi(next_file_name,'')
    [~,file_base]=getCurrentSaveFolder();
    next_file_name=['tt_' file_base '_01__' expname ext];
    last_file_name='';
end