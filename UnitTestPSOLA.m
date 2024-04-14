%% Unit Test PSOLA
% Unit test for the PSOLA functions
% Author: Michael Seaborg
% Date: 04/13/2024

%% First, prove this out on a synthetic signal
% Generate a fake periodic signal
f0 = 100;
fs = 44100;
dur = 1;
numEpochs = int32(f0*dur);
ff = f0*ones(numEpochs, 1); % Frequency of each epoch
nn = int32(fs./ff);     % Fundamental period in samples of each epoch
xx = zeros(sum(nn), 1); % Final vector whose length in samples is the sum of all the number of samples of the epochs
for ii=1:numEpochs
    % Place a kronecker delta at the start of each pitch epoch
    xx(sum(nn(1:ii)))=1; %xx is the excitation
end

% Run pitch estimation on it
windowLen = 0.02*fs;
hopSize = 0.01*fs;
f0 = pitch(xx,fs,Method="CEP",WindowLength=windowLen,OverlapLength=hopSize);
figure(1);
subplot(2, 1, 1);
plot(xx);
subplot(2, 1, 2);
plot(f0);

% Get pitch marks
m = findPitchMarks(xx, fs, f0, hopSize, windowLen);
m_compare = zeros(length(xx), 1);
m_compare(m') = 1.0;
figure(2);
plot(xx);
hold on;
plot(m_compare);
hold off;

% Run PSOLA
out = psola(xx, m, 1.0, 1.25)';
figure(3);
subplot(2, 1, 1);
plot(xx);
subplot(2, 1, 2);
plot(out);

% Get the pitch of the output sequence
f0_out = pitch(out, fs, method="CEP", WindowLength=windowLen,OverlapLength=hopSize);
figure(4);
subplot(2, 2, 1);
plot(xx);
subplot(2, 2, 2);
plot(out);
subplot(2, 2, 3);
plot(f0);
subplot(2, 2, 4);
plot(f0_out);

%% Next, try it out on a raw audio segment


%% Finally, try it out on an LPC residual signal