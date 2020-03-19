classdef biasFieldManager<handle
    %hold three biasPSU instances and helps set the magnetic field
    
    properties
        bias1
        bias2
    end
    properties (SetAccess = private)
        conversionFactors = [4.355,8.496,12.097] %[x,y,z] gauss/amper (NOT SURE W.R.T SIGN 28/05/19)
        maxIx=1.5;
        maxIz=0.105;
        maxIy=1.2;
    end
    properties (Dependent)
        B
        I
        
    end
    methods
        function obj = biasFieldManager()  
            global p
            if ~isfield(p,'HHGaussPerAmp')
                initp
            end
            obj.conversionFactors = p.HHGaussPerAmp;
            obj.bias1 =BiasPSU('TCPIP::10.10.10.106::inst0::INSTR'); %ch2: Z ch1:Y
            obj.bias2 =BiasPSU('TCPIP::10.10.10.107::inst0::INSTR'); %ch2: X
%             obj.bias1.setTriggerSource(1,'ext1');
%             obj.bias1.setTriggerSource(2,'ext1');
%             obj.bias2.setTriggerSource(2,'ext1');
%             obj.bias2.setTriggerSource(1,'ext1');
%             obj.bias1.setTriggerCount(1,'inf');
%             obj.bias1.setTriggerCount(2,'inf');
%             obj.bias2.setTriggerCount(2,'inf');
%             obj.bias2.setTriggerCount(1,'inf');
            obj.configTrig
            obj.bias1.setVoltageLimit(2,100);
            obj.bias1.setVoltageLimit(1,21);
            obj.bias2.setVoltageLimit(2,21);
            obj.bias2.setVoltageLimit(1,100);
%                           obj.bias1 =BiasPSU('USB0::2391::36888::MY52350175::0::INSTR','USB0::2391::36888::MY52350175::0::INSTR');
        end
        function I=get.I(obj)
            global p
            obj.abortTrigger();
%             fprintf(obj.bias1.conn,'*CLS');
%             fprintf(obj.bias2.conn,'*CLS');
%             fprintf(obj.bias1.conn, ':abort:all');
%             fprintf(obj.bias2.conn, ':abort:all');
            Iy=round(str2double(query(obj.bias1.conn,':meas:curr? (@1)')),6); 
            if ~isfield(p,'zBiasLocationPSU')
                Iz=round(str2double(query(obj.bias1.conn,':meas:curr? (@2)')),6);
            elseif strcmp(p.zBiasLocationPSU,'2,1')
                   Iz=round(str2double(query(obj.bias2.conn,':meas:curr? (@1)')),6);
            else
                Iz=round(str2double(query(obj.bias1.conn,':meas:curr? (@2)')),6);
            end
                Ix=round(str2double(query(obj.bias2.conn,':meas:curr? (@2)')),6);  
%             Iy=round(str2double(query(obj.bias1.conn,':sour1:curr:lev:imm:ampl?')),6);
%             Iz=round(str2double(query(obj.bias1.conn,':sour2:curr:lev:imm:ampl?')),6);
%             Ix=round(str2double(query(obj.bias2.conn,':sour2:curr:lev:imm:ampl?')),6);
            I=[Ix,Iy,Iz];
            if any(I>1.5)
                error('problem with HH coil current. try clearing the error queue')
            end
            
        end
        function configTrig(obj)
            obj.bias1.setTriggerSource(1,'ext1');
            obj.bias1.setTriggerSource(2,'ext1');
            obj.bias2.setTriggerSource(1,'ext1');
            obj.bias2.setTriggerSource(2,'ext1');
            obj.bias1.setTriggerCount(1,'inf');
            obj.bias1.setTriggerCount(2,'inf');
            obj.bias2.setTriggerCount(1,'inf');
            obj.bias2.setTriggerCount(2,'inf');
            
        end
        function sendTrigger(obj)
            obj.bias1.sendTrigger();
             obj.bias2.sendTrigger();
        end
            
        function set.I(obj,current)
            global p
            obj.abortTrigger();
            Ix=current(1);
            Iy=current(2);
            Iz=current(3);
            if Iz>obj.maxIz
                Iz=obj.maxIz;
                error('requested Iz > 105mA');
            end
            if Iy>obj.maxIy
                Iy=obj.maxIy;
                error('requested Iy > 1.5A');
            end
            if Ix>obj.maxIx
                Ix=obj.maxIx;
                error('requested Ix > 1.5A');
            end
            obj.bias1.setCurrent(1,Iy);
            zChan=p.zBiasLocationPSU;
            PSUNum=zChan(1);
            PSUChan=zChan(3);
            if PSUNum==1
                obj.bias1.setCurrent(PSUChan,Iz);
            else
                obj.bias2.setCurrent(PSUChan,Iz);
            end
            obj.bias2.setCurrent(2,Ix);
            actIy=round(str2double(query(obj.bias1.conn,':MEAS:CURR? (@1)')),6);
            actIz=round(str2double(query(obj.bias1.conn,':MEAS:CURR? (@2)')),6);
            actIx=round(str2double(query(obj.bias2.conn,':MEAS:CURR? (@2)')),6);
%             if round(Iz,8)~=0 && abs(1-actIz/Iz)>0.01
%                 error('actual Iz in bias field ~= set Iz');
%                 Iz=actIz;
%                 obj.bias1.setCurrent(1,Iz);
%             end
%             if round(Ix,8)~=0 && abs(1-actIx/Ix)>0.01
%                 error('actual Ix in bias field ~= set Ix');
%                 Ix=actIx;
%                 obj.bias2.setCurrent(2,Ix);
%             end
%             if round(Iy,8)~=0 && abs(1-actIy/Iy)>0.01
%                 error('actual Iy in bias field ~= set Iy');
%                 Iy=actIy;
%                 obj.bias1.setCurrent(2,Iy);
%             end
            %           obj.I=[Ix,Iy,Iz];
        end
        function B=get.B(obj)
            B=obj.I.*obj.conversionFactors;
        end
        
        function set.B(obj,field)
            Bx=field(1);
            By=field(2);
            Bz=field(3);
            %             obj.B=[Bx,By,Bz];
            obj.I=[Bx,By,Bz]./obj.conversionFactors;
        end
        
        function setBinSpherical(obj,magB,theta,phi)
            Bz=magB*cos(theta);
            By=magB*sin(theta)*sin(phi);
            Bx=magB*sin(theta)*cos(phi);
            obj.I=[Bx,By,Bz]./obj.conversionFactors;
        end
        
        function setFieldPath(obj,Bi,Bf,nPts)
            field=getGreatCirclePath(Bi,Bf,nPts);
            Ix=field(:,1)/obj.conversionFactors(1);
            Iy=field(:,2)/obj.conversionFactors(2);
            Iz=field(:,3)/obj.conversionFactors(3);
            obj.bias1.setTriggerCount(1,1);
            obj.bias1.setTriggerCount(2,1);
            obj.bias1.setUserDefinedSignal(1,'curr',Ix',1000e-6)
            obj.bias1.setUserDefinedSignal(2,'curr',Iz',1000e-6)
        end
        
        function configBpulse(obj,Bpulse,duration,varargin)
            global p
            % --it seems we cannot pulse more than one channel simmultaneously
            %this may be because they are triggered from the same source,
            %but i am not sure. 28/5/2019--
            % problem fixed 20/1/2020
            
            duration=duration*1e-6;
            Ipulse=Bpulse./obj.conversionFactors;
           
            I=obj.I;
            
            if nargin==3
                if isnan(Ipulse(2))
                    obj.bias1.setSquare(1,'curr',[I(2),I(2),duration,0,1]); %y
                else 
                    obj.bias1.setSquare(1,'curr',[I(2),Ipulse(2),duration,0,1]); %y
                end
                if isnan(Ipulse(3))
                    if ~isfield(p,'zBiasLocationPSU')
                        obj.bias1.setSquare(2,'curr',[I(3),I(3),duration,0,1]); %z
                    elseif strcmp(p.zBiasLocationPSU,'2,1')
                        obj.bias2.setSquare(1,'curr',[I(3),I(3),duration,0,1]); %z
                    else
                        obj.bias1.setSquare(2,'curr',[I(3),I(3),duration,0,1]); %z
                    end                    
                else 
                    if ~isfield(p,'zBiasLocationPSU')
                        obj.bias1.setSquare(2,'curr',[I(3),Ipulse(3),duration,0,1]); %z
                    elseif strcmp(p.zBiasLocationPSU,'2,1')
                        obj.bias2.setSquare(1,'curr',[I(3),Ipulse(3),duration,0,1]); %z
                    else
                        obj.bias1.setSquare(2,'curr',[I(3),Ipulse(3),duration,0,1]); %z
                    end                                       
                end
                if isnan(Ipulse(1))
                    obj.bias2.setSquare(2,'curr',[I(1),I(1),duration,0,1]); %x
                else
                    obj.bias2.setSquare(2,'curr',[I(1),Ipulse(1),duration,0,1]); %x
                end
            elseif nargin==5
                endTime=varargin{1};
                repetitions=varargin{2};
                
                %params =[topTime,endTime,repetitions]
                
                obj.bias1.setSquare(1,'curr',[I(2),Ipulse(2),duration,endTime*1e-6,repetitions]);
                obj.bias1.setSquare(2,'curr',[I(3),Ipulse(3),duration,endTime*1e-6,repetitions]);
                
            else
                    error('incorrent number of parameters in custom B field pulse config');
            end
            
                    
            
            
%             if ~isnan(Ipulse(3))
%                 obj.bias1.setSquare(2,'curr',[I(3),Ipulse(3),duration,0,1]);
%             else
%                 obj.bias1.setSquare(2,'curr',[I(3),I(3),duration,0,1]);
%             end
%             if ~isnan(Ipulse(2))
            %parms =[startLevel,topLevel,topTime,endTime,repetitions]
            
%             else
%                 obj.bias1.setSquare(1,'curr',[I(2),I(2),duration,0,1]);
%             end
%             if ~isnan(Ipulse(1))
%                 obj.bias2.setSquare(2,'curr',[I(1),Ipulse(1),duration,0,1]);
%             else
%                 obj.bias2.setSquare(2,'curr',[I(1),I(1),duration,0,1]);
%             end
            obj.bias1.initTrigger();
            obj.bias2.initTrigger();
            
            
            
        end
        function configDoubleBpulse(obj,FirstB,SecondB,FirstDuration,SecondDuration)
            global p
% FirstB in Gauss,SecondB in Gauss,FirstDuration in us,SecondDuration in us
            obj.abortTrigger
            firstI=FirstB./obj.conversionFactors;
            SecondI=SecondB./obj.conversionFactors;  
            I=obj.I;
            firstnanInds = isnan(firstI);
            firstI(firstnanInds) = I(firstnanInds);
            secondnanInds = isnan(SecondI);
            SecondI(secondnanInds) = I(secondnanInds);
           obj.bias1.configTriggedDoublePulse(1,firstI(2),SecondI(2),FirstDuration,SecondDuration); %y
           if ~isfield(p,'zBiasLocationPSU')
               obj.bias1.configTriggedDoublePulse(2,firstI(3),SecondI(3),FirstDuration,SecondDuration); %z
           elseif strcmp(p.zBiasLocationPSU,'2,1')
               obj.bias2.configTriggedDoublePulse(1,firstI(3),SecondI(3),FirstDuration,SecondDuration); %z
           else
               obj.bias1.configTriggedDoublePulse(2,firstI(3),SecondI(3),FirstDuration,SecondDuration); %z
           end
           obj.bias2.configTriggedDoublePulse(2,firstI(1),SecondI(1),FirstDuration,SecondDuration); %x
            obj.bias1.initTrigger();
            obj.bias2.initTrigger();
        end
        function abortTrigger(obj)
            obj.bias1.abortTrigger()
            obj.bias2.abortTrigger()
        end
        function initTrigger(obj)
            obj.bias1.initTrigger()
            obj.bias2.initTrigger()
        end
    end
end

