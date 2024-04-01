function ProcessSpeechAudio(audio,fs,modulationTriplets)
    audio = audio/max(audio);
    denoisedAudio = WienerScalart96(audio,fs);
    denoisedAudio = [denoisedAudio;zeros([length(audio)-length(denoisedAudio),1])];
    for i = 1:length(modulationTriplets(:,1))
        t1 = modulationTriplets(i,1);
        t2=modulationTriplets(i,2);
        macroBlock = audio(1+fs*t1:1+fs*t2);
        dnBlock = denoisedAudio(1+fs*t1:1+fs*t2);
        frames = buffer(macroBlock,.01*fs);
        dnFrames = buffer(dnBlock,.01*fs);
        for f = 1:size(frames,2)
            if(isVoiced(dnFrames(:,f)))
                f0 = fundamentalFrequencyCalc(frames(:,f));
                frames(:,f) = modulate(frames(:,f),f0,modulationTriplets(i,3));
            end
        end
        modBlock = frames(:);
        audio(1+fs*t1:1+fs*t2) = modBlock(1:length(macroBlock));
    end
end