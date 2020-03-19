function res=checkLoaded()
global inst
global p
global r

try 
    strcmp(inst.com.TcpID.Status,'open');
catch
    res=0;
end
if ~exist('res','var')
    res=1;
end

end
