
function processedAudio = ProcessSpeechAudio(audio,fs,modulationTriplets)
% ProcessSpeechAudio - Takes in audio and modulation instructions and
% reconstructs the speech pitch according to the instructions.

% Inputs:
%    audio: Audio signal vector
%    fs: Sampling Rate
%    modulationTriplets: Modulation instructions where each row contains
%    [t1,t2,fmod] where t1 is the start time of the modulation, t2 is the
%    end time, and fmod is the frequency modulation factor or a specific
%    frequency to modulate to.

% Output:
%    processedAudio: Audio with modulation

% Note:
%   modulation process is implied to have a consistent fundamental
%   frequency across the modulation instruction, so the output across the
%   time interval(t1 to t2) will become monotonic if it wasn't already.
    audio = audio/max(audio);
    windowLen = floor(0.05*fs);
    hopSize = floor(0.5*windowLen);
    for i = 1:length(modulationTriplets(:,1))
        t1 = modulationTriplets(i,1);
        t2=modulationTriplets(i,2);
        fmod = modulationTriplets(i,3);
        aBlock = audio(1+fs*t1:1+fs*t2);
        %[aCoeffs, predGains, residual, nInterval, ~] = VocalTractAnalysis(aBlock, fs);
        f0_est = pitch(aBlock, fs, method="CEP", WindowLength=windowLen,OverlapLength=hopSize);
        m = findPitchMarks(aBlock, fs, f0_est, hopSize, windowLen);
        if(fmod>10)
            blockStretched = psola(aBlock, m, 1.0, fmod,true);
        else
            blockStretched = psola(aBlock, m, 1.0, fmod,false);
        end
       % modBlock = VocalTractSynthesis(residualStretched, aCoeffs, predGains, nInterval);
        audio(1+fs*t1:1+fs*t2) = blockStretched(1:length(aBlock));
        
    end
    processedAudio = audio;
    end
