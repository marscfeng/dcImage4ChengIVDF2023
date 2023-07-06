% Fspac
%   determine phase velocity of surface wave by linear spatial autocorrelation method
%   error = Real<Ua*conj(Ub)/[|Us|*|Ub|]> - J0(k*R(ab))
%   Refer: Aki 1957 & Chavez-Garcia2006a
%   this subroutine aims to fast dispersion calculation for one time segment
%   which could be noise dataset or active surface wave shot gather
%
% Usage
%   [fv,f,v] = Fspac(uxt,x,t,normFlag,fmin,fmax,vmin,vmax)
%   [fv,f,v] = Fspac(uxt,x,t,normFlag,fmin,fmax,vmin,vmax,figure_handle,cutFlag,picFilename)
%   [fv,f,v] = Fspac(uxt,x,t,normFlag,fmin,fmax,vmin,vmax,figure_handle,cutFlag,picFilename,paralFlag, azmeanFlag, attenuaFlag)
%
% INPUT:
%   uxt, 2D seismic matrix [npts,ntrace]
%   x, 1D offset info [ntrace]
%   t, 1D time series
%   normFlag, frequency normalization 1/ 0 or not
%   fmin, interested frequency range minF
%   fmax, interested frequency range maxF
%   vmin, interested velocity range minV
%   vmax, interested velocity range maxV
%   figure_handle, optional flag for imaging 1/0, default 0
%   cutFlag, optional flag for cutoff rejection 1/0, default 0
%   picFilename, option filename for dispersion image, default time naming if figure_handle =1
%   paralFlag, option to open parallel for besselfit, default 1
%   azmeanFlag, option to do azimuthal average and speed calculation, default 1
%   attenuaFlag, option to apply attenuation coefficient, default 0
%
% OUTPUT:
%   f,v,fv, SPAC dispersion energy image
%
% DEPENDENCES:
%   besselfit_fv
%   matrixInterf_index
%
% AUTHOR:
%   F. CHENG ON mars-OSX.local
%
% UPDATE HISTORY:
%   Initial code, 20-Feb-2017
%   modify to support active-source dispersion imaging, 28-Nov-2018
%   function routine with matrixInterf_index and besselfit_fv, 29-Mar-2020
%
% SEE ALSO:
%   Fspac2fk
% ------------------------------------------------------------------
%%
function [fv,f,v] = Fspac(uxt,x,t,normFlag,fmin,fmax,vmin,vmax,figure_handle,cutFlag,picFilename,paralFlag, azmeanFlag, attenuaFlag)
%%
% remove dead traces
mtrace = mean(uxt, 1);
uxt = uxt(:, ~isnan(mtrace));
x = x(~isnan(mtrace));
%
nv = 500;
v = linspace(vmin,vmax,nv);
nf = 600;
f = linspace(fmin,fmax,nf);
df = mean(diff(f));
dt = mean(diff(t));
%%------------------------ CUT off frequency
[fdata0,f0] = fftrl(uxt,t,0.1,ceil(1/dt/df/2)*2);
% CAL cutoff frequency for FFTRL to avoid imaging alias
threshold = 99.7;
[fmin_cut,fmax_cut,famp] = cutFreq(fdata0,f0,threshold);
%
if exist('cutFlag','var') && cutFlag
    fmin = max(fmin, fmin_cut);
    fmax = min(fmax, fmax_cut);
end
%%------------------------ DO xcoh
interfmethod = 'Coherence';
tfpresent = 'spac';
interftimespan = 'causal';
whiteNoise = 2;
hugeDataFlag = 0;
% initial virtual source/receiver matrix
ntrace = length(x);
npairs = cn2(ntrace);
vsIndex_S = zeros(npairs, 1);
vsIndex_R = zeros(npairs, 1);
offset = zeros(npairs, 1);
index = 0;
for vsIndex=1:ntrace
    for j = vsIndex+1 : ntrace
        index = index+1;
        vsIndex_S(index) = vsIndex;
        vsIndex_R(index) = j;
        offset(index) = ABdist2D([x(vsIndex), 0], 1, [x(j), 0], 1);
    end
end
dt = mean(diff(t));
%
[fxcoh, f, errlog] = matrixInterf_index(uxt, vsIndex_S, vsIndex_R, dt, interfmethod, interftimespan, whiteNoise, tfpresent, hugeDataFlag, df);
%
if ~isempty(errlog)
    error(errlog);
end
indexf = between(fmin, fmax, f, 2);
fxcoh = real(fxcoh(indexf, :));
f = f(indexf);
%%------------------------ DO SPAC
if ~exist('paralFlag','var')
    paralFlag = 1;
end
if ~exist('azmeanFlag', 'var')
    azmeanFlag = 1;
end
if ~exist('attenuaFlag', 'var')
    attenuaFlag = 0;
end
[fv] = besselfit(fxcoh,f,v,offset, paralFlag, azmeanFlag, attenuaFlag);

%%------------------------ Spectral Normalization
if normFlag ==1
    fv=bsxfun(@rdivide, fv, max(abs(fv),[],1));
    fv=fv.^2;
end

fv(isnan(fv)) = 0;


%% ------------------------ Dispersion Imaging
if exist('figure_handle','var') && figure_handle
    strTag = 'SPAC';
    if ~exist('picFilename','var') || isempty(picFilename)
        picFilename = strcat('DspImg_',strTag,'_',gcdSTR,'.png');
    end
    famp = interp1(f0, famp, f);
    pltDSPIMG(f,v,fv,normFlag,figure_handle,x,famp,fmin_cut,fmax_cut,strTag, picFilename);
end
