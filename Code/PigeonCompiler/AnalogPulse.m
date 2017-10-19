classdef AnalogPulse < Pulse 
    %Generate an analog pulse
    
    properties
        voltage;
        end
    
    methods
        function obj = AnalogPulse(ch,ts,width,voltage,varargin)
            obj@Pulse(ch,ts,width); 
            obj.analog=true;
            obj.voltage=2^15*(voltage/10); %16 bit output mapped to +/- 10 Volts

           if ischar(ch)
              ch=PulseChannelInfo(ch);
           end
           obj.Channel = ch;
        end
        
    end
    
end

