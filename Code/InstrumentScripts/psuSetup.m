function psuSetup(circBool,rectBool)

if nargin<1
    circBool=1;
    rectBool=0;
end

if nargin<2
    rectBool=0;
end


if circBool
    t1=tcpip('10.10.10.102',8462);
    fopen(t1);
%clear error queue
    for i=1:10
        fprintf(t1,'system:error?');
        fscanf(t1);
    end

% set analog programming range to high (0-10V)
    fprintf(t1,'system:interface:ianalog 4,RANGE,HI');
    fprintf(t1,'*SAV');

% set voltage programming to ethernet interface
    fprintf(t1,'system:remote:cv:status ethernet');

%set current programming interface to analog interface
    fprintf(t1,'system:remote:cc:status slot4');
    
% set limits to maximum. Current is limited to 120 until we gwt a new IGBT
    fprintf(t1,'system:limits:voltage 18,ON');
    fprintf(t1,'system:limits:current 220,ON');

    fprintf(t1,'source:voltage 18');
% turn output on 
    fprintf(t1,'output on');
    fclose(t1);
    disp('circular coil setup complete');
end

if rectBool
    t1=tcpip('10.10.10.103',8462);
    fopen(t1);
%clear error queue
    for i=1:10
        fprintf(t1,'system:error?');
        fscanf(t1);
    end

% set analog programming range to high (0-10V)
    fprintf(t1,'system:interface:ianalog 4,RANGE,HI');
    fprintf(t1,'*SAV');

% set voltage programming to ethernet interface
    fprintf(t1,'system:remote:cv:status ethernet');

%set current programming interface to analog interface
    fprintf(t1,'system:remote:cc:status slot4');
    
% set limits to maximum. Current is limited to 120 until we gwt a new IGBT
%changed the limit after replacing IGBT. let's see. 16/10/17 GW
    fprintf(t1,'system:limits:voltage 18,ON');
    fprintf(t1,'system:limits:current 220,ON');

    fprintf(t1,'source:voltage 18');
% turn output on 
    fprintf(t1,'output on');
    fclose(t1);
    disp('rectangular coil setup complete');
end

