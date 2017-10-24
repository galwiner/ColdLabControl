classdef pixelfly < handle
    %object to run a pixelfly camera
    
    properties
        handle
        src
        
    end
    
    properties (Access=private)
        state %is the camera running? 
        scale % m / pix
    end
    
    properties (Dependent)
    x %image plane coordinates x 
    y %image plane coordinates y 
    end
    
    
    
    
    methods
        
        function obj=pixelfly()
            obj.handle = videoinput('pcocameraadaptor', 0, 'USB 2.0');
            obj.src = getselectedsource(obj.handle);
            obj.state=0;
            obj.scale=4.32e-5; %m/pix
            obj.setExposure(10);
        end
        
        function val=get.x(obj)
            w=double(obj.src.H2HardwareROI_Width);
            
            val=linspace(-w/2,w/2,w)*obj.scale*str2double(obj.src.B1BinningHorizontal);
        end
        
        function val=get.y(obj)
            h=double(obj.src.H5HardwareROI_Height);
            val=linspace(-h/2,h/2,h)*obj.scale*str2double(obj.src.B2BinningVertical);
        end
        
        function [x,y]=getImSize(obj)
            x=double(obj.src.H2HardwareROI_Width);
            y=double(obj.src.H5HardwareROI_Height);
        end
        
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
            warning('stopping pixelfly camera.');
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
        
        function newScale=setScale(obj,scale)
             obj.scale=scale;
            newScale=scale;
        end
        
        function scale=getScale(obj)
            scale=obj.scale;
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
        
        function setHardwareTrig(obj)
            if obj.getState==1
                obj.stop
            end
                triggerconfig(obj.handle, 'hardware', '', 'ExternExposureStart');
                fprintf('hardware mode set to ext trigger. \nCamera status: Stopped\n');
            
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
            end
            
        end
        
        function delete(obj)
            warning('deleting pixelfly camera object.');
            obj.stop;
        end
        
            
            
        
    end
    
end

