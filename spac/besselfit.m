% besselfit
%   kernel calculation for SPAC method, match xcoh spectra real part with Beseelj function
%   determine phase velocity of surface wave
%
% Usage
%   [fv] = besselfit(fxcoh,f,v,x)
%   [fv] = besselfit(fxcoh,f,v,x, paralFlag, azmeanFlag, attenuaFlag)
%   [fv] = besselfit(fxcoh,f,v,x, paralFlag, azmeanFlag, attenuaFlag, BesselJ)
%   [fv] = besselfit(fxcoh,f,v,x, paralFlag, azmeanFlag, attenuaFlag, BesselJ, 1) % fit complex xcoh
%
% INPUT:
%   fxcoh, real part spectra of xcoh [nf, ntrace]
%   f, frequency vector for xcoh spectra [nf]
%   v, interested velocity scanning series [nv]
%   x, offset vector for xcoh matrix [ntrace]
%   paralFlag, open parallel 1 or not 0, default 0
%   azmeanFlag, apply azimuth average 1 or not, default 0
%   attenuaFlag, apply attenuation coefficient 1 or not, default 0
%   BesselJ, pre-measured besselj matrix [nf, ntrace, nv], default empty
%   mspacFlag, open modified SPAC function or not
%
% OUTPUT:
%   fv, output dispersion spectrum [nv, nf]
%
% DEPENDENCES:
%
% AUTHOR:
%   F. CHENG ON mars-OSX.local
%
% UPDATE HISTORY:
%   Initial code, 07-Nov-2015
%   update codes with paralFlag, azmeanFlag, attenuaFlag options, 29-Mar-2020
%   add option to pre-calculate BesselJ matrix for speedup, 04-Apr-2020
%   remove the power order (2) for misfit error, 08-Apr-2020
%   add mspacFlag to support the modified SPAC function, 17-Jun-2022
%
% SEE ALSO:
%
% ------------------------------------------------------------------
%%

function [fv] = besselfit(fxcoh,f,v,x, paralFlag, azmeanFlag, attenuaFlag, BesselJ, mspacFlag)
% initial matrix space
nf = length(f);
nv = length(v);
ntrace = length(x);
% check real part xcoh spectra
if ~exist('mspacFlag', 'var')
    mspacFlag = 0;
end
%
if ~mspacFlag && ~isreal(fxcoh)
    error('input xcoh spectra should only conclude real part!');
end
% check vector/matrix size
if ~isequal([nf, ntrace], size(fxcoh))
    error('conflicted input parameters size: nf=%d ntrace=%d size(fxcoh)=[%d %d]!', ...
        nf, ntrace, size(fxcoh,1), size(fxcoh,2));
end
%
if exist('paralFlag', 'var') && paralFlag
    paralCorenum = Inf;
else
    paralCorenum = 0;
end

%% do azimuth average could be ignored, since the results will be smoother without azimuthal average
if exist('azmeanFlag', 'var') && azmeanFlag
    R = unique(x);
    ntrace = length(R);
    %
    spacCoef = zeros(nf,ntrace);
    for i = 1:ntrace
        spacCoef(:,i) = mean(fxcoh(:, x == R(i)),2);
    end
    x = R;
else
    spacCoef = fxcoh;
end
%
f = col2row(f, 1);
x = col2row(x, 2);

%% cal BesselJ matrix
if ~exist('BesselJ','var') || isempty(BesselJ)
    BesselJ = zeros(nf,ntrace,nv);

    % BESSEL FUNCTION CALCULATING ...
    parfor (i = 1:nv, paralCorenum)
        %     for i = 1:nv
        tmp = 2*pi*f*x/v(i);
        tmp(tmp < 0.5) = 0.5;
        %         tmp1 = besselj(0, tmp);
        %         tmp2 = bessely(0, tmp); tmp2(tmp2<-0.5) = -0.5;
        %         BesselJ(:,:,i) = tmp1 - 1j*tmp2;
       
            % BesselJ(:,:,i) = besselj(zeros(nf,ntrace), tmp);
            BesselJ(:,:,i) = besselj(zeros(nf,ntrace), tmp) - 1j*besselh(zeros(nf,ntrace), 2, tmp);
            % BesselJ(:,:,i) = besselh(zeros(nf,ntrace), 1, tmp);

    end
end

%%

% Matching Bessel function with Observed C-Coh Spectra
if exist('attenuaFlag', 'var') && attenuaFlag
    attenua = 0.1:0.1:1;
else
    attenua = 1;
end
nattenua = length(attenua);
fvERR = cell(nattenua,1);
fvERRTol = zeros(nattenua,1);
%
for irun = 1:nattenua
    %
    fverr = zeros(nv,nf);
    alpha = attenua(irun);
    parfor (i = 1:nv, paralCorenum)
        temp = alpha*BesselJ(:,:,i) - spacCoef;
        fverr(i, :) = transpose(rms(temp,2));
    end
    fvERRTol(irun) = sum(min(fverr,[],1));
    fvERR{irun} = fverr;
end
[~,index] = min(fvERRTol);
fverr = fvERR{index};
%
fv = (1./fverr);
% fv = max(fverr(:))*1.2 - (fverr);
fv(isnan(fv)) = 0;

end
