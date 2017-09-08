function seqUpload(seq,DEBUG)
if nargin==1
    DEBUG=0;
end
    prog=CodeGenerator;
    prog.GenSeq(seq);
    prog.GenFinish;
    prog.DisplayCode;

if ~DEBUG
    try
    com=Tcp2Labview('localhost',6340);
    com.UploadCode(prog);
    com.UpdateFpga;
    com.WaitForHostIdle;
    com.Execute(1); 
    com.Delete;
    catch err
        disp(['ERROR: ' err.message ' OCCURED IN: ' mfilename])
    end
end
