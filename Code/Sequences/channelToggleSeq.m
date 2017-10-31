function seq=channelToggleSeq(channelTable,chanName,stateBool)

if ~exist('channelTable','var')
    basicImports
end

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

    
seq={Pulse(channelTable.PhysicalName{chanName},0,state)};
end
