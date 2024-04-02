%% Unit Test Vocal Tract Analysis
% Unit testing for the VocalTractAnalysis function
% Author: Michael Seaborg
% Date: 04/01/2024

%% Test error conditions
testGoodFs = 44100;
testGoodAudio = sin(2*pi*(1000/testGoodFs)*(0:1:44100));
testBadFs = [1, 2];
testBadAudio = [testGoodAudio; testGoodAudio];

% Check behavior for bad input arguments
try
    [a, g, err, n] = VocalTractAnalysis(testGoodAudio, testBadFs);
catch ME
    fprintf('Error caught: %s, %s\n', ME.identifier, ME.message);
end

try
    [a, g, err, n] = VocalTractAnalysis(testBadAudio, testGoodFs);
catch ME
    fprintf('Error caught: %s, %s\n', ME.identifier, ME.message);
end

clear;

%% Run VocalTractAnalysis on a test input
% Load test audio and prune to about 5 seconds
[testAudio, fs] = audioread('vocadito/Audio/vocadito_1.wav');
testAudio = testAudio(1:10*fs);

% Run the VocalTractAnalysis function
[a, g, err, n] = VocalTractAnalysis(testAudio, fs);

% Plot outputs
set(0, 'DefaultFigureWindowStyle', 'docked');

% Figure 1: Original Audio and LPC Error Signal
t = ((1:1:length(testAudio))-1)./fs;
figure(1);
subplot(2, 1, 1);
plot(t, testAudio);
subplot(2, 1, 2);
plot(t, err);
linkaxes(get(gcf, 'Children'), 'x');

% Figure 2: Original Audio WB spectrogram and LPC spectrum
figure(2);
subplot(2, 1, 1);
spectrogram(testAudio, hamming(200), 20, 1024, fs, 'yaxis');
title('Original Audio WB Spectrogram')
ylim([0 5]);
subplot(2, 1, 2);
lpc_spectrum_matrix = zeros(size(a,2), 1024);
for m = 1:length(g)
    [h, f] = freqz(g(m), a(m, :), 1024, fs);
    lpc_spectrum_matrix(m, :) = mag2db(abs(h));
end
t = ((0:n:(size(a, 2)*n))./fs)';
t = t(1:(end-1));
imagesc(t, f/1000, lpc_spectrum_matrix');
title('LPC Spectrogram');
ylabel('Frequency (kHz)');
xlabel('Time (s)');
ylim([0 5]);
axis xy;
colorbar;