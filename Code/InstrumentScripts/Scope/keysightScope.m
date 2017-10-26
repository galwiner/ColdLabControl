classdef keysightScope < handle
    %KEYSIGHTSCOPE object
    
    properties
        sc
        waveform
        scopename
    end
    
    methods
        function obj = keysightScope(scopename)
            %KEYSIGHTSCOPE Construct an instance of this class
            %   Detailed explanation goes here
            obj.scopename=scopename;
            obj.sc = visa('agilent',obj.scopename);
            obj.sc.InputBufferSize = 20000;
            obj.sc.Timeout = 20;
            obj.sc.ByteOrder = 'littleEndian';
            fopen(obj.sc);
            fprintf(obj.sc,':WAVEFORM:SOURCE CHAN1');
            fprintf(obj.sc,':WAV:POINTS:MODE NORMAL');
            fprintf(obj.sc,':WAV:POINTS 10000');
        end
        
        function [x,y]=getChan(obj,chanum)
            fprintf(obj.sc,[':DIGITIZE CHAN' num2str(chanum)]);
            
            % Wait till complete
            operationComplete = str2double(query(obj.sc,'*OPC?'));
            while ~operationComplete
                operationComplete = str2double(query(obj.sc,'*OPC?'));
            end
            
            % Get the data back as a WORD (i.e., INT16), other options are ASCII and BYTE
            fprintf(obj.sc,':WAVEFORM:FORMAT WORD');
            % fprintf(sc,':WAV:FORM ASCii');
            % Set the byte order on the instrument as well
            fprintf(obj.sc,':WAVEFORM:BYTEORDER LSBFirst');
            
            preambleBlock = query(obj.sc,':WAVEFORM:PREAMBLE?');
            
            fprintf(obj.sc,':WAV:DATA?');
            % read back the BINBLOCK with the data in specified format and store it in
            % the waveform structure. FREAD removes the extra terminator in the buffer
            obj.waveform.RawData = binblockread(obj.sc,'uint16'); fread(obj.sc,1);
            % Read back the error queue on the instrument
            instrumentError = query(obj.sc,':SYSTEM:ERR?');
            while ~isequal(instrumentError,['+0,"No error"' char(10)])
                disp(['Instrument Error: ' instrumentError]);
                instrumentError = query(obj.sc,':SYSTEM:ERR?');
            end
            maxVal = 2^16;
            
            %  split the preambleBlock into individual pieces of info
            preambleBlock = regexp(preambleBlock,',','split');
            
            % store all this information into a waveform structure for later use
            obj.waveform.Format = str2double(preambleBlock{1});     % This should be 1, since we're specifying INT16 output
            obj.waveform.Type = str2double(preambleBlock{2});
            obj.waveform.Points = str2double(preambleBlock{3});
            obj.waveform.Count = str2double(preambleBlock{4});      % This is always 1
            obj.waveform.XIncrement = str2double(preambleBlock{5}); % in seconds
            obj.waveform.XOrigin = str2double(preambleBlock{6});    % in seconds
            obj.waveform.XReference = str2double(preambleBlock{7});
            obj.waveform.YIncrement = str2double(preambleBlock{8}); % V
            obj.waveform.YOrigin = str2double(preambleBlock{9});
            obj.waveform.YReference = str2double(preambleBlock{10});
            obj.waveform.VoltsPerDiv = (maxVal * obj.waveform.YIncrement / 8);      % V
            obj.waveform.Offset = ((maxVal/2 - obj.waveform.YReference) * obj.waveform.YIncrement + obj.waveform.YOrigin);         % V
            obj.waveform.SecPerDiv = obj.waveform.Points * obj.waveform.XIncrement/10 ; % seconds
            obj.waveform.Delay = ((obj.waveform.Points/2 - obj.waveform.XReference) * obj.waveform.XIncrement + obj.waveform.XOrigin); % seconds
            
            % Generate X & Y Data
            % waveform.XData = (waveform.XIncrement.*(1:length(waveform.RawData))) - waveform.XIncrement;
            % waveform.YData = (waveform.YIncrement.*(waveform.RawData - waveform.YReference)) + waveform.YOrigin;
            x = (obj.waveform.XIncrement.*(1:length(obj.waveform.RawData))) - obj.waveform.XIncrement;
            y = (obj.waveform.YIncrement.*(obj.waveform.RawData - obj.waveform.YReference)) + obj.waveform.YOrigin;
            
        end
        
        function delete(obj)
            fclose(obj.sc);
            disp(['closed connection to scope: ' obj.scopename]);
        end
        
    end
end
