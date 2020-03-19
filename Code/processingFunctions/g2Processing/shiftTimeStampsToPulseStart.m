function gates=shiftTimeStampsToGateStart(sortedStamps)
pulseStarts=sortedStamps{3};
pulses={};
for ind=1:length(sortedStamps)-1
    pulseStartsCopy=pulseStarts;
    times=sortedStamps{ind};
    row=[];
    det={};
    
    while ~isempty(times) 
        if isempty(pulseStartsCopy)
            det{end+1}=times;
            break
        end
        while times(1)<pulseStartsCopy(1)
            %             disp('here')
            row(end+1)=pulseStartsCopy(1)-times(1);
            
            times=times(2:end);
            
        end
        pulseStartsCopy=pulseStartsCopy(2:end);
        det{end+1}=row;
        s=0;
        for knd=1:length(det)
            s=s+length(det{knd});
        end
        
        row=[];
    end
pulses{ind}=det;    
end


end


