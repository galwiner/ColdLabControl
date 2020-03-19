classdef omegaDAC
    %controlling the OM-USB-3105
    
    properties
        library
        board
    end
   
    methods
        function obj = omegaDAC()
            
            obj.library = NET.addAssembly('D:\Dropbox (Weizmann Institute)\Lab\ExpCold\ControlSystem\Code\InstrumentScripts\omegaDAC\MccDaq.dll');
            obj.board=MccDaq.MccBoard(0);
            for ind=1:16
                obj.board.BoardConfig.SetDacRange(ind-1,MccDaq.Range.Bip10Volts);
            end
                 
        end
        
        function setVoltage(obj,chan,voltage)
            if voltage>10 && voltage < -10 
                error(sprintf('bad voltage range in omega channel %d',chan));
            end
            range=MccDaq.Range.Bip10Volts;
            Options=MccDaq.VOutOptions.Default;
            obj.board.VOut(chan, range, voltage, Options);
        end
        
    end
end

