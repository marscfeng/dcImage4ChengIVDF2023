% remi
%   REMI method to obtain dispersion curves from noise shot gather
%   Refer Louie 2001;
%         McMechan and Yedlin, 1981
%
% Usage
%   [fv,f,v] = remi(uxt,x,dt,fmin,fmax,vmin,vmax,lrFlag,fkFlag)
%
% INPUT:
%   uxt, 2D seismic matrix [npts,ntrace]
%   x, 1D offset info [ntrace]
%   dt, time step
%   fmin, interested frequency range minF
%   fmax, interested frequency range maxF
%   vmin, interested velocity range minV
%   vmax, interested velocity range maxV
%   lrFlag
%       0, positive direction and negative direction
%       1, positive direction, default 1
%       -1, negative direction
%   fkFlag, optional output fk domain spectra, default 0
%
% OUTPUT:
%   fv, 2D dispersion energy matrix [nv,nf]
%   f, 1D frequency series [nf]
%   v, 1D velocity series [nv]
%
% DEPENDENCES:
%   radontran
%   interp1_p2v
%
% AUTHOR:
%   F. CHENG ON mars-OSX.local
%
% UPDATE HISTORY:
%   Initial code, 02-Jun-2016
%   update with vectorization speed, 29-Mar-2020
%   add fkFlag to output fk domain spectra, 05-Apr-2020
%
% SEE ALSO:
%   Ftaup
% ------------------------------------------------------------------
%%
function [fv,f,v] = remi(uxt,x,dt,fmin,fmax,vmin,vmax,lrFlag, fkFlag)
% tic
% 
% remove dead traces
mtrace = mean(uxt, 1);
uxt = uxt(:, ~isnan(mtrace));
x = x(~isnan(mtrace));

% default choose forward/right-going direction
if ~exist('lrFlag','var') || isempty(lrFlag)
    lrFlag = 1;
end
% --------------------- initial work space
nf = 600;
f = linspace(fmin, fmax, nf);
df = mean(diff(f));
%
np = 500;
pmin = 1/vmax;
pmax = 1/vmin;
%
%---------------------- tau-p slant-stacking / FFT
switch lrFlag
    case 1
        % forward direction p>0
        [fp, f, p] = radontran(uxt,x,dt,pmin,pmax,np,df);
    case -1
        % inverse direction p<0
        [fp, f, p] = radontran(uxt,x,dt,-pmin,-pmax,np,df);
    case 0
        %
        [fp1,f,p] = radontran(uxt,x,dt,pmin,pmax,np,df);
        %
        [fp2] = radontran(uxt,x,dt,-pmin,-pmax,np,df);
        %
        fp = fp1+fp2;
    otherwise
        error('lrFlag can only be 1/-1/0 indicating forward/backward/bidirectional!');
end
% 
indexf = between(fmin,fmax,f,2);
f = f(indexf);
fp = fp(:, indexf);
% transform fp to fv and linear interpolation
if ~exist('fkFlag', 'var') || fkFlag == 0
    [fv, v] = interp1_p2v(fp, p);
else
    f = col2row(f, 1);
    p = col2row(p, 2);
    nf = length(f);
    np = length(p);
    p2k = f*p;
    k = linspace(min2(p2k),min(max2(p2k), 1./mean(diff(x))),np);
    fk  = zeros(np, nf);
    for i = 1:nf
        fk(:,i) = interp1(p2k(i,:), fp(:,i), k);
    end
    % 
    v = k;
    fv = fk;
end

