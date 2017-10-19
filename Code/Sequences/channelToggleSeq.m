function seq=channelToggleSeq(chanName,stateBool)
if nargin<2
    state=0; %turn on 
else
    if(stateBool==1)
        state=0;
    elseif stateBool==0
        state=-1;
    else 
        error('incorrect state');
    end
end

    
seq={Pulse(chanName,0,state)};
end
