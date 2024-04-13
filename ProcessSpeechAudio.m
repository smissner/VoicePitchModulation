
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
    for i = 1:length(modulationTriplets(:,1))
        t1 = modulationTriplets(i,1);
        t2=modulationTriplets(i,2);
        fmod = modulationTriplets(i,3);
        aBlock = audio(1+fs*t1:1+fs*t2);
        [aCoeffs, predGains, errorSig, nInterval, kCoeffs] = VocalTractAnalysis(aBlock, fs);
        excitation = zeros(length(aBlock),1);
        if(fmod<10)
            [period,g] = pitch_estimation_Long_term(aBlock);
            period = period*fmod;
        else
            period = fmod;
        end
        excitation(1:ceil(fs/period):end) = 1;
        modBlock = VocalTractSynthesis(excitation(1:length(errorSig)), aCoeffs, predGains, nInterval);
        audio(1+fs*t1:1+fs*t2) = modBlock(1:length(aBlock));
        
    end
    processedAudio = audio;
    end
