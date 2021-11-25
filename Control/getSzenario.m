function [r,radius,density] = getSzenario(folder,fileName,deltaT)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% szenario file
file = strcat(folder,fileName);
S = load(file);
S = S.szenario;
if isfield(S,'slope')
    % particle input is not constant: its a ramp
    % simulation time
    T_end = S.T_end;
    % number of time steps the simulation takes + extra number of time
    % steps since the MPC needs predicted values
    k_end = T_end/deltaT+200;
    m = S.m_start*ones(1,k_end+1)+S.slope*(0:deltaT:(T_end+200*deltaT));
    rP = S.shareP*m;
    rN = (1-S.shareP)*m;
elseif isfield(S,'T_jump')
    % particle input is not constant: its a jump at T_jump
    % particle input is not constant: its a ramp
    % simulation time
    T_end = S.T_end;
    % number of time steps the simulation takes + extra number of time
    % steps since the MPC needs predicted values
    k_end = T_end/deltaT+200;
    % jump happens at time step k_jump
    T_jump = S.T_jump;
    k_jump = T_jump/deltaT;
    m = S.m_start*ones(1,k_end);
    m(k_jump:k_end) = S.m_afterJump;
    rP = S.shareP*m;
    rN = (1-S.shareP)*m;
else
    % particle input is constant
    rP = S.rP;
    rN = S.rN;
end
r = [rP; rN];
% radius in mm
if isfield(S,'radius_mm')
    radius = [S.radius_mm.P; S.radius_mm.N];
else
    warning('no radius defined')
    radius = zeros(2,1);
end
% density in kg/m^3
if isfield(S,'density_kg_m')
    density = [S.density_kg_m.P; S.density_kg_m.N];
else
    warning('no density defined')
    density = zeros(2,1);
end
end

