audioDir = './vocadito/Audio/';
audioFiles = dir(audioDir);
audioFiles = audioFiles(3:end);
avgNormError = 0;
avgDisc = 0;
for i = 1:10000
    file = randsample(audioFiles,1);
    [x,fs] = audioread([audioDir,file.name]);
    winLength = round(0.2*fs);
    overlapLength = round(0.1*fs);
    [f0o,idx] = pitch(x,fs,Method="SRH",WindowLength=winLength,OverlapLength=overlapLength);
    hro = harmonicRatio(x,fs,Window=hamming(winLength,"periodic"),OverlapLength=overlapLength);
    f0o(hro<.8)=nan;
    triplets = createModulationTriplets(length(x)/fs);
    randomlyModifiedAudio = ProcessSpeechAudio(x,fs,triplets);
    f0om = modifyExpectedPitch(f0o,fs,idx,triplets);
    [f0m,idxm] = pitch(randomlyModifiedAudio,fs,Method="SRH",WindowLength=winLength,OverlapLength=overlapLength);
    hrm = harmonicRatio(randomlyModifiedAudio,fs,Window=hamming(winLength,"periodic"),OverlapLength=overlapLength);
    f0m(hrm<.8)=nan;
    diff = f0m - f0om;
    avgNormError = avgNormError + norm(diff(~isnan(diff)));
    avgDisc = avgDisc + (nnz(f0om(~isnan(f0om)))-nnz(diff(~isnan(diff))));
end
avgNormError = avgNormError/10000;
avgDisc = avgDisc/10000;
sprintf("The average norm error of the pitch before and after processing is %0.4f",avgNormError);
sprintf("The average number of pitch samples that could no longer be accurately pitch measured after processing was %0.1f",avgDisc);

function triplets = createModulationTriplets(t)
    mods = [.125, .25, .37, .5, .66, .75, 1, 1.25, 1.5, 1.66, 2, 2.5, 3, 5];
    numTriplets = randi([1, 10]);
    triplets = zeros(numTriplets, 3);
    
    for i = 1:numTriplets
        if i == 1
            startTime = rand * t*.5;
            endTime = startTime + rand * (t - startTime);
        else
            startTime = triplets(i - 1, 2) + rand * (t -  triplets(i - 1, 2))*1/(2*i);
            endTime = startTime + rand * (t - startTime);
        end
        
        modulation = mods(randi(length(mods)));
        triplets(i, :) = [startTime, endTime, modulation];
    end
end

function moddedPitch = modifyExpectedPitch(pitch, fs, idx, triplets)

    moddedPitch = zeros(size(pitch));
    
    normalizedValues = idx / fs;
    
    [~, tripletIndices] = max(normalizedValues >= triplets(:, 1) & normalizedValues <= triplets(:, 2), [], 2);
    
    validIndices = tripletIndices > 0;
    moddedPitch(validIndices) = pitch(validIndices) .* triplets(tripletIndices(validIndices), 3);
    
    unmatchedIndices = ~validIndices;
    moddedPitch(unmatchedIndices) = pitch(unmatchedIndices);
end
