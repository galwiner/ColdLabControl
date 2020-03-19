classdef coldEfieldGenerator < omegaDAC
    %class to set the E field in the cold experiment
    %mapping of electrodes
    
    properties
        connectionTable
    end
    
    methods
        function obj = coldEfieldGenerator()
            obj=obj@omegaDAC();
%             wireColor={'white','black','green','purple','organge','blue','red','yellow','white','black','green','purple','organge','blue','red','yellow'}'; %wire color on the OmegaDAC side
            wireColor={'white','black','green','purple','organge','blue','red','yellow','black','white','purple','green','blue','organge','yellow','red'}'; %wire color on the OmegaDAC side
            braidColor={'black','white','gray','purple','blue','green','yellow','orange','white','black','purple','gray','green','blue','orange','yellow'}'; %braid color on the PBC side
%             VOChannel=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]';This order
%             is wrong. Found on 06/02/20. see correct order bellow. The
%             problem was the order of the bottom PCB
            VOChannel=[0,1,2,3,4,5,6,7,9,8,11,10,13,12,15,14]';%same order as wireColor. i.e wireColor{1}=white is VOChannel(1)=0
            pad=[1,2,3,4,5,6,7,8,1,2,3,4,5,6,7,8]';%this is the PCB electrode number. This sets the order of all the rest
            side={'top','top','top','top','top','top','top','top','bottom','bottom','bottom','bottom','bottom','bottom','bottom','bottom'}'; %position of the PCB
            facingSide=[8,7,6,5,4,3,2,1,8,7,6,5,4,3,2,1]'; % not used and unknown as of 06/02/20.
            pairNumber = [8,7,6,5,4,3,2,1,1,2,3,4,5,6,7,8]';%number of the pair assosiated with the pad. There are 8 pairs. Thay are numberd clockwise for an observer looking from the computer screens side. so pair #1 will be the farthest one, to the right. pair 4 will be closest to the right.
            obj.connectionTable=table(pad,VOChannel,wireColor,braidColor,side,pairNumber);
            for ind=1:16
                obj.setVoltage(ind-1,0);
            end
            fprintf('E field initialized. all channels set to 0 V\n');
        end

        function setZField(obj,field)
            %this function sets the value of all the top elevtrods to be
            %field and all the bottom to be -field, then waits 10ms for the
            %voltage to settel (from settiling time measured on 05/02/20)
            for ind=1:8
                obj.setVoltage(ind-1,field)
            end
            for ind=9:16
                obj.setVoltage(ind-1,-field)
            end
            pause(0.01);
        end
        
        function setXField(obj,field)
            %this function sets the value of all the upper pairs (1,2,7,8)to be
            %field, and all the lower pairs (3,4,5,6) to be -field, then waits 10ms for the
            %voltage to settel (from settiling time measured on 05/02/20)
            posPairs = [1,2,7,8];
            negPairs = [3,4,5,6];
            for ii = 1:16
                if any(obj.connectionTable.pairNumber(ii)==posPairs)
                    obj.setVoltage(obj.connectionTable.VOChannel(ii),field);
%                     fprintf('coldEfieldGenerator: set VOChannel %0.0f to %0.2f V\n',obj.connectionTable.VOChannel(ii),field)
                elseif any(obj.connectionTable.pairNumber(ii)==negPairs)
                    obj.setVoltage(obj.connectionTable.VOChannel(ii),-field);
%                     fprintf('coldEfieldGenerator: set VOChannel %0.0f to %0.2f V\n',obj.connectionTable.VOChannel(ii),-field)
                else
                    error('coldEfieldGenerator: problem while setting pad #%0.0f voltage',ii)
                end  
            end
            pause(0.01);
        end
        
        function setYField(obj,field)
            %this function sets the value of all the right pairs (1,2,3,4)to be
            %field, and all the left pairs (5,6,7,8) to be -field, then waits 10ms for the
            %voltage to settel (from settiling time measured on 05/02/20)
            ritPairs = [1,2,3,4];
            lftPairs = [5,6,7,8];
            for ii = 1:16
                if any(obj.connectionTable.pairNumber(ii)==ritPairs)
                    obj.setVoltage(obj.connectionTable.VOChannel(ii),field);
%                     fprintf('coldEfieldGenerator: set VOChannel %0.0f to %0.2f V\n',obj.connectionTable.VOChannel(ii),field)
                elseif any(obj.connectionTable.pairNumber(ii)==lftPairs)
                    obj.setVoltage(obj.connectionTable.VOChannel(ii),-field);
%                     fprintf('coldEfieldGenerator: set VOChannel %0.0f to %0.2f V\n',obj.connectionTable.VOChannel(ii),-field)
                else
                    error('coldEfieldGenerator: problem while setting pad #%0.0f voltage',ii)
                end  
            end
            pause(0.01);
        end
            
    end
end

