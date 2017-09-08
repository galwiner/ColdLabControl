classdef Channel
    %represents a single channel in a sequence
    %linked list of pulses
       
    properties
        logicalName;
        physicalName;
        timeline;
    end
    
    methods
        function chan=Channel(logicalName,physicalName)
            chan.physicalName=physicalName;
            chan.logicalName=logicalName;
            chan.timeline=[];
        end
        
        function addPulse(obj,chan,startTime,width)
            chan.timeline(end+1)=startTime;
        end
        
        function remPulse(obj,chan,state,time,width,pos)
            %if pos not supplied, pulse removed from end
            
        end
        
        function plt=plotChannel(chan)
            T=[0];
            V=[0];
            for ind=1:length(chan.timeline)
               T(end+1)=chan.timeline{ind}.Tstart;
               V(end+1)=0;
               T(end+1)=chan.timeline{ind}.Tstart;
               V(end+1)=5;
               if chan.timeline{ind}.Tstart==chan.timeline{ind}.Tend 
                   Tend=Tend+1/40;
               else 
                   Tend=chan.timeline{ind}.Tend;
               end
               T(end+1)=Tend;
               V(end+1)=5;
               T(end+1)=Tend;
               V(end+1)=0;
                
            end
            
            plt=line(T,V);
            
        end
        
    end
    
    
end

