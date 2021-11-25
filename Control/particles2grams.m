function M = particles2grams(N,type,density, radius)
%PARTICLES2GRAMS Changes the unit of the Matrix M from particles/s to g/s
%   Inputs:
%       -N: matrix N with values in particles/s
%           -size: (NyDim,NxDim)
%           -x-direction of N: time 
%           -y-direction of N: particle type
%       -type: classifies which type of particle is in each row of N
%           -size: (NyDim,1)
%       -density: density of a particle in kg/m^3 for each type
%           -size: (numberTypes,1)
%       -radius: radius of a particle in mm for each type
%           -size: (numberTypes,1)
%   Output:
%       -M: matrix M with values in g/s
[NyDim,NxDim] = size(N);
if NyDim ~= size(type,1)
    warning('column vector type is of wrong dimension')
end
M = zeros(NyDim,NxDim);
for i=1:NyDim
    particleType = type(i,1);
    % approximated volume of an particle of type particleType in m^3
    Volume = 4/3*pi*(radius(particleType)/1000)^3;
    % input mass flow in g/s
    M(i,:) = N(i,:)*1000*density(particleType)*Volume;
end


