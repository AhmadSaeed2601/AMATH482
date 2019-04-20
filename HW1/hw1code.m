clear all; close all; clc;
load Testdata

L=15; % spatial domain
n=64; % Fourier modes

x2=linspace(-L,L,n+1); x=x2(1:n); y=x; z=x;
k=(2*pi/(2*L))*[0:(n/2-1) -n/2:-1]; ks=fftshift(k);
[X,Y,Z]=meshgrid(x,y,z);
[Kx,Ky,Kz]=meshgrid(ks,ks,ks);

figure
Un(:,:,:)=reshape(Undata(20,:),n,n,n);
isosurface(X,Y,Z,abs(Un), 0.75)
axis([-20 20 -20 20 -20 20]), grid on, drawnow
xlabel("x"), ylabel("y"), zlabel("z")
title("Ultrasound in 3-D space (20th measurement)")

Undatashape = reshape(Undata, [20,n,n,n]);
Ut= fftn(Undatashape);
avg = zeros(64,64,64);
for p = 1:20
    avg(:,:,:) = avg + abs(reshape(Ut(p,:),n,n,n));
end
avg = avg./20;
avg = abs(avg)/max(abs(avg(:)));

figure
isosurface(Kx,Ky,Kz,fftshift(avg), 0.725)
axis([-10 10 -10 10 -10 10]), grid on, drawnow
xlabel("Kx"), ylabel("Ky"), zlabel("Kz")
title("Normalized Sum of Fourier Transformed Ultrasound Data")

avgshift = fftshift(avg);
[maximum, index] = max(avgshift(:));

[ii,jj,ll] = ind2sub([n,n,n], index);

cx = ks(jj); cy = ks(ii); cz = ks(ll);
%%
fwid = -0.01;
filter = exp(fwid*(Kx - cx).^2 +fwid*(Ky - cy).^2 + fwid*(Kz - cz).^2);

for j=1:20
    Uncur(:,:,:)= reshape(Ut(j,:),n,n,n);
    filterall(j,:,:,:) = ifftshift(filter).*Uncur;
    close all, isosurface(Kx,Ky,Kz,abs(fftshift(Utfn)), 0.5)
    axis([-20 20 -20 20 -20 20]), grid on, drawnow
end

figure;
Undenoise = ifftn(filterall);
for j = 1:20 
    Unslice(:,:,:)= reshape(Undenoise(j,:),n,n,n);
    Unslice = abs(Unslice)/max(abs(Unslice(:)));
    [maximum, index] = max(abs(Unslice(:)));
    [ii,jj,ll] = ind2sub([n,n,n], index);
    plotdata(j,:) = [X(ii,jj,ll),Y(ii,jj,ll),Z(ii,jj,ll)];
    isosurface(X,Y,Z,abs(Unslice), 0.6)
    axis([-20 20 -20 20 -20 20]), grid on, drawnow
end
xlabel("x"), ylabel("y"), zlabel("z")
title("Denoised Ultrasounds in Space");

figure;
plot3(plotdata(:,1), plotdata(:,2), plotdata(:,3), "Linewidth", 1.5)
axis([-15 15 -10 10 -15 15]), grid on, drawnow
xlabel("x"), ylabel("y"), zlabel("z")
title("Marble Path in Space");

point = plotdata(20,:)