function [cam, ImageData, err] = InitiateCamera(h, ExposureTime)

% Written by Sebastian Duque-Mesa
% 10/9/2017
%
% Inititates Thorlabs Camera by using the .NET library (refer to manual for
% more info) for the uc480 cam.
% Set exposure, gain and pixel format.
% 
%
% Params:
% - h is the window handle to plot the graphics
% - ExposureTime set the camera exposure in seconds
%
% Returns:
% - cam the info of the camera
% - ImageData contains the description of the image [ImageData.Width, 
%   ImageData.Height, ImageData.Bits, ImageData.Pitch]
%   err is the string "SUCCESS" if the camera is initiated properly, "NO_SUCCESS" otherwise


% Add NET assembly if it does not exist
% May need to change specific location of library
asm = System.AppDomain.CurrentDomain.GetAssemblies;
if ~any(arrayfun(@(n) strncmpi(char(asm.Get(n-1).FullName), ...
  'uc480', length('uc480DotNet')), 1:asm.Length))
 NET.addAssembly(...
  'D:\Box Sync\Lab\ExpCold\FPGA control\ControlSystem\Code\InstrumentScripts\uc480DotNet.dll');
end

% Create camera object
cam = uc480.Camera;

% Initialize camera, setting window handle for display
% Change the first argument from 0 to camera ID to initialize a specific
% camera, otherwise first camera found will be initialized
cam.Init(0);

% Ensure Direct3D mode is set
cam.Display.Mode.Set(uc480.Defines.DisplayMode.Direct3D);

% Set camera gain
cam.Gain.Hardware.Boost.SetEnable(false);
cam.Gain.Hardware.ConvertScaledToFactor.Blue(0);
cam.Gain.Hardware.ConvertScaledToFactor.Green(0);
cam.Gain.Hardware.ConvertScaledToFactor.Master(0);
cam.Gain.Hardware.ConvertScaledToFactor.Red(0);

% Set exposure [seconds]
cam.Timing.Exposure.Set(ExposureTime);

% Set to Raw pixel data
err = cam.PixelFormat.Set(uc480.Defines.ColorMode.SensorRaw8);

% Set up camera for copying image to Matlab memory for processing
[err, ImageData.ID] = cam.Memory.Allocate(true);
[err, ImageData.Width, ImageData.Height, ImageData.Bits, ImageData.Pitch]= cam.Memory.Inquire(ImageData.ID);
cam.DirectRenderer.SetStealFormat(uc480.Defines.ColorMode.SensorRaw8);

% Start camera live capture
cam.Acquisition.Capture;

disp('ThorCam started')