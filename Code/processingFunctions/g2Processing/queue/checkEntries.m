function rowNum=checkEntries(binFileName)
    [folder,filename,ext]=fileparts(binFileName);
    matFileName=fullfile(folder,[filename '.mat']);
    d=dir(matFileName);
    if isempty(d)
        error('no mat file!');
    end
    
    m = memmapfile(binFilename, 'Format', {'uint8', [1 1] 'overflow'; 'uint8',  [1 1] 'reserved0'; 'uint16',  [1 1] 'reserved1'; 'int32', [1 1] 'channel'; 'uint64', [1 1]  'time'});
    data=m.Data;
    sizeData=size(data);
    load(matFileName);
    rowNum=length(timeArray(1,:))+length(timeArray(2,:))+length(timeArray(3,:));
    assert(rowNum==sizeData);
    
    