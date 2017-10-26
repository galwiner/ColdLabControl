function [x,y]=getscDat(sc,chanum)
% Digitize channel nuber 'chanum'
switch chanum
    case 1
        fprintf(sc,':DIGITIZE CHAN1');
    case 2
        fprintf(sc,':DIGITIZE CHAN2');
    case 3
        fprintf(sc,':DIGITIZE CHAN3');
    case 4
        fprintf(sc,':DIGITIZE CHAN4');
end
% Wait till complete
operationComplete = str2double(query(sc,'*OPC?'));
while ~operationComplete
    operationComplete = str2double(query(sc,'*OPC?'));
end

% Get the data back as a WORD (i.e., INT16), other options are ASCII and BYTE
fprintf(sc,':WAVEFORM:FORMAT WORD');
% fprintf(sc,':WAV:FORM ASCii');
% Set the byte order on the instrument as well
fprintf(sc,':WAVEFORM:BYTEORDER LSBFirst');

preambleBlock = query(sc,':WAVEFORM:PREAMBLE?');

fprintf(sc,':WAV:DATA?');
% read back the BINBLOCK with the data in specified format and store it in
% the waveform structure. FREAD removes the extra terminator in the buffer
waveform.RawData = binblockread(sc,'uint16'); fread(sc,1);
% Read back the error queue on the instrument
instrumentError = query(sc,':SYSTEM:ERR?');
while ~isequal(instrumentError,['+0,"No error"' char(10)])
    disp(['Instrument Error: ' instrumentError]);
    instrumentError = query(sc,':SYSTEM:ERR?');
end
maxVal = 2^16; 

%  split the preambleBlock into individual pieces of info
preambleBlock = regexp(preambleBlock,',','split');

% store all this information into a waveform structure for later use
waveform.Format = str2double(preambleBlock{1});     % This should be 1, since we're specifying INT16 output
waveform.Type = str2double(preambleBlock{2});
waveform.Points =str2double(preambleBlock{3});
waveform.Count = str2double(preambleBlock{4});      % This is always 1
waveform.XIncrement = str2double(preambleBlock{5}); % in seconds
waveform.XOrigin = str2double(preambleBlock{6});    % in seconds
waveform.XReference = str2double(preambleBlock{7});
waveform.YIncrement = str2double(preambleBlock{8}); % V
waveform.YOrigin = str2double(preambleBlock{9});
waveform.YReference = str2double(preambleBlock{10});
waveform.VoltsPerDiv = (maxVal * waveform.YIncrement / 8);      % V
waveform.Offset = ((maxVal/2 - waveform.YReference) * waveform.YIncrement + waveform.YOrigin);         % V
waveform.SecPerDiv = waveform.Points * waveform.XIncrement/10 ; % seconds
waveform.Delay = ((waveform.Points/2 - waveform.XReference) * waveform.XIncrement + waveform.XOrigin); % seconds

% Generate X & Y Data
% waveform.XData = (waveform.XIncrement.*(1:length(waveform.RawData))) - waveform.XIncrement;
% waveform.YData = (waveform.YIncrement.*(waveform.RawData - waveform.YReference)) + waveform.YOrigin; 
x = (waveform.XIncrement.*(1:length(waveform.RawData))) - waveform.XIncrement;
y = (waveform.YIncrement.*(waveform.RawData - waveform.YReference)) + waveform.YOrigin; 

fclose(sc);
