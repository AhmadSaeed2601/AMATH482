close all; clear all; clc;
%% Importing all images from directories (uncropped)
storagestan = [];
Dcy = dir("yalefaces");
for k = 3:length(Dcy)
    data = double(imread(strcat("yalefaces\", Dcy(k).name)));
    storagestan = [storagestan; reshape(data,1,243*320)];
end
%% Importing all images from directories (Cropped)

storagecrop = [];
Dcy = dir("CroppedYale");
for k = 1:length(Dcy)
   curD = Dcy(k).name;
   Dtemp = dir(strcat("CroppedYale\",curD, "\*.pgm"));
   
   for j = 1:length(Dtemp)
       data = double(imread(strcat("CroppedYale\",curD, "\", Dtemp(j).name)));
       storagecrop = [storagecrop; reshape(data,1,192*168)];
   end
end
%% Computation (cropped)
tic
[u,s,v] = svd(storagecrop', 'econ');
toc

%% Plotting and reconstrunction (cropped)
sig = diag(s);
lambda = sig.^2;

subplot(1,2,1)
plot(cumsum(lambda/sum(lambda)), 'bo')
refline(0,0.99)
legend("Energy Captured", "99% of Energy Captured", "Location", "Southeast");
ylabel("Cumulative Energy Captured by Diagonal Variances "); xlabel("Diagonal Variances");
title("Cumulative Energy Captured (Cropped)", "Fontsize", 14);
subplot(1,2,2)
plot(lambda/sum(lambda), 'ro')
set(gca, 'YScale', 'log')
ylim([10e-7, 1]); ylabel("Log of Energy Captured by Each Diagonal Variance"); xlabel("Diagonal Variances");
title("Log Of Energy Captured (Cropped)", "Fontsize", 14);
%% Eigen Faces
reconstruct = u(:,1:160) *s(1:160,:)*v(1:160,:)';
for z = 1:9
    curimg = reshape(reconstruct(:,z), [192,168]);
    subplot(3,3,z);
    pcolor(flip(curimg)), shading interp, colormap(gray)
end


%% NEW PART
tic
[u1,s1,v1] = svd(storagestan', 'econ');
toc

sig1 = diag(s);
lambda1 = sig1.^2;

reconstruct1 = u1(:,1:108) *s1(1:108,:)*v1(1:108,:)';
for z = 1:9
    curimg = reshape(reconstruct1(:,z), [243,320]);
    subplot(3,3,z);
    pcolor(flip(curimg)), shading interp, colormap(gray)
end

sig1 = diag(s1);
lambda1 = sig1.^2;

subplot(1,2,1)
plot(cumsum(lambda1/sum(lambda1)), 'bo')
refline(0,0.99)
legend("Energy Captured", "99% of Energy Captured", "Location", "Southeast");
ylabel("Cumulative Energy Captured by Diagonal Variances"); xlabel("Diagonal Variances");
title("Cumulative Energy Captured  (Uncropped)", "Fontsize", 14);
subplot(1,2,2)
plot(lambda1/sum(lambda1), 'ro')
set(gca, 'YScale', 'log')
ylim([10e-7, 1]); ylabel("Log of Energy Captured by Each Diagonal Variance"); xlabel("Diagonal Variances");
title("Log Of Energy Captured (Uncropped)", "Fontsize", 14);
