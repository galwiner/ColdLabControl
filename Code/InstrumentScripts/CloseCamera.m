function CloseCamera(cam, ImageData)

% Stop capture
cam.Acquisition.Stop;
% Free image memory
cam.Memory.Free(ImageData.ID);

% Close camera
cam.Exit;

disp('ThorCam stopped')