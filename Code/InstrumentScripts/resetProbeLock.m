function resetProbeLock(detVals)
global inst;
pauseTime = 0.01;
startVal = detVals(end);
endVal = detVals(1);
direction = sign(endVal-startVal);
jumpSize = direction*2.5;
curVal = startVal+jumpSize;
switch direction
    case 1 %end val is higher than start val
        while curVal<endVal
%             if inst.DDS.s.BytesAvailable~=0
%                 flushinput(inst.DDS.s);
%             end
            inst.DDS.setFreq(2,probeDetToFreq(curVal,8));
            curVal = curVal+jumpSize;
            pause(pauseTime);
        end
        inst.DDS.setFreq(2,probeDetToFreq(endVal,8));
        pause(pauseTime);
    case -1
        while curVal>endVal
%             if inst.DDS.s.BytesAvailable~=0
%                 flushinput(inst.DDS.s);
%             end
            inst.DDS.setFreq(2,probeDetToFreq(curVal,8));
            curVal = curVal+jumpSize;
            pause(pauseTime);
        end
        inst.DDS.setFreq(2,probeDetToFreq(endVal,8));
        pause(pauseTime);
end

end
