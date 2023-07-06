% 
% a MATLAB script to illustrate
% 
%   Phase-weighted slant stacking for surface wave dispersion measurement
%   developed by F. Cheng, 
%   
%   for details of the algorithm, please refer our paper
% 
%   Cheng, F., Xia, J., Zhang, K., Zhou, C., & Ajo-Franklin, J. B. (2021). 
%       Phase-weighted slant stacking for surface wave dispersion measurement. 
%       Geophysical Journal International, 226(1), 256–269. 
%       https://doi.org/10.1093/gji/ggab101
% 
% 
clear;clc;close all
load('synthetic-seismic-data.mat','uxt','t','x');
%
figure(1);clf
imagesc(x,t,uxt)
xlabel('Offset (m)')
ylabel('Time (sec)')
%
normFlag = 1;
fmin = 10;
fmax = 100;
vmin = 50;
vmax = 800;
%
[fv,f,v]=FPhaseshift(uxt,x,t,normFlag,fmin,fmax,vmin,vmax,0);
[fv2]=FPhaseshift(uxt,x,t,normFlag,fmin,fmax,vmin,vmax,1);

%% 
figure(2);clf
subplot(1,2,1)
imagesc(f,v,fv);
axis xy
colormap(gca, jet)
xlabel('Frequency (Hz)')
ylabel('Phase velocity (m/s)')
title('RAW')
subplot(1,2,2)
imagesc(f,v,fv2);
axis xy
colormap(gca, jet)
xlabel('Frequency (Hz)')
ylabel('Phase velocity (m/s)')
title('PWS')
