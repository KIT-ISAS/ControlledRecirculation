function [N] = grams2particles(M,type,density, radius)
% GRAMS2PARTICLES Changes the unit of the Matrix M from g/s to particles/s
%   Inputs:
%       -M: matrix M with values in g/s
%           -size: (MyDim,MxDim)
%           -x-direction of M: time 
%           -y-direction of M: particle type
%       -type: classifies which type of particle is in each row of M
%           -size: (MyDim,1)
%       -density: density of a particle in kg/m^3 for each type
%           -size: (numberTypes,1)
%       -radius of a particle in mm for each type
%           -size: (numberTypes,1)
%   Output:
%       -N matrix N with values in particles/s
[MyDim,MxDim] = size(M);
if MyDim ~= size(type,1)
    warning('column vector type is of wrong dimension')
end
N = zeros(MyDim,MxDim);
for i=1:MyDim
    particleType = type(i,1);
    % approximated volume of an particle of type particleType in m^3
    Volume = 4/3*pi*(radius(particleType)/1000)^3;
    % input mass flow in particles/s
    N(i,:) = M(i,:)/(1000*density(particleType)*Volume);
end

