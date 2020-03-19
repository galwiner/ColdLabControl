function seqUpload(seq,DEBUG)
global inst
global p
% if isfield(p,'com');
%     com=p.com;
% end


%%% DEBUG enables sequence print and disables actual upload to FPGA
if nargin==1
    DEBUG=0;
end
for ii=1:size(seq,2)
    if iscell(seq{ii})
        delayInd=find(strcmpi(seq{ii},'duration'));
        PauseTime=seq{ii}{delayInd+1};
        seq=seq(1:end-1);
    end
end
p.cg=CodeGenerator;
p.cg.GenSeq(seq);
if exist('PauseTime','var')
    p.cg.GenPause(PauseTime);
end
p.cg.GenFinish;
if DEBUG
    DEBUG;
end

if ~DEBUG
    try
        %       if ~isfield(p,'com')
        %         com=Tcp2Labview('localhost',6340);
        %       end
        if length(p.cg.code)>1000
           error('FPGA code has %0.0f lines, max number  is 1000!',length(p.cg.code))
        end
        fprintf('Code length is: %d rows\n',length(p.cg.code));
%         tic
        inst.com.WaitForHostIdle;
        inst.com.UploadCode(p.cg);
        inst.com.UpdateFpga;    
        inst.com.WaitForHostIdle;
        numInSeq = [];
        for ii = 1:length(seq)
            if  seq{ii}.Channel==p.TTGateChanNum
                numInSeq = ii;
                break
            end
        end
        if ~isempty(numInSeq)
            p.TTGateStartTimes(end+1) = (seq{numInSeq}.Tstart)*1e-6/40;
        end
        if ~isfield(p,'cycleTimes')
            p.cycleTimes = "";
        elseif p.cycleTimes(1)==""
            p.cycleTimes(1) = string(datestr(now,'HH:MM:SS FFF'));
        else
            p.cycleTimes(end+1) = string(datestr(now,'HH:MM:SS FFF'));
        end
        if isfield(inst,'tt') && isfield(p,'ttStartTime') && isempty(p.ttStartTime)&&~p.loopingRun
            ttstrm = TTTimeTagStream(inst.tt,1);
            inst.tt.sync();
            ttsd = ttstrm.getData(); % get data buffer, this will also contain information on when the call was made.
            p.ttStartTime = ttsd.tGetData;
            ttstrm.stop()
            clear ttstrm ttsd;
        end
        inst.com.Execute(p.looping);
%         uploadTimer=toc;
%         fprintf(p.logFile,'%.5f,',uploadTimer);
%         p.com.Delete;
    catch err
        if isempty(err.identifier)
            error(err.message,'ERROR: %d  OCCURED IN: %d\n',err.message,mfilename);
        else
            error(err.identifier,'ERROR: %d  OCCURED IN: %d\n',err.message,mfilename);
        end
    end
end
