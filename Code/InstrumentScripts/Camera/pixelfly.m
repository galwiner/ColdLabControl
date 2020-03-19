classdef pixelfly < handle
    %object to run a pixelfly camera
    
    properties
        handle
        src
        ROIX %in pixels
        ROIY %in pixels
        name;
        ID;
        Number; %This is 716 for the plane and 1234 for the top
    end
    
    
    
    properties (Access=private)
        state %is the camera running? 
        binning_free_scale=4.0994e-06;%m/pix. calibrated using test target. 
    end
    
    properties (Dependent)
    x %image plane coordinates x 
    y %image plane coordinates y 
     
    end
    methods
        
        function obj=pixelfly(varargin)
            driverName = 'PCOCameraAdaptor_R2018a';
            driverInfo = imaqhwinfo(driverName);
            names = {driverInfo.DeviceInfo.DeviceName};
            IDs = {driverInfo.DeviceInfo.DeviceID};
            %When changing to the 2018a driver the device IDs became 0 to
            %the pixelfly top and 1 to the top, where bofore it was the
            %otherway arrond, and we tought that it was related to the name
            %orer (first or second in the camera names array.
%             if str2num(names{1}(end-1))==6 %The plane neme is 'pco.USB.Pixel.Fly [716]' and the top name is 'pco.USB.Pixel.Fly [1234]'
%             planeID = IDs{1};
%             TopID = IDs{2};
%             else
%             planeID = IDs{2};
%             TopID = IDs{1};
%             end
            try
            obj.handle = videoinput(driverName,IDs{1}, 'USB 2.0');
            catch err
                disp(err.identifier);
                error('error in initializing pixelfly. is native software running?');
            end
            obj.src = getselectedsource(obj.handle);
            obj.src.E1ExposureTime_unit='us';
            obj.src.B1BinningHorizontal='01';
            obj.src.B2BinningVertical='01';
            obj.state=0;
            obj.setExposure(10);
%             obj.ROIX = [50,200]; %in pixels
%             obj.ROIY = [75,225];
            ROI = obj.handle.ROIPosition; %returns [
            obj.ROIX = [ROI(1),ROI(3)];
            obj.ROIY = [ROI(2),ROI(4)];
%             obj.handle.FramesPerTrigger=440;
        end
        
        function val=get.x(obj)
            %changed in 24/10/18 to accont for dinamic ROI
            %w=double(obj.src.H2HardwareROI_Width);
            %val=linspace(1,w+1,w).*obj.binning_free_scale.*str2double(obj.src.B1BinningHorizontal);
            width = double(obj.ROIX(2));
            val=linspace(1,width+1,width).*obj.binning_free_scale.*str2double(obj.src.B1BinningHorizontal);
        end
        
        function val=get.y(obj)
            %changed in 24/10/18 to accont for dinamic ROI
%             h=double(obj.src.H5HardwareROI_Height);
%             val=linspace(1,h+1,h).*obj.binning_free_scale.*str2double(obj.src.B2BinningVertical);
            hight = double(obj.ROIY(2));
            val=linspace(1,hight+1,hight).*obj.binning_free_scale.*str2double(obj.src.B2BinningVertical);
        end
%         function val=get.scale(obj)
%             val=obj.binning_free_scale*str2double(obj.src.B2BinningVertical);
%         end
        
        function [x,y]=getImSize(obj)
            %changed in 24/10/18 to accont for dinamic ROI
%             x=double(obj.src.H2HardwareROI_Width);
%             y=double(obj.src.H5HardwareROI_Height);
                width = obj.ROIX(2);
                hight = obj.ROIY(2);
                x=double(width);
                y=double(hight);
        end
        function [x,y]=setROI(obj,ROI)
            %ROI format [leftOffset topOfset Width Hight]
            if (ROI(1)+ROI(3))>obj.src.H2HardwareROI_Width
                error('Horizontal ROI error. leftOffset + Width larger than H2HardwareROI_Width') 
            end
            if (ROI(2)+ROI(4))>obj.src.H5HardwareROI_Height
                error('Vertical ROI error. topOffset + Hight larger than H5HardwareROI_Height')
            end
            obj.ROIX = [ROI(1),ROI(3)];
            obj.ROIY = [ROI(2),ROI(4)];
            obj.handle.ROIPosition = ROI;
        end
%         function [x,y]=getROI(obj)
%             obj.src.H2HardwareROI_Width = obj.ROIX;
%             obj.src.H5HardwareROI_Height = obj.ROIY;
%         end
        function val=getExposure(obj)
            obj.src.E1ExposureTime_unit='us';
            val=obj.src.E2ExposureTime;
        end
       
        
        function val=setExposure(obj,exposure)
            %exposure time in us
            obj.src.E1ExposureTime_unit='us';
            obj.src.E2ExposureTime=exposure;
            val=obj.src.E2ExposureTime;
            
        end
        function start(obj)
            if obj.state
                warning('camera already started')
            else
                start(obj.handle);
                obj.state=1;
            end
        end
        
        function stop(obj)
%             warning('stopping pixelfly camera.');
            stop(obj.handle);
            obj.state=0;
        end
        
        function ret=getState(obj)
            
            state=obj.handle.Running;
            if(strcmpi(state,'on'))
                ret=1;
            elseif(strcmpi(state,'off'))
                ret=0;
            else
                error('error in pixelfly camera state');
            end
                
        end
        function scale=getScale(obj)
            scale=obj.binning_free_scale*str2num(obj.src.B1BinningHorizontal);
        end
        
        function [xBin,yBin]=getBinning(obj)
            xBin=obj.src.B1BinningHorizontal;
            yBin=obj.src.B2BinningVertical;
        end
        
        function [xBin,yBin]=setBinning(obj,xBin,yBin)
           if nargin==2
           obj.src.B1BinningHorizontal=xBin;
           elseif nargin==3
           obj.src.B1BinningHorizontal=xBin;
           obj.src.B2BinningVertical=yBin;
           else 
               error('no binning option given');
           end 
           
           xBin=obj.src.B1BinningHorizontal;
           yBin=obj.src.B2BinningVertical;
           
        end
        
        function im=livePreview(obj,handle)
            if obj.getState==1
                obj.stop;
            end
            triggerconfig(obj.handle, 'manual');
            obj.start;
            im=double(getdata(obj.handle, 1));
            
        end
        
             
        
        function im=snapshot(obj)
            %take a single image right now
            if obj.getState==1
                obj.stop;
                triggerconfig(obj.handle, 'manual');
                obj.start;
                trigger (obj.handle);
                im=double(getdata(obj.handle, 1));
            else 
                triggerconfig(obj.handle, 'manual');
                obj.start;
                trigger (obj.handle);
                im=double(getdata(obj.handle, 1));
                obj.stop;
            end
            
            
        end
        
        function setHardwareTrig(obj,nTrigs)
            %nTrigs is the number of images to be acquired
            if nargin==1
                obj.handle.TriggerRepeat=0;
            else
                obj.handle.TriggerRepeat=nTrigs-1;
            end
            
            if obj.getState==1
                obj.stop
            end
                triggerconfig(obj.handle, 'hardware', '', 'ExternExposureStart');
                
                fprintf('hardware mode set to ext trigger.\n');
            
        end
        
        function im=showSnap(obj)
            im=obj.snapshot;
            imagesc(obj.x,obj.y,im);
            colorbar;
            [xbin,ybin]=getBinning(obj);
            title(['binning: ' xbin 'X' ybin]);
        end
        
        function snapAndFit(obj)
            im=double(obj.snapshot);
            im=fliplr(im)';
            [p,fitImg]=fitImageGaussian2D([],[],im,1);
            [xbin,ybin]=getBinning(obj);
            figure;
            subplot(2,1,1);
            imagesc(fitImg);
            colorbar
            title('fit');
            subplot(2,1,2);
            imagesc(im);
            title('original');
            colorbar
            
        end
        function images=getImages(obj,N)
            %N is the number of images to get from the camera
            if nargin<2
                N=1;
            end
           
            if ~obj.state
                error('cannot get images when camera is not running');
            else
                images=double(squeeze(getdata(obj.handle,N)));
%                 images=double(getdata(obj.handle,N));
                flushdata(obj.handle);
                
            end
            
        end
        
        function delete(obj)
%             warning('deleting pixelfly camera object.');
            obj.stop;
        end
        
            
            
        
    end
    
end

