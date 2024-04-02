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
ord = 20;                  % LPC Order
windowOvlpTime = 0.0001;   % Hop size in seconds
windowLenTime = 0.005;     % Window length in seconds

hopSizeN = int32(floor((windowLenTime-windowOvlpTime)*fs)); % Hop size in number of samples
windowLenN = int32(floor(windowLenTime*fs)); % Window length in number of samples

%% Setup
numFrames = floor(length(audio)/hopSizeN) - 1;
window = hamming(windowLenN, 'periodic');

% Matrix of windowed autocorrelations
windowedAutocorrs = zeros(windowLenN, numFrames);

% Error signal and time-varying filter state
errorSig = zeros(size(audio));
filtState = zeros(ord, 1);

%% Main Processing Loop
% Compute windowed autocorrelation on each audio frame
for m = 1:numFrames
    % Get the start and stop index for this frame
    startIdx = (m-1)*hopSizeN + 1;
    stopIdx = (m-1)*hopSizeN + windowLenN;

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

% Generate the error signal by applying the time varying aCoeffs to the
% input audio
for m = 1:numFrames
    % Get the start and stop index for this frame
    startIdx = (m-1)*hopSizeN + 1;
    stopIdx = (m-1)*hopSizeN + windowLenN;

    localSig = audio(startIdx:stopIdx);
    [localErr, filtState] = filter(aCoeffs(m,:), 1, localSig, filtState);

    errorSig(startIdx:stopIdx) = localErr;
end

% Assign function outputs
nInterval = hopSizeN;
predGains = sqrt(errorVec);

end

