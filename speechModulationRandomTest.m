audioDir = './vocadito/Audio/';
audioFiles = dir(audioDir);
audioFiles = audioFiles(3:end);
avgNormError = 0;
avgDisc = 0;
avgNothingError = 0;
for i = 1:200
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
    nothingDiff = f0o - f0om;
    avgNormError = avgNormError + norm(diff(~isnan(diff)));
    avgNothingError = avgNothingError + norm(nothingDiff(~isnan(nothingDiff)));
    avgDisc = avgDisc + (nnz(f0om(~isnan(f0om)))/nnz(diff(~isnan(diff)))) + 1;
end
avgNormError = avgNormError/200;
avgDisc = avgDisc/200;
sprintf("The average norm error of the pitch before and after processing is %0.1f, compare this to if we did nothing at all, which would average an error of %0.1f",avgNormError,avgNothingError)
sprintf("The average percentage of pitch samples that could no longer be accurately pitch measured after processing was %0.1f%%",100*avgDisc)

function triplets = createModulationTriplets(t)
    mods = [.125, .25, .37, .5, .66, .75, 1, 1.25, 1.5, 1.66, 2, 2.5, 3, 5];
    numTriplets = randi([1, 10]);
    triplets = zeros(numTriplets, 3);
    
    for i = 1:numTriplets
        if i == 1
            startTime = rand * t*.5;
            endTime = startTime + .25 + rand * (t - startTime);
        else
            startTime = triplets(i - 1, 2) + rand * (t -  triplets(i - 1, 2))*1/(2*i);
            endTime = startTime + .25 + rand * (t - startTime);
        end
        if(endTime>t)
            endTime = t;
            if(endTime-startTime<.25)
                break;
            end
        end
        modulation = mods(randi(length(mods)));
        triplets(i, :) = [startTime, endTime, modulation];
    end
end
function moddedPitch = modifyExpectedPitch(pitch, fs, idx, triplets)
    time = idx / fs;
    moddedPitch = pitch;
    for f = 1:size(triplets,1)
        interval = find(time>=triplets(f,1),1):find(time<=triplets(f,2),1,'last');
        if(triplets(f,3)<=10)
            moddedPitch(interval) = moddedPitch(interval)*triplets(f,3);
        else
            moddedPitch(interval) = triplets(f,3);
        end
    end
end

