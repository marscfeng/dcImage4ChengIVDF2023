% FPhaseshift
%   Calculate the dispersion image based on phase-shift method
%   Reference on Park et al., 1998
% 	and the phase weighted slantstacking technique
% 	refer to Cheng et al., 2021. GJI.
%
% Usage
%   [fv,f,v]=FPhaseshift(uxt,x,t,normFlag,fmin,fmax,vmin,vmax)
%   [fv,f,v]=FPhaseshift(uxt,x,t,normFlag,fmin,fmax,vmin,vmax,pwsFlag)
%
% INPUT:
%   uxt, 2D seismic matrix [npts,ntrace]
%   x, 1D offset info [ntrace]
%   t, 1D time series [npts]
%   normFlag, frequency normalization 1/ 0 or not
%   fmin, interested frequency range minF
%   fmax, interested frequency range maxF
%   vmin, interested velocity range minV
%   vmax, interested velocity range maxV
%   pwsFlag, optional pws flag for imaging 1 or not 0
%
% OUTPUT:
%   fv, 2D dispersion energy matrix [nv,nf]
%   f, 1D frequency series [nf]
%   v, 1D velocity series [nv]
%
% DEPENDENCES:
%   1. fftrl, between, mwindow
%   2. cutFreq
%   3. pltDSPIMG
%
% AUTHOR:
%   F. CHENG ON mars-OSX.local
%
% UPDATE HISTORY:
%   Initial code, 22-Mar-2015
%   vectorization, 07-Apr-2015
%   use fftrl replace fft, 31-May-2015
%   add cutoff frequency to limit frequency range, 30-Jun-2017
%   add log file bakup, 09-Sep-2017
%   add figure_handle check, 28-Mar-2018
%   remove ph due to ph = fdata/|fdata|, 21-Aug-2018
%   change x from x-x(1) to x, 01-Nov-2018
%   add nf_800 to ensure the output frequency (around 800) not too short, 21-Jan-2020
%   add picFilename option to save dspimg, 31-Jan-2020
% 	add pwsFlag to clear the incoherent noise, 10-May-2020
%   remove dead traces, 09-Aug-2021
% ------------------------------------------------------------------
%%
function [fv,f,v]=FPhaseshift(uxt,x,t,normFlag,fmin,fmax,vmin,vmax,pwsFlag)
%% 
% remove dead traces
mtrace = mean(uxt, 1);
uxt = uxt(:, ~isnan(mtrace));
x = x(~isnan(mtrace));
%%------------------------ initial parameters
nv = 600;
v = linspace(vmin,vmax, nv);
nf = 1000;
f = linspace(fmin, fmax, nf);
df = mean(diff(f));
dt = mean(diff(t));
nf = ceil(1/dt/df/2)*2;
% 
npts = size(uxt,1);
nf = max(nf, ceil(npts/2)*2);
%%------------------------ FFT
% 
[fdata,f] = fftrl(uxt,t,0.1,nf);
% 
fdata = fdata./abs(fdata);
% 
indexf = between(fmin,fmax,f,2);
f = f(indexf);
fdata = fdata(indexf,:);
% 
%%------------------------ Phase Shift
% 
if ~exist('pwsFlag','var') || isempty(pwsFlag)
	pwsFlag = 0;
end
% 


fv = phaseshiftdsp(fdata,x,f,v,pwsFlag);
%

%%------------------------ Spectral Normalization
if normFlag ==1
    fv=bsxfun(@rdivide, fv, max(abs(fv),[],1));
end

fv(isnan(fv)) = 0;


