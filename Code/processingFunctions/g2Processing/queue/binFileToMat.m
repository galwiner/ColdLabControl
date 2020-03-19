function [fileName,datMatFile]=binFileToMat(binFilename)    
    
    tic
    fileName=binFilename;
    
    d=dir(binFilename);
    idx=1; %counter for breaking out of the while loop
    currSize=0;
    if isempty(d)
        error('no bin file');
        return
    end
    
    while ~isempty(d)
           d=dir(binFilename);
           newSize=d.bytes;
           if newSize~=0
                if newSize==currSize 
                    break
                else
                    if newSize>currSize
                        currSize=newSize;
                    end
                end
           end
           idx=idx+1;
           if idx>1e4
               error(sprintf('%s :empty bin file!',binFilename));
               break
           end
    end
    d=dir(binFilename);
    if isempty(d)
        error('could not map bin file to mat format. exiting job');
    end
        
        m = memmapfile(binFilename, 'Format', {'uint8', [1 1] 'overflow'; 'uint8',  [1 1] 'reserved0'; 'uint16',  [1 1] 'reserved1'; 'int32', [1 1] 'channel'; 'uint64', [1 1]  'time'});
    
    fprintf('starting data extraction in file %s\n',binFilename);
    data=m.Data;
    
%     sizeData=size(data);
    
    channel = [data(:).channel];
    
    time = [data(:).time];
    
        
    overflow = [data(:).overflow];
    if any(overflow)
        error('there is an overflow in %s!',binFilename)
    end
%     datMat=[channel;time;overflow];
    fprintf('starting datMat in file %s\n',binFilename);
    datMat=[time;channel];
    
%     timeArray=sortTimeStampsByChannels(datMat);
%     shiftTimeStampsToGateStart
    
    [folder,name,ext]=fileparts(binFilename);
%     folder=getCurrentSaveFolder();
    
    datMatFile=fullfile(folder,[name '.mat']);
        save(datMatFile,'datMat'); %saving the raw data.
        fprintf('Saved datMat: %s\n',[name '.mat'])
        if size(data)~=length(time)
            error('missing data!, not deleting bin file!');
        else
            if isempty(dir(fullfile(folder,[name '.mat'])))
        error('did not create mat file in %s!',name)
            else
%             clear m
%             delete(binFilename); %can't delete because we rely on the
%             file being there when we look for next file name. 
%             fclose(fopen(binFilename,'w'));
%             d=dir(binFilename);
%             while d.bytes~=0
%                 f=fopen(binFilename,'w')
%                 fprintf(f,'emptied');
%                 fclose(f);
%             end
            fprintf('bin file can be emptied\n');
            end
        end
    t=toc;
    fprintf('done in binFile To mat!\n');
    fprintf('binFileToMat took %d seconds\n',t);
    
%     tic;
%     fprintf('Starting parsing...\n');
%     procDat=parseDetectorData({datMatFile});
%     t=toc;
%     fprintf('Parsing complete [%.2f S]\n',t);
%     r=regexp(name,'\_','split');
%     procName=[r{1} 'Proc' '_' r{2} '_' r{3} '__' r{5}];
%     save(fullfile(folder,[procName '.mat']),'procDat'); %saving the pre-processed data.
end

