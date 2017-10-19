% Add NET assembly if it does not exist
% May need to change specific location of library
asm = System.AppDomain.CurrentDomain.GetAssemblies;
if ~any(arrayfun(@(n) strncmpi(char(asm.Get(n-1).FullName), ...
  'uc480', length('uc480DotNet')), 1:asm.Length))
 NET.addAssembly(...
  'D:\Box Sync\Lab\ExpCold\FPGA control\ControlSystem\Code\InstrumentScripts\uc480DotNet.dll');
end

% Create window to display image
NET.addAssembly('System.Windows.Forms');
if ~exist('h', 'var')
 h = System.Windows.Forms.Form;
 h.Show;
end

if ~isequal(h.WindowState, System.Windows.Forms.FormWindowState.Maximized)
 h.WindowState = System.Windows.Forms.FormWindowState.Maximized;
end

% Create camera object
cam = uc480.Camera;

% Initialize camera, setting window handle for display
% Change the first argument from 0 to camera ID to initialize a specific
% camera, otherwise first camera found will be initialized
cam.Init(0, h.Handle);

% Ensure Direct3D mode is set
cam.Display.Mode.Set(uc480.Defines.DisplayMode.Direct3D);

% Set camera gain
cam.Gain.Hardware.Boost.SetEnable(false);
cam.Gain.Hardware.ConvertScaledToFactor.Blue(0);
cam.Gain.Hardware.ConvertScaledToFactor.Green(0);
cam.Gain.Hardware.ConvertScaledToFactor.Master(0);
cam.Gain.Hardware.ConvertScaledToFactor.Red(0);

% Set exposure [seconds]
cam.Timing.Exposure.Set(0.002);

% Set to Raw pixel data
err = cam.PixelFormat.Set(uc480.Defines.ColorMode.SensorRaw8);

% Set up camera for copying image to Matlab memory for processing
[err, ImageData.ID] = cam.Memory.Allocate(true);
[err, ImageData.Width, ImageData.Height, ImageData.Bits, ImageData.Pitch]= cam.Memory.Inquire(ImageData.ID);
cam.DirectRenderer.SetStealFormat(uc480.Defines.ColorMode.SensorRaw8);

% [err, tmp] = cam.Memory.CopyToArray(ImageData.ID);
% MyImage = reshape(uint8(tmp), [ImageData.Width, ImageData.Height, ImageData.Bits/8]);
% MyImage = double(rot90(MyImage',2));
% imagesc(MyImage)


% Set up matlab figure for processed image
clf
hImg = imagesc;
axis(hImg.Parent, 'image');
axis(hImg.Parent, 'tight');
hx = line(0, 0, 'Color', 'r', 'LineWidth', 2);
hy = line(0, 0, 'Color', 'r', 'LineWidth', 2);
hStp = uicontrol('Style', 'ToggleButton', 'String', 'Stop', ...
 'ForegroundColor', 'r', 'FontWeight', 'Bold', 'FontSize', 20);
hStp.Position(3:4) = [100 50];

% Start live capture
cam.Acquisition.Capture;
fprintf('Capturing images ...\n');

% Continue until Stop button pressed
T = zeros(10, 1);
tic
while ~hStp.Value || strcmp(err, uc480.Defines.Status.NO_SUCCESS)
 % Copy image from graphics card to RAM (wait for completion)
 cam.DirectRenderer.StealNextFrame(uc480.Defines.DeviceParameter.Wait);
 
 % Copy image from RAM to Matlab array
 [err, I] = cam.Memory.CopyToArray(ImageData.ID);
 I = reshape(uint8(I), ImageData.Width, ImageData.Height).';
 
 % Calculate marginals
 Ix = sum(uint64(I));
 Iy = sum(uint64(I), 2);
 
 % Plot data
 hImg.CData = I;
 hx.XData = 1:length(Ix);
 hx.YData = Ix*.2*diff(hImg.YData)/max(Ix);
 hy.YData = 1:length(Iy);
 hy.XData = Iy*.2*diff(hImg.XData)/max(Iy);
 T = [T(2:end); toc];
 title(sprintf('FPS: %.1fs %s', 10/diff(T([1 end])), ...
  datestr(now, 'HH:MM:SS.FFF dd/mm/yyyy')));
 drawnow;
end
hStp.Value = false;

% Stop capture
cam.Acquisition.Stop;
% Free image memory
cam.Memory.Free(ImageData.ID);

fprintf('I''ve had enough of that now!!!\n');

% Close camera - ALWAYS make sure the camera is closed before attempting to
% initialize again!!!
cam.Exit;
