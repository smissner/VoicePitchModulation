function y = VocalTractSynthesis(excitation, aCoeffs, predGains, hopLen)
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
%    predGains      - A vector containing the prediction gain for each set
%                       of aCoeffs
%    hopLen         - The "hop distance" between each entry of aCoeffs as a
%                       number of samples
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
y = zeros(size(excitation));

%% Main Processing Loop
% Apply each filter to the entire input timeseries and switch the outputs
% to remove transients
% https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=735314
allSynthOutputs = zeros(numFrames, length(excitation));
for m = 1:numFrames
    % NOTE: This is WILDLY inefficient, but it works
    allSynthOutputs(m, :) = filter(predGains(m), aCoeffs(m,:), excitation);
end

for m = 1:numFrames
    startIdx = (m-1)*hopLen + 1;
    stopIdx = startIdx + hopLen - 1;
    y(startIdx:stopIdx) = allSynthOutputs(m,startIdx:stopIdx);
end

end

