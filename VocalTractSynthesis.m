function y = VocalTractSynthesis(excitation, aCoeffs, hopLen)
% VocalTractSynthesis - Implements a time-varying all-pole lattice filter
% which operates on the excitation signal. Largely taken and modified from 
% my HW4 code.
%
% Author: Michael Seaborg
% Date: 04/02/2024
%
% Inputs:
%    excitation     - The excitation signal to be input to the time-varying
%                       filter
%    aCoeffs        - A matrix containing the time-varying lattice coefficients
%    hopLen         - The "hop distance" between each entry of aCoeffs as a
%                       number of samples
%
%    NOTE: It may be simpler to have this function intuit the hop length
%    from the length of the excitation input.
%
% Outputs:
%    y              - The resynthesized audio 
%
%% Check inputs
% hopLen must be a scalar
if( ~isscalar(hopLen) || (hopLen <= 0) )
    ME = MException('VocalTractSynthesis:BadHopLenInput', 'Hop length must be a positive scalar');
    throw(ME);
end

% aCoeffs must be a matrix with lpcOrd < numFrames
numFrames = size(aCoeffs, 1);
lpcOrd = size(aCoeffs, 2);
if( (~ismatrix(aCoeffs)) || (lpcOrd > numFrames) )
    ME = MException('VocalTractSynthesis:BadFilterCoeffs', 'aCoeffs must be MxN where M is the frame index, and N is the lpc order');
    throw(ME);
end

% excitation must be a 1-D vector
if( ~isvector(excitation) )
    ME = MException('VocalTractSynthesis:BadExcitationSig', 'The excitation signal must be a 1-D vector');
    throw(ME);
end

%% Loop Setup

%% Main Processing Loop



end

