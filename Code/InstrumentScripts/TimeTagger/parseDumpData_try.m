[folder,file_base]=getCurrentSaveFolder();
[next_file_name,this_file_name]=getNextDumpFileName(folder);
tic
d=dir(fullfile(folder,this_file_name));
numRows=d.bytes/16;
clear m
% sliceRows=1e6;
sliceRows=1e5;
repeat=floor(numRows/sliceRows);
offset=repeat*sliceRows;
remainderRows=numRows-offset;
% slice=[sliceRows,1];
% rSlice=[remainderRows,1];
sliceRows=[1,10,100,1e4,1e5,5e5,1e6];
for ind=1:length(sliceRows)
    clear m
    tic
m = memmapfile(this_file_name, 'Format', {'uint8', [1 1] 'overflow'; 'uint8',  [1 1] 'reserved0'; 'uint16',  slice 'reserved1'; 'int32', slice 'channel'; 'uint64', slice  'time'},'offset',0,...
    'repeat',sliceRows(ind));

% fprintf('%d\n',length(m.Data));t(ind)=toc
t(ind)=toc
end
figure;plot(sliceRows,t,'o-')
xlabel('numRows');
ylabel('time[s]')
r = memmapfile(this_file_name, 'Format', {'uint8', [1 1] 'overflow'; 'uint8',  [1 1] 'reserved0'; 'uint16',  rSlice 'reserved1'; 'int32', rSlice 'channel'; 'uint64', rSlice  'time'},'offset',offset,...
    'repeat',1);
slice=[1 1];
m = memmapfile(this_file_name, 'Format', {'uint8', slice 'overflow'; 'uint8',  slice 'reserved0'; 'uint16',  slice 'reserved1'; 'int32', slice 'channel'; 'uint64', slice  'time'});


% m = memmapfile(this_file_name, 'Format', {'uint8', slice 'overflow'; 'uint8',  slice 'reserved0'; 'uint16',  slice 'reserved1'; 'int32', slice 'channel'; 'uint64', slice  'time'});
% data = m.Data;
%%
m = memmapfile(this_file_name, 'Format', {'uint8', [1 1] 'overflow'; 'uint8',  [1 1] 'reserved0'; 'uint16',  [1 1] 'reserved1'; 'int32', [1 1] 'channel'; 'uint64', [1 1]  'time'},'repeat',1e6);

data = m.Data;

%now the data can be accessed via data: struct array with fields:
disp(' ');
disp('Load the data for which the time tags are stored in an array of structs.');
disp(' ');
disp('The struct contains the channel number of the incoming tag (.channel) and the respective time in ps (.time).');
disp('If an overflow occured during the transmission .overflow is set to 1. The reserved fieldes can be ignored.');
for i = 1:3
    disp(['Tag ' num2str(i)]);
    disp(data(i));
end
%for the case all timestamps should be in one array
disp('Convert the struct into 1D arrays.');
channel = [data(:).channel];
time = [data(:).time];
overflow = [data(:).overflow];
for i = 1:3
    disp(['Tag #' num2str(i) '  t = ' num2str(time(i)) ' ps   channel: ' num2str(channel(i)) '  overflow: ' num2str(overflow(i))]);
end

disp('Depending on the operation the 64 bit integer timestamp must be converted to doubles for further processing in matlab.');
mtime = double(time);

disp(' ');
disp('The raw time tag stream can be also accessed via the TimeTagStream class.');
disp('The TimeTagStream class stores the tags in memory where they can be processed or stored immediately.');
disp('See 1-GettingStarted/TTQuickstart.m for an example.');



