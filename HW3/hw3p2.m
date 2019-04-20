clear all; close all; clc; 
load('cam1_2.mat')
load('cam2_2.mat')
load('cam3_2.mat')
%%
%Play Videos
numFrames1a =size(vidFrames1_2,4);
numFrames2a =size(vidFrames2_2,4);
numFrames3a =size(vidFrames3_2,4);

%%
for k = 1:numFrames1a
    mov1a(k).cdata = vidFrames1_2(:,:,:,k);
    mov1a(k).colormap = [];
end

%Play video
width = 50;
filter = zeros(480,640);
filter(300-2.6*width:1:300+2.6*width, 350-width:1:350+2*width) = 1;

data1 = [];
for j=1:numFrames1a
    X=frame2im(mov1a(j));
    
    Xabw = rgb2gray(X);
    X2 = double(X);
    
    Xabw2 = double(Xabw);
    Xf = Xabw2.*filter;
    thresh = Xf > 250;
    indeces = find(thresh);
    [Y, X] = ind2sub(size(thresh),indeces);
    
    data1 = [data1; mean(X), mean(Y)];
    
% subplot(1,2,1)
% imshow(uint8((thresh * 255))); drawnow
% subplot(1,2,2)
% imshow(uint8(Xf)); drawnow
end

%pause(5)
close all;
%%
for k = 1:numFrames2a
    mov2a(k).cdata = vidFrames2_2(:,:,:,k);
    mov2a(k).colormap = [];
end
width = 50;
filter = zeros(480,640);
filter(250-4*width:1:250+4.5*width, 290-2.5*width:1:290+2.7*width) = 1;

data2 = [];
%Play video
for j=1:numFrames2a
    X=frame2im(mov2a(j));
    
    Xabw = rgb2gray(X);
    X2 = double(X);
    
    Xabw2 = double(Xabw);
    Xf = Xabw2.*filter;
    thresh = Xf > 249;
    indeces = find(thresh);
    [Y, X] = ind2sub(size(thresh),indeces);
    
    data2 = [data2; mean(X), mean(Y)];
    
%     subplot(1,2,1)
%     imshow(uint8((thresh * 255))); drawnow
%     subplot(1,2,2)
%     imshow(uint8(Xf)); drawnow
end

%%
for k = 1:numFrames3a
    mov3a(k).cdata = vidFrames3_2(:,:,:,k);
    mov3a(k).colormap = [];
end

width = 50;
filter = zeros(480,640);
filter(250-1*width:1:250+2.6*width, 360-2.5*width:1:360+2.7*width) = 1;

data3 = [];
%Play video
for j=1:numFrames3a
    X=frame2im(mov3a(j));
    
    Xabw = rgb2gray(X);
    X2 = double(X);
    
    Xabw2 = double(Xabw);
    Xf = Xabw2.*filter;
    thresh = Xf > 246;
    indeces = find(thresh);
    [Y, X] = ind2sub(size(thresh),indeces);
    
    data3 = [data3; mean(X), mean(Y)];
    
%     subplot(1,2,1)
%     imshow(uint8((thresh * 255))); drawnow
%     subplot(1,2,2)
%     imshow(uint8(Xf)); drawnow
end

%%
[M,I] = min(data1(1:20,2));
data1  = data1(I:end,:);

[M,I] = min(data2(1:20,2));
data2  = data2(I:end,:);

[M,I] = min(data3(1:20,2));
data3  = data3(I:end,:);

%%
data2 = data2(1:length(data1), :);
data3 = data3(1:length(data1), :);

%% Method 2
alldata = [data1';data2';data3'];
%alldata = alldata';

[m,n]=size(alldata); % compute data sizea
mn=mean(alldata,2); % compute mean for each row
alldata=alldata-repmat(mn,1,n); % subtract mean

[u,s,v]=svd(alldata'/sqrt(n-1)); % perform the SVD
lambda=diag(s).^2; % produce diagonal variances

Y= alldata' * v; % produce the principal components projection

sig=diag(s);
%%
figure()
plot(1:6, lambda/sum(lambda), 'mo', 'Linewidth', 2);
title("Case 2: Energy of each Diagonal Variance");
xlabel("Diagonal Variances"); ylabel("Energy Captured");

figure()
subplot(2,1,1)
plot(1:295, alldata(2,:), 1:295, alldata(1,:),'Linewidth', 2)
ylabel("Displacement (pixels)"); xlabel("Time (frames)"); 
legend("Z", "XY")
title("Case 2: Original displacement across Z axis and XY-plane (cam 1)");
subplot(2,1,2)
plot(1:295, Y(:,1),1:295, Y(:,2),'r','Linewidth', 2)
ylabel("Displacement (pixels)"); xlabel("Time (frames)"); 
title("Case 2: Displacement across principal component directions");
legend("PC1", "PC2")