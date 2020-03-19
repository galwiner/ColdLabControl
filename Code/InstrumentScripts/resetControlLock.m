function resetControlLock(endVal,AorE_OM)
global inst;
if nargin==1
    AorE_OM = 'A';%choose if you scan with AOM or EOM
end
switch upper(AorE_OM)
    case 'A'
        pauseTime = 0.1;
        startVal = inst.DDS.getFreq(1);
        direction = sign(endVal-startVal);
        jumpSize = direction*0.3;
        curVal = startVal;
        while curVal<endVal
            inst.DDS.setFreq(1,curVal);
            curVal = curVal+jumpSize;
            pause(pauseTime);
        end
        inst.DDS.setFreq(1,endVal);
        pause(pauseTime);
    case 'E'
        pauseTime = 0.1;
        startVal = inst.synthHD.getFreq('A');
        direction = sign(endVal-startVal);
        jumpSize = direction*1;
        curVal = startVal;
        while curVal<endVal
            inst.synthHD.setFreq(curVal,'A');
            fprintf('synthHD setFreq to %.2f MHz\n',curVal);
            curVal = curVal+jumpSize;
            pause(pauseTime);
        end
        inst.synthHD.setFreq(endVal,'A');
        pause(pauseTime);
        
end
