function processedAudio = ProcessSpeechAudio(audio,fs,modulationTriplets)
    audio = audio/max(audio);
   % denoisedAudio = WienerScalart96(audio,fs);
    %denoisedAudio = [denoisedAudio;zeros([length(audio)-length(denoisedAudio),1])];
    for i = 1:length(modulationTriplets(:,1))
        t1 = modulationTriplets(i,1);
        t2=modulationTriplets(i,2);
        aBlock = audio(1+fs*t1:1+fs*t2);
       % dnBlock = denoisedAudio(1+fs*t1:1+fs*t2);
        [aCoeffs, predGains, errorSig, nInterval, kCoeffs] = VocalTractAnalysis(aBlock, fs);
        excitation = pitchmoving(aBlock,modulationTriplets(i,3));
        modBlock = VocalTractSynthesis(excitation, aCoeffs, predGains, nInterval);
        audio(1+fs*t1:1+fs*t2) = modBlock(1:length(aBlock));
    end
    processedAudio = audio;
end