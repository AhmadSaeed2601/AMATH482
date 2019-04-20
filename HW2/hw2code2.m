close all; clear all; clc;

pia=(audioread('music1.wav')).'; 
% plot((1:length(pia))/Fs,pia);
% xlabel('Time [sec]'); ylabel('Amplitude');
% title('Mary had a little lamb (piano)'); drawnow

Lpia=16;  % record time in seconds%
n = length(pia);
Fspia=length(pia)/Lpia;
t2 = linspace(0, Lpia, n+1); tpia= t2(1:n);
kpia = (2*pi/Lpia) * [0:n/2-1 -n/2:-1]; kspia = fftshift(kpia); 
tslidepia = 0:0.2:16;

spcpia = [];
pianotes = [];
for j=1:length(tslidepia)
    g = exp(-100*(tpia-tslidepia(j)).^2);
    
    vgpia = g.*pia;
    vgpiat = fft(vgpia);
    [M,I] = max(vgpiat);
    
    pianotes = [pianotes; abs(kpia(I))/(2*pi)];
    spcpia = [spcpia; abs(fftshift(vgpiat))];
end

%figure(2)
rec=(audioread('music2.wav')).'; 
% plot((1:length(rec))/Fs,rec);
% xlabel('Time [sec]'); ylabel('Amplitude');
% title('Mary had a little lamb (recorder)');

Lrec=14;  % record time in seconds
Fsrec=length(rec)/Lrec;
n = length(rec);
t2 = linspace(0, Lrec, n+1); trec= t2(1:n);
krec = (2*pi/Lpia) * [0:n/2-1 -n/2:-1]; ksrec = fftshift(krec); 
tsliderec = 0:0.2:16;

spcrec = [];
recnotes = [];
for j=1:length(tsliderec)
    g = exp(-100*(trec-tsliderec(j)).^2);
    
    vgrec = g.*rec;
    vgrect = fft(vgrec);
    
    [M,I] = max(vgrect);
    recnotes = [recnotes; abs(krec(I))/(2*pi)];
    
    spcrec = [spcrec; abs(fftshift(vgrect))];
end

% figure;
% 
subplot(2,1,1)
pcolor(tslidepia,(kspia/(2*pi)),spcpia.'), shading interp
xlabel("Time (s)");ylabel("Frequency (Hz)"); title("Piano");
ylim([0 400])
subplot(2,1,2)
pcolor(tsliderec,ksrec/(2*pi),spcrec.'), shading interp, colormap(hot)
xlabel("Time (s)");ylabel("Frequency (Hz)"); title("Recorder");
ylim([600 1000])

plot(tslidepia,pianotes,'o','MarkerFaceColor', 'b');
yticks([246.9417,261.6256,277.1826,293.6648,311.127,329.6276,349.2282]);
yticklabels({'B3','C4','C#4','D4','E4','F4'});
ylim([246 350])
title("Score for Piano Music (~250-350Hz");
xlabel("Time (s)"); ylabel("Notes corresponding to frequency (Hz)");

plot(tsliderec,recnotes,'o', 'MarkerFaceColor', 'b')
yticks([698.4565,739.9888,783.9909,830.6094,880,932.3275]);
yticklabels({'F5','F#5','G5','G#5','A5','A#5'});
ylim([680 950])
title("Score for Recorder Music (~680-950Hz)");
xlabel("Time (s)"); ylabel("Notes corresponding to frequency (Hz)");