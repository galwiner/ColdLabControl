function [Value, Timestamp]=MeasPowerMeter
try
    oph = actxserver('OphirLMMeasurement.CoLMMeasurement');
catch COM_error
    disp(COM_error.message);
    error('Could not establist a link to OphirLMMeasurement');
end

SerialNumbers = oph.ScanUSB;
if(isempty(SerialNumbers))
    warndlg('No USB devices seem to be connected. Please check and try again',...
            'Ophir Measurement COM interface: ScanUSB error')
end
usb = oph.OpenUSBDevice(SerialNumbers{1});
oph.StopAllStreams;    


% oph.ModifyWavelength(usb(1),0,4,795);
% oph.SetWavelength(usb(1),0,5); % Currently 780nm
% oph.SetWavelength(usb(1),0,4); % Currently 795nm

% oph.SetRange(usb(1),0,MeterRange);

sensor=0;
oph.StartStream(usb(1),sensor);
pause(0.8);
oph.StopAllStreams;
% [Value Timestamp Status]= oph.GetData(usb(1),sensor);
Value=[];
t=tic;
while isempty(Value) && toc(t)<10 
[Value, Timestamp, ~]= oph.GetData(usb(1),sensor);
end
Value(isnan(Value))=0;
end



