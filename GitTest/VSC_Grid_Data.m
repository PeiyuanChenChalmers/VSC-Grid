clc 
clear 
close all  
%**********************************************************************
% m-file for VSC controller
%**********************************************************************
fn = 50; % Hz, rated frequency
wn = 2*pi*fn; % rad/s, rated angular frequency
Ts = 2e-4; % s, sampling time
fs = 1/Ts; % Hz, sampling frequency
fsw = fs; % Hz, switching frequency

%**********************************************************************
% Per unit bases                                                      
%**********************************************************************
Sb = 35000;         % W, 3-phase power
Vb = 230*sqrt(2);   % V, AC phase, peak
Vdcb = Vb*2;        % V, DC   
wb = wn;            % rad/s, rotating frequency base
Ib = Sb/(3/2*Vb);   % A, AC phase, peak
Zb = Vb/Ib;         % ohm, phase
Lb=Zb/wb;           % H, phase

%**********************************************************************
% Filter parameters                                                      
%**********************************************************************
Rf=6e-3; % ohm, filter resistance
Lf=2e-3; % H, filter inductance

Rf_pu=Rf/Zb;
Lf_pu=Lf/Lb; 

%**********************************************************************
% Non-ideal IGBT and inverse diode, 25 deg temperature                                                     
%**********************************************************************
Vce0=1;             % V, IGBT CE voltage drop
% Rce=5.3e-3;         % ohm, IGBT CE resistance, chip level
Rce=1e-3;
Rccee=0.3e-3*0;       % ohm, IGBT resistance, module level
R_IGBT=Rce+Rccee;

% Vt0=1.3;            % V, inverse diode forward voltage drop
Vt0=1;
% Rt=(3.3e-3);      % ohm, inverse diode resistance, chip level (not possible to implement here in simulink)
Rt=R_IGBT;

%**********************************************************************
% Current Control parameters: Grid                                                      
%**********************************************************************
alpha_CC= 2*pi*fs/10;       % rad/s, bandwidth (2*pi*500)
Kp_CC= alpha_CC*Lf_pu/wb;   % pu, Proportional gain
Ki_CC= alpha_CC*Rf_pu;      % rad/s, integral gain

%**********************************************************************
% Grid PLL                                                  
%**********************************************************************
alpha_PLL= 2*pi*5;    % rad/s, bandwidth (alpha_CC/100)
fmax= 55;   % pu, Proportional gain
fmin= 45;      % rad/s, integral gain

%**********************************************************************
% Grid PQ controller                                                    
%**********************************************************************
alpha_PQ= alpha_CC/10;    % rad/s, bandwidth (2*pi*50)

%**********************************************************************
% Resistor when charging DC capacity from the grid                                                   
%**********************************************************************
R_rectifier=50; % ohm


%**********************************************************************
% dc-link controller                                                   
%**********************************************************************
alpha_dc= alpha_CC/10;      % rad/s, bandwidth (2*pi*50)
C_dc=6080e-06;              % F, capacitance of the DC-link capacitor,6600e-06
Ca=alpha_dc*C_dc*1;         % rad/s*F, active damping term
Kp_dc=alpha_dc*C_dc;        % rad/s*F, Proportional gain
Ki_dc=alpha_dc*Ca*1+Kp_dc/0.3*0;          % (rad/s)^2*F, integral gain, active damping or a simple time constant of 0.3 sec/rad
Igmax=Ib;                   % A, maximum grid-side current, phase peak






