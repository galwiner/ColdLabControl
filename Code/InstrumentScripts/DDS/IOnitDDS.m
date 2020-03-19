classdef IOnitDDS < handle
    %class to represent Meir Alon's DDS
    
    properties
        s
        comport='COM1';
        name='DDS#1'
    end
    
    methods
        function obj = IOnitDDS(parallel,DRG,Singlemode,OSK,REF1,TCXO1,comport)
            %             obj.s = serial(obj.comport,'BaudRate',9600,'DataBits',8);
            try
                if nargin==0
                    obj.comport='COM1';
                    INIT(obj,0,0,1,0,0,0);
                else
                    obj.comport=comport;
                    INIT(obj,parallel,DRG,Singlemode,OSK,REF1,TCXO1);
                end
            catch ERR
                error(ERR.identifier,'Error in DDS initialization.\n %s',ERR.message)
            end
            disp('DDS initialized');
            
        end
        
        function setFreq(obj,freq,offset_phase,Adb)
            if nargin==2
                offset_phase=0;
                Adb=0;
            end
            setFreqInternal(obj,freq,offset_phase,Adb);
        end
        
%         function setupSweepMode(obj,UP_FREQUENCY,DOWN_FREQUENCY,dtP,dtN,dfP,dfN)
%             DRG_INIT(obj,UP_FREQUENCY,DOWN_FREQUENCY,dtP,dtN,dfP,dfN);
%         end
        function setupSweepMode(obj,center,span,time,multiplyer,symmetric,varargin)
            %time in [uS]
            %varargin order: {1} = rampDownTime; {2} = Numner of steps
            if nargin <7
                symmetric = 1;
            end
            N = 1000; %Number of steps
            if nargin == 9 %2 varargin
                N = varargin{2};
            end
            if time/span<2
                warning('If time/span < 2 you risk broadeniong the line');
            end
            
            UP_FREQUENCY = (center + span/2)/multiplyer;
            DOWN_FREQUENCY = (center - span/2)/multiplyer;
            dfP = span*1e6/N/multiplyer; %in Hz
            dtP=time*1e-6/N;%in sec
            if dtP>260
                warning('Performing more then 1000 steps')
                N = time/260;
                dtP=time*1e-6/N;%in sec
                dfP = span*1e6/N/multiplyer; %in Hz
            end
            if symmetric==1
            dtN=dtP;
            else
                try
                    dtN = varargin{1}*1e-6/N;%in sec
                catch
                    error('symmetric is not 1 but no rampDownTime found!');
                end
            end
            dfN=dfP;
            
            fprintf('Set DDS ramp step size to: %.2e Hz/step\n',dfP);
            
            if dfN/dtN < 1
                error('Cannot set sweep rate to more than 1 MHz/ uS!');
            end
            INIT(obj,0,1,0,0,1,1);
            DRG_INIT(obj,UP_FREQUENCY,DOWN_FREQUENCY,dtP,dtN,dfP,dfN);
            DRG_INIT(obj,UP_FREQUENCY,DOWN_FREQUENCY,dtP,dtN,dfP,dfN);
%             for ii = 1:3
%             pause(2);
%             SHOVACH_DRG_INIT(obj,chan,UP_FREQUENCY,DOWN_FREQUENCY,dtP,dtN,dfP,dfN);
%             fprintf('Looping for detDDSSqeepMode. Loop # %d\n',ii)
%             end
        end

        
        function delete(obj)
            fclose(obj.s);
            disp(['serial connection to ' obj.name  ' closed']);
        end
    end
end

