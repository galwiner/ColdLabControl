function gates=shiftTimeStampsToGateStart(sortedStamps)
%Time unit: uS
%The gates output has the structure: gates={{ch1},{ch2}} where each
%channel (detector) cell array has the structure:
%{chN}={{gate1},...,{gateN}} and each gate has time tags relative the gate start pulse. 

gateStarts=sortedStamps{1};
% ch1=double(sortedStamps{1});
% ch2=double(sortedStamps{2});
gates={};
for ind=1:(length(sortedStamps)-1) %ind goes over detectors (1 and 2)
    gateStartsCopy=gateStarts;
    times=double(sortedStamps{ind});
    row=[];
    det={};
    while ~isempty(times) %deal with time stamps one by one and remove any one you've dealt with 
        if isempty(gateStartsCopy)
            det{end+1}=times; %done dealing with all gates
            break
        end
        if length(gateStartsCopy)==1 %dealing with the last gate
            while ~isempty(times)
                row(end+1)=times(1)-gateStartsCopy(1); %shift time to current gate
                times=times(2:end);
            end
        else
            while ~isempty(times) && times(1)<gateStartsCopy(2)
                row(end+1)=times(1)-gateStartsCopy(1); %shift time to current gate
                times=times(2:end);
            end
        end
        gateStartsCopy=gateStartsCopy(2:end); %pop the current gate from the top of the stack
        row=row-row(1);
        row=row(2:end);
        det{end+1}=row*1e-6; %switch to uS
%         s=0;
%         for knd=1:length(det)
%             s=s+length(det{knd});
%         end
        
        row=[];
    end
    while length(det)<length(gateStarts)
        det{end+1} = [];
    end
gates{ind}=det;    
end
end


