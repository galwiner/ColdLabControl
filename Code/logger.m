function logger(logname,fname)
% function to create and update the daily log
if ~exist(logname,'file')
    f=fopen(logname,'w');
    fprintf(f,['EXPERIMENT LOG FOR' datestr(now,'dd/mm/YY') '\n']);
    fprintf(f,['Log created at ' datestr(now,'HH:MM') '\n']);
    fprintf(f,'______________________________________________\n');
else
    f=fopen(logname,'a');
end
[~,fname]=fileparts(fname);
update=[fname '\t' datestr(now) '\n'];
fprintf(f,update);
end
