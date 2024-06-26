function processedAudio = ProcessSpeechAudioWithLPC(audio,fs,modulationTriplets)
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
    audio = audio/max(audio);
    windowLen = floor(0.05*fs);
    hopSize = floor(0.5*windowLen);
    for i = 1:length(modulationTriplets(:,1))
        t1 = modulationTriplets(i,1);
        t2=min(modulationTriplets(i,2),length(audio));
        fmod = modulationTriplets(i,3);
        aBlock = audio(1+round(fs*t1):round(fs*t2));
        if(isempty(aBlock))
            break;
        end
        [aCoeffs, predGains, residual, nInterval, ~] = VocalTractAnalysis(aBlock, fs);
        f0_est = pitch(aBlock, fs, method="CEP", WindowLength=windowLen,OverlapLength=hopSize);
        m = findPitchMarks(residual, fs, f0_est, hopSize, windowLen);
        if(fmod>10)
            blockStretched = psola(residual, m, 1.0, fmod,true);
        else
            blockStretched = psola(residual, m, 1.0, fmod,false);
        end
        modBlock = VocalTractSynthesis(blockStretched, aCoeffs, predGains, nInterval);
        audio(1+round(fs*t1):round(fs*t2)) = modBlock(1:length(aBlock));
        
    end
    processedAudio = audio;
    end
