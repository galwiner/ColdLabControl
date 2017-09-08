function [err,CamImage] = GetImage(cam, ImageData)

cam.DirectRenderer.StealNextFrame(uc480.Defines.DeviceParameter.Wait);  % Copy image from graphics card to RAM (wait for completion)
[err, CamImage] = cam.Memory.CopyToArray(ImageData.ID);                        % Copy image from RAM to Matlab array
CamImage = reshape(uint8(CamImage), ImageData.Width, ImageData.Height).';