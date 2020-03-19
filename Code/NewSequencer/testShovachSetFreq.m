
clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasSpecResults = 1;
p.benchtopSpecRes = 1;
initinst
initr
%%
steptime = zeros(1,N);
BytesAvailable = zeros(1,N);
dds = inst.DDS;
N = 1500;
freqList = linspace(30,200,N);
t = tic;

for ii = 1:N
    BytesAvailable(ii) = dds.s.BytesAvailable;
    if dds.s.BytesAvailable~=0
       flushinput(dds.s);
    end
    dds.setFreq(2,freqList(ii));
    pause(0.01)
    steptime(ii) = toc(t);
end

