clear all; close all; clc;
    
%% Read in files (vid 1)
%Replace this with whatever movie to load in
vid1 = VideoReader('mov5.mp4');
dt = 1/vid1.Framerate;
t = 0:dt:vid1.Duration;
vidFrames = read(vid1);
numFrames = get(vid1,'numberOfFrames');
%% Load
for k = 1 : numFrames
    mov(k).cdata = vidFrames(:,:,:,k);
    mov(k).colormap = [];
end

fdata = [];
for j=1:numFrames
    X=frame2im(mov(j));
    
    fdata = [fdata, reshape(double(rgb2gray(imresize(X, 0.25))), [180*320,1])];
    %imshow(imresize(X, 0.25)); drawnow
end

%%  DMD
%%%%%% body of DMD %%%%%%%%%%
X1 = fdata(:,1:end-1); 
X2 = fdata(:,2:end);

[U,S,V] = svd(X1, 'econ');

subplot(1,2,1)
plot(diag(S)/sum(diag(S)), 'bo', 'Linewidth', 2, 'MarkerSize', 10, 'MarkerFaceColor', 'g');
title("Energies of Singular Values", 'Fontsize', 24); ylabel("Energy Captured"); xlabel("Singular Values");
grid on

r = 2;

U_r = U(:, 1:r); % truncate to rank-r
S_r = S(1:r, 1:r);
V_r = V(:, 1:r);
Atilde = U_r' * X2 * V_r / S_r; % low-rank dynamics
[W_r, D] = eig(Atilde);
Phi = X2 * V_r / S_r * W_r; % DMD modes

lambda = diag(D); % discrete-time eigenvalues
omega = log(lambda)/dt; % continuous-time eigenvalues

subplot(1,2,2)
bar(abs(omega), 'm')
title("Omega Values (Absolute Value)",'Fontsize', 24);
set(gca,'XTick',[]); xlabel("Omegas"); ylabel("Absolute Value of Omegas");
grid on
%% Compute DMD mode amplitudes b
x1 = X1(:, 1);
b = Phi\x1;

%% DMD reconstruction
mm1 = size(X1, 2); % mm1 = m - 1
time_dynamics = zeros(r, mm1);
t = (0:mm1-1)*dt; % time vector
for iter = 1:mm1,
time_dynamics(:,iter) = (b.*exp(omega*t(iter)));
end;
Xdmd = Phi * time_dynamics;

%% Create Sparse and Nonsparse

Xsparse = X1 - abs(Xdmd);

R = Xsparse.*(Xsparse<0);

X_bg = R + abs(Xdmd);
X_fg = Xsparse - R;

X_reconstructed =  X_fg + X_bg;

%% Display
temp1 = reshape(Xsparse, [180,320, length(t)]);
temp2 = reshape(Xdmd, [180,320,length(t)]);
temp3 = reshape(X_bg, [180,320,length(t)]);
temp4 =  reshape(X_fg, [180,320,length(t)]);
temp5 =  reshape(X_reconstructed, [180,320,length(t)]);
temp6 =  reshape(X1, [180,320,length(t)]);
temp7 = reshape(R, [180,320,length(t)]);

% implay(uint8(temp3));
% imshow(uint8(temp3(:,:,100)))
% imshow(uint8(temp3(:,:,100)))
% imshow(uint8(temp3(:,:,100)))

%% Plotting
figure()
framenum = 100;

subplot(2,3,1)
imshow(uint8(temp6(:,:,framenum)))
title("Original Video");

subplot(2,3,2)
imshow(uint8(temp1(:,:,framenum)))
title("Sparse Reconstruction (No R subtraction)");


subplot(2,3,3)
imshow(uint8(temp2(:,:,framenum)))
title("Low Rank Reconstruction (No R addition)");

subplot(2,3,6)
imshow(uint8(temp3(:,:,framenum)))
title("Low Rank Reconstruction (R addition)");

subplot(2,3,5)
imshow(uint8(temp4(:,:,framenum)))
title("Sparse Reconstruction (R subtraction)");

subplot(2,3,4)
imshow(uint8(temp5(:,:,framenum)))
title("Total Reconstruction (Sparse + Low Rank)");

sgtitle(strcat("Video 5 (Frame ", int2str(framenum), "): ", int2str(r)," Modes"), 'Fontsize', 20)