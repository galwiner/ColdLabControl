classdef NumControl < handle
% This class create numeric control in a GUI
% syntax:
% num=NumControl(fig,x,y,label);
% num=NumControl(fig,x,y,label,'increase',inc,'value',val,'callback',@function);
% fig - handle for the figure on which to place the control
% x,y - coordinates in the figure in which to place the control
% label - the string which will be display next to the control
% val - the initial value 
% inc - the increasment of the value when the up/down button is pressed
% @function - a handle to a function that will be called when the value of
% the control is changed
properties
    upb;  
    dpb;  
    nedit;
    name;
    N=0;
    inc=0.1;
    user_callback=[];
    
end
 
methods
    function obj=NumControl(fig,x,y,name,varargin) 
        [up,umap]=imread('uptrig.bmp');
        [down,dmap]=imread('downtrig.bmp');
        for i=1:2:size(varargin,2)
           switch lower(char(varargin(i)))
               case 'value'
                   obj.N=varargin{i+1};
               case 'increase'
                   obj.inc=varargin{i+1};
               case 'callback'
                   obj.user_callback=varargin{i+1};
           end; %switch
       end;%for loop      
 
        obj.upb = uicontrol(fig,'Style','pushbutton',...
                  'Position',[x+80,y+15,15,15],'CData',ind2rgb(up,umap),...
                  'visible','on','Callback',@obj.up_callback);
        obj.dpb = uicontrol(fig,'Style','pushbutton',...
                  'Position',[x+80,y,15,15],'CData',ind2rgb(down,dmap),...
                  'visible','on','Callback',@obj.down_callback);
        obj.nedit=uicontrol(fig,'Style','edit','Fontsize',12,...
                  'Position',[x,y,80,30],'String',num2str(obj.N),...
                  'Callback',@obj.numedit_callback);  
        if fig==gcf
            p=[0 0];
        else
            p=get(fig,'Position');
        end
        obj.name = name;
        annotation(gcf,'textbox','Units','pixels','Position',...
        [p(1)+x,p(2)+y+30 100 35 ],'String',name,...
        'FontSize',8,'EdgeColor','none'); 
    end

    function SetValue(obj,newN)
        obj.N=newN;
        set(obj.nedit,'String',num2str(obj.N));
        if ~isempty(obj.user_callback)
            obj.user_callback(obj);
        end
    end
    function up_callback(obj,handle,eventdata)  
        obj.N=obj.N+obj.inc;
        set(obj.nedit,'String',num2str(obj.N));
        if ~isempty(obj.user_callback)
            obj.user_callback(obj);
        end
    end
    function down_callback(obj,handle,eventdata)
        obj.N=obj.N-obj.inc;
        set(obj.nedit,'String',num2str(obj.N));
        if ~isempty(obj.user_callback)
            obj.user_callback(obj);
        end
    end 
    function numedit_callback(obj,handle,eventdata)
        obj.N=str2num(get(obj.nedit,'String'));
        if ~isempty(obj.user_callback)
            obj.user_callback(obj);
        end
    end

end
end 