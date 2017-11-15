classdef IOnitDDS < handle
    %class to represent Meir Alon's DDS
    
    properties
        s
        comport='COM1';
        name='DDS#1'
    end
    
    methods
        function obj = IOnitDDS(parallel,DRG,Singlemode,OSK,REF1,TCXO1)
            %             obj.s = serial(obj.comport,'BaudRate',9600,'DataBits',8);
            try
                if nargin==0
                    INIT(obj,0,0,1,0,0,0);
                else
                    INIT(obj,parallel,DRG,Singlemode,OSK,REF1,TCXO1);
                end
            catch ERR
                error('Error in DDS initialization')
            end
            disp('DDS initialized');
            
        end
        
        function setFreq(obj,freq,offset_phase,Adb)
            if nargin==2
                offset_phase=0;
                Adb=0;
            end
            setFreqInternal(obj,freq,offset_phase,Adb);
        end
        
        function setupSweepMode(obj,UP_FREQUENCY,DOWN_FREQUENCY,dtP,dtN,dfP,dfN)
            DRG_INIT(obj,UP_FREQUENCY,DOWN_FREQUENCY,dtP,dtN,dfP,dfN);
        end
        
        function delete(obj)
            fclose(obj.s);
            disp(['serial connection to ' obj.name  ' closed']);
        end
    end
end

