classdef AnalogPulse < Pulse 
    %Generate an analog pulse
    
    properties
        voltage;
        end
    
    methods
        function obj = AnalogPulse(ch,ts,width,voltage,varargin)
            obj@Pulse(ch,ts,width); 
            obj.analog=true;
            if strcmpi(ch,'forStart')||strcmpi(ch,'forEnd')
                obj.voltage=voltage; %used for number for loops
            else 
            obj.voltage=ceil(2^15*(voltage/10)); %16 bit output mapped to +/- 10 Volts
            end


           if ischar(ch)
              ch=PulseChannelInfo(ch);
           end
           obj.Channel = ch;
        end
        
    end
    
end

