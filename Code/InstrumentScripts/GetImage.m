function [err,CamImage] = GetImage(cam, ImageData)

cam.DirectRenderer.StealNextFrame(uc480.Defines.DeviceParameter.Wait);  % Copy image from graphics card to RAM (wait for completion)
%[err, ImageData.Width, ImageData.Height, ImageData.Bits, ImageData.Pitch] = cam.Memory.Inquire(ImageData.ID);
[err, CamImage] = cam.Memory.CopyToArray(ImageData.ID);                        % Copy image from RAM to Matlab array
 if isempty(CamImage)
     CamImage = [];
     return
 end
CamImage = reshape(double(CamImage), [ImageData.Width, ImageData.Height]).';