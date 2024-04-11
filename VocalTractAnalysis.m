function [aCoeffs, predGains, errorSig, nInterval, kCoeffs] = VocalTractAnalysis(audio, fs)
% VocalTractAnalysis: Analyzes an audio timeseries and outputs a matrix of 
% time-varying filter coefficients which can be used to model the 
% formant structure of the original audio. This implementation is largely
% based on my HW4 code, but has some modifications to make it more
% adjustable and easier to read.
%
% Author: Michael Seaborg
% Date: 04/01/2024
%
% Inputs:
%    audio  - The input audio timeseries (assumed mono)
%    fs     - The sample rate of the input audio in Hz
%
% Outputs:
%    aCoeffs    - Each row represents the LPC a-coefficients for a block of audio
%                   data at a certain point in time
%    predGains  - The prediction gain for each LPC analysis filter 
%    errorSig   - The prediction residual after applying aCoeffs to the
%                   input audio
%    nInterval  - The number of samples elapsed between each set of LPC
%                   coefficients (hop size)
%    kCoeffs    - The lattice reflection coefficient equivalents to 'aCoeffs'
%
%% Check inputs
% Make sure "audio" is a 1-dimensional vector
if(~isvector(audio))
    ME = MException('VocalTractAnalysis:BadAudioInput', 'Input audio must be a 1-D vector');
    throw(ME);
end

% Make sure fs is a scalar
if(~isscalar(fs))
    ME = MException('VocalTractAnalysis:BadFsInput', 'Fs must be a scalar');
    throw(ME);
end

%% Constants
ord = 15;                           % LPC Order
windowLenTime = 0.02;               % Window length in seconds
windowOvlpTime = 0.5*windowLenTime; % 50% Overlap

hopSizeN = int32(floor((windowLenTime-windowOvlpTime)*fs)); % Hop size in number of samples
windowLenN = int32(floor(windowLenTime*fs)); % Window length in number of samples

%% Setup
% Truncate the input to fit into an even number of frames
numFrames = 1 + floor( (length(audio)-windowLenN) / hopSizeN );

%floor(length(audio)/hopSizeN) - 1;
window = hamming(windowLenN, 'periodic');

% Matrix of windowed autocorrelations
windowedAutocorrs = zeros(windowLenN, numFrames);

% Error signal and time-varying filter state
errorSig = zeros(size(audio));

%% Main Processing Loop
% Compute windowed autocorrelation on each audio frame
for m = 1:numFrames
    % Get the start and stop index for this frame
    startIdx = (m-1)*hopSizeN + 1;
    stopIdx = min((m-1)*hopSizeN + windowLenN,length(audio));

    % Window this audio frame
    curAudioFrame = audio(startIdx:stopIdx);
    windowedAudio = window.*curAudioFrame;

    % Compute windowed autocorrelation
    [frameAutocorr, lag] = xcorr(windowedAudio, windowedAudio);
    frameAutocorr(lag<0) = []; % Remove negative lags (see MATLAB documentation for levinson)

    % Add the autocorrelation for this frame to the matrix
    windowedAutocorrs(:,m) = frameAutocorr;
end

% Compute levinson-durbin LPC coefficients for each frame using the matrix
% form of the levinson() function
[aCoeffs, errorVec, kCoeffs] = levinson(windowedAutocorrs, ord);

% Apply each filter to the entire input timeseries and switch the outputs
% to remove transients
% https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=735314
allErrOutputs = zeros(numFrames, length(errorSig));
for m = 1:numFrames
    % NOTE: This is WILDLY inefficient, but it works :)
    allErrOutputs(m, :) = filter(aCoeffs(m,:), 1, audio);
end

for m = 1:numFrames
    startIdx = (m-1)*hopSizeN + 1;
    stopIdx = startIdx + hopSizeN - 1;
    errorSig(startIdx:stopIdx) = (1.0/sqrt(errorVec(m)))*allErrOutputs(m,startIdx:stopIdx);
end

% Assign function outputs
nInterval = hopSizeN;
predGains = sqrt(errorVec);

end

