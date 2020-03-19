function processed_gates=removeAfterPulses(gates,deadTime)
    %gates is assumed to be a cell array with cell num=detector num +1 
    %because last channel is the pulse start signal (not from an SPCM) 
    if nargin==1
        deadTime=24e3; %time in ps
    end
    
    for ind=1:(length(gates)-1)
        jnd=1;
        while jnd<=(length(gates{ind})-1)
            if gates{ind}(jnd+1)-gates{ind}(jnd)<deadTime
                gates{ind}(jnd)=[];
            end
            jnd=jnd+1;
        end
    end
    processed_gates=gates;