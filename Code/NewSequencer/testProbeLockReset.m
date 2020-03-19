
clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasSpecResults = 0;
initinst
initr
%%
N = 1000;
p.holdFreqPrint = 1;
det1 = 20;
det2 = -290;
for ii = 1:N
    resetProbeLock([det2,det1])
    pause(0.1)
    resetProbeLock([det1,det2])
    pause(0.1)
    disp(ii)
end

