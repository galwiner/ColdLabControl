function [ Volt ] = VoltageFromCurrent(Amp)
%  VoltageFromCurrent maps 0-200A into 0-10V
    if Amp<0
        Volt = 0;
    end
    Volt = Amp*10/200; %maps 0-200A into 0-10V
end

