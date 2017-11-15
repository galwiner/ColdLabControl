function seqUpload(seq,DEBUG)


%%% DEBUG enables sequence print and disables actual upload to FPGA 
if nargin==1
    DEBUG=0;
end
    prog=CodeGenerator;
    prog.GenSeq(seq);
    prog.GenFinish;
if DEBUG
    prog.DisplayCode;
end

if ~DEBUG
    try
    com=Tcp2Labview('localhost',6340);
    com.UploadCode(prog);
    com.UpdateFpga;
    com.WaitForHostIdle;
    com.Execute(1); 
    com.Delete;
    catch
        error(['ERROR: ' err.message ' OCCURED IN: ' mfilename]);
    end
end
