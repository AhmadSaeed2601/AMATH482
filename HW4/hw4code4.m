close all; clear all; clc;

%% Import audio files
alldata = [];
Alabels = [];
for str = {"pop", "rock", "motown"}
    for i = 1:5
        [song, Fs] = audioread(strcat("Music\",str{1}, num2str(i),".mp3"));
        Fs = Fs/10;

        %Lower sampling rate
        song = song(1:10:end,:);
        
        monosong = [];
        %Convert from stereo to mono
        for z = 1:length(song)
            if (song(z,1) == 0 || song(z,2) == 0)
                monosong(z,1) = max(song(z,:));
            else
                monosong(z,1) = (song(z,1) + song(z,2))/2;
            end
        end


        %Remove leading and trailing 0s
        monosong = monosong(find(monosong,1,'first'):find(monosong,1,'last'));

        %5 second intervals
        chunk_size = Fs*5;

        endpoint = floor(length(monosong) / chunk_size);
        monosong = monosong(1:(chunk_size * endpoint),1);

        data = reshape(monosong, [chunk_size, endpoint]);
        alldata = [alldata, data];
        Alabels = [Alabels; repmat(str{1}, size(data,2) ,1)];
    end
end
Alabels = Alabels.';
traindata = alldata;
trainlabels = Alabels;
%% Rearrange and apply fft
[u,s,v] = svd(abs(fft(alldata)), 'econ');
trainlabels = Alabels;

sig = diag(s);
lambda = sig.^2;

utrunc = u(:, 1:239);
traindata = utrunc'*alldata;

n = floor(size(traindata, 2)/(8));
c = randperm(size(traindata,2), n);
    
testdata = traindata(:,c);
testlabels = trainlabels(:,c);

traindata(:,c) = [];
trainlabels(:,c) = [];

nosvdtraindata = abs(fft(alldata));
nosvdtestdata = nosvdtraindata(:,c);
nosvdtraindata(:,c) = [];
%% Modeling
nbMdl = fitcnb(traindata.', trainlabels);
nbL = loss(nbMdl, testdata.', testlabels)

%Cross validation model
nbcvMdl = fitcnb(traindata.', trainlabels, 'crossval', 'on');
nbcvL = kfoldLoss(nbcvMdl,'LossFun','ClassifErr')

svmMdl = fitcecoc(traindata.', trainlabels);
svmL = loss(svmMdl, testdata.', testlabels)

%Cross validation model
svmcvMdl = fitcecoc(traindata.', trainlabels, 'crossval', 'on');
svmcvL = kfoldLoss(svmcvMdl,'LossFun','ClassifErr')

rfMdl = fitctree(traindata.', trainlabels);
rfL = loss(rfMdl, testdata.', testlabels)

%Cross validation model
rfcvMdl = fitctree(traindata.', trainlabels, 'crossval', 'on');
rfcvL = kfoldLoss(rfcvMdl,'LossFun','ClassifErr')

%% Modeling (no SVD)
nosvdnbMdl = fitcnb(nosvdtraindata.', trainlabels);
nosvdnbL = loss(nosvdnbMdl, nosvdtestdata.', testlabels)

%Cross validation model
nosvdnbcvMdl = fitcnb(nosvdtraindata.', trainlabels, 'crossval', 'on');
nosvdnbcvL = kfoldLoss(nosvdnbcvMdl,'LossFun','ClassifErr')

nosvdsvmMdl = fitcecoc(nosvdtraindata.', trainlabels);
nosvdsvmL = loss(nosvdsvmMdl, nosvdtestdata.', testlabels)

%Cross validation model
nosvdsvmcvMdl = fitcecoc(traindata.', trainlabels, 'crossval', 'on');
nosvdsvmcvL = kfoldLoss(nosvdsvmcvMdl,'LossFun','ClassifErr')

nosvdrfMdl = fitctree(nosvdtraindata.', trainlabels);
nosvdrfL = loss(nosvdrfMdl, nosvdtestdata.', testlabels)

%Cross validation model
nosvdrfcvMdl = fitctree(nosvdtraindata.', trainlabels, 'crossval', 'on');
nosvdrfcvL = kfoldLoss(nosvdrfcvMdl,'LossFun','ClassifErr')

%% Plotting
close all;

bar(1-[nbL nbcvL nosvdnbL nosvdnbcvL; svmL svmcvL nosvdsvmL nosvdsvmcvL; rfL rfcvL nosvdrfL nosvdrfcvL])
xticklabels(["Naive Bayes", "Support Vector Machine", "Random Forests"]);
legend("SVD, No Cross Validation", "SVD, Cross Validation", "No SVD, No Cross Validation", "No SVD, Cross Validation");
ylabel("Classification Accuracy (Scale of 0 to 1)"); xlabel("Supervised Learning Algorithms");
title("Test 3: Accuracy of Trained Models of Three Genres (239 Modes)", 'FontSize', 20);
grid on
%% Loop
tic
classify= []
for z = 1:25:size(u,2)
    trunc = u(:, 1:z);
    traindata = utrunc'*alldata;
    trainlabels = Alabels;
    
    n = floor(size(traindata, 2)/(8));
    c = randperm(size(traindata,2), n);
    
    testdata = traindata(:,c);
    testlabels = trainlabels(:,c);
    traindata(:,c) = [];
    trainlabels(:,c) = [];
    
    nbMdl = fitcnb(traindata.', trainlabels);
    nbcvMdl = fitcnb(traindata.', trainlabels, 'crossval', 'on');

    svmMdl = fitcecoc(traindata.', trainlabels);
    svmcvMdl = fitcecoc(traindata.', trainlabels, 'crossval', 'on');

    rfMdl = fitctree(traindata.', trainlabels);
    rfcvMdl = fitctree(traindata.', trainlabels, 'crossval', 'on');
    
    classify= [classify; loss(nbMdl, testdata.', testlabels) , kfoldLoss(nbcvMdl,'LossFun','ClassifErr'), ...
                       loss(svmMdl, testdata.', testlabels), kfoldLoss(svmcvMdl,'LossFun','ClassifErr'), ...
                        loss(rfMdl, testdata.', testlabels), kfoldLoss(rfcvMdl,'LossFun','ClassifErr')];
                    
end
toc

%% Plot bigger stuff
close all;

subplot(1,2,1)
plot(1:25:size(u,2), 1-classify, "Linewidth", 2)
title("Test 3: Model Accuracy vs Number of Modes", "Fontsize", 20);
xlabel("Number of Modes"); ylabel("Accuracy (Scale of 0 to 1)");
refline(0,0.5)
legend("Naive Bayes", "Naive Bayes (Cross Validation)", "SVM", "SVM (Cross Validation)", ...
    "Random Forests", "Random Forests (Cross Validation)","50% Accuracy Mark", "Location", "Southwest");

subplot(1,4,3)
plot(cumsum(lambda/sum(lambda)), 'bo')
refline(0,0.95)
legend("Energy Captured", "95% of Energy Captured", "Location", "Southeast");
ylabel("Cumulative Energy Captured by Diagonal Variances"); xlabel("Diagonal Variances");
title("Cumulative Energy Captured", "Fontsize", 14);
subplot(1,4,4)
plot(lambda/sum(lambda), 'ro')
set(gca, 'YScale', 'log')
ylim([10e-5, 1]); ylabel("Log of Energy Captured by Each Diagonal Variance"); xlabel("Diagonal Variances");
title("Log Of Energy Captured", "Fontsize", 14);