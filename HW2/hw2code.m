clear all; close all; clc;

load handel
v = y'/2;
v(end) = [];
vt = fft(v);

%My code
L = 9; n = length(v);
t2 = linspace(0, L, n+1); t= t2(1:n);
k = (2*pi/L) * [0:n/2-1 -n/2:-1]; ks = fftshift(k);   

subplot(2,1,1)
plot(t,v);
xlabel('Time [sec]');
ylabel('Amplitude');
title('Signal of Interest, v(n)');

subplot(2,1,2)
plot(ks, abs(fftshift(vt)));


%Gaussian Window
tslide= 0:0.1:9;
spc = [];
spcsmallwindow = [];
spclargewindow = [];
spcmxhat = [];
spcshn = [];

figure(2)
for j=1:length(tslide)
    g = exp(-100*(t-tslide(j)).^2);
    gsm = exp(-1*(t-tslide(j)).^2);
    glg = exp(-1000*(t-tslide(j)).^2);
    
    omega = 0.05;
    mxhat = (2/ (sqrt(3*omega) * pi^(0.25))).* (1-((t-tslide(j))/omega).^2) .* exp(-((t-tslide(j)).^2)/(2 * omega^2));
    
    sig = 0.05;
    shn = abs(t-tslide(j)) <= sig/2;
    
    vg = g.*v;
    vgt = fft(vg);
    
    vgsm = gsm.*v;
    vgsmt =fft(vgsm);
    
    vglg = glg.*v;
    vglgt =fft(vglg);
    
    vmx = mxhat.*v;
    vmxt = fft(vmx);
    
    vshn = shn.*v;
    vshnt = fft(vshn);
    
%     subplot(2,1,1)
%     plot(t,v,'k-', t, mxhat, 'Linewidth', 2);
%     axis([0 9 -0.5 1])
%     
%     subplot(2,1,2)
%     plot(t,vg, 'Linewidth', 2);
%     axis([0 9 -0.4 0.4])
%     
    spc = [spc; abs(fftshift(vgt))];
    spcsmallwindow = [spcsmallwindow; abs(fftshift(vgsmt))];
    spclargewindow = [spclargewindow; abs(fftshift(vglgt))];
    spcmxhat = [spcmxhat; abs(fftshift(vmxt))];
    spcshn = [spcshn; abs(fftshift(vshnt))];
    pause(0.00001);
end

tslideover = 0:0.01:9;
spcover = []
for j=1:length(tslideover)
    g = exp(-200*(t-tslideover(j)).^2);
    vg = g.*v;
    vgt = fft(vg);
    
    spcover = [spcover; abs(fftshift(vgt))];
    pause(0.00001);
end

tslideunder = 0:1:9;
spcunder = []
for j=1:length(tslideunder)
    g = exp(-200*(t-tslideunder(j)).^2);
    vg = g.*v;
    vgt = fft(vg);
    
    spcunder = [spcunder; abs(fftshift(vgt))];
    pause(0.00001);
end

figure;
%frequency here?
pcolor(tslide,ks./(2*pi),spc.'), shading interp, colormap(hot)
xlabel("Time (s)");ylabel("Frequency (Hz)"); title("Normal sampling, normal window");

figure;
pcolor(tslide,ks./(2*pi),spcsmallwindow.'), shading interp, colormap(hot)
xlabel("Time (s)");ylabel("Frequency (Hz)"); title("Normal sampling, small window");

figure;
pcolor(tslide,ks./(2*pi),spclargewindow.'), shading interp, colormap(hot)
xlabel("Time (s)");ylabel("Frequency (Hz)"); title("Normal sampling, large window");

figure;
pcolor(tslide,ks./(2*pi),spcmxhat.'), shading interp, colormap(hot)
xlabel("Time (s)");ylabel("Frequency (Hz)"); title("Mexican Hat, omega = 0.05");

figure;
pcolor(tslide,ks./(2*pi),spcshn.'), shading interp, colormap(hot)
xlabel("Time (s)");ylabel("Frequency (Hz)"); title("Step Function (Shannon), sigma = 0.05");

figure;
pcolor(tslideover,ks./(2*pi),spcover.'), shading interp, colormap(hot)
xlabel("Time (s)");ylabel("Frequency (Hz)"); title("Oversampling");

figure;
pcolor(tslideunder,ks./(2*pi),spcunder.'), shading interp, colormap(hot)
xlabel("Time (s)");ylabel("Frequency (Hz)"); title("Undersampling");
