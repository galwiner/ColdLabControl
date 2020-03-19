function slice=sliceBinData(file,startIdx,length)
d=dir(fullfile(folder,this_file_name));
numRows=d.bytes/16;
if startIdx+length>numRows
    length=numRows-startIdx;
end

format={'uint8', [1 1] 'overflow'; 'uint8',  [1 1] 'reserved0'; 'uint16',  slice 'reserved1'; 'int32', slice 'channel'; 'uint64', slice  'time'};
m = memmapfile(file, 'Format', format,'offset',startIdx,'repeat',length);

end
