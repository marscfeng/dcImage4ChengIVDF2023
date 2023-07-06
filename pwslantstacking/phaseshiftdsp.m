% phaseshiftdsp
% 	kernel codes for phase-shift method for MASW based dispersion analysis
% 	scan multiple trace seismic data along specific frequency/velocity direction
%   Reference on Park et al., 1998, 2006; Cheng et al., 2016
%	use angle to do azimuth adjustment for directional noise data
% 	use lrFlag to do reverse direction velocity scanning
%
% Usage
% 	fv = phaseshiftdsp(fdata,x,f,v)
%   fv = phaseshiftdsp(fdata,x,f,v,angle,lrFlag,normFlag)
%
% INPUT:
%   fdata, 2D seismic data spectrum [nf, ntrace]
% 	f/v, scanning vector along frequency and velocity [nf]/[nv]
%   x, offset info [ntrace]
%   angle, azimuthal adjustment degree [0~180], default 0
%   lrFlag
%       lrFlag = 0, positive direction and negative direction
%       lrFlag = 1, positive direction, default 1
%       lrFlag =-1, negative direction
%   normFlag, frequency normalization 1/ 0 or not
%
% OUTPUT:
%   fv, 2D dispersion energy matrix [nv,nf]
%
% DEPENDENCES:
%
% AUTHOR:
%   F. CHENG ON mars-OSX.local
%
% UPDATE HISTORY:
%   Initial code, 29-Mar-2020
% 	add normalization option, 04-Apr-2020
%   add pwsFlag option, 10-May-2020
%   fix bug caused by complex domain calculation [nf, nx]
%    which are replaced with [nv, nx],01-Dec-2020
%
% SEE ALSO:
%   FPhaseshift, phaseshift2fk
% ------------------------------------------------------------------
%%
function fv = phaseshiftdsp(fdata,x,f,v, pwsFlag)
%%
% default do not apply azimuth adjustment
angle = 0;
%
if ~exist('pwsFlag','var') || isempty(pwsFlag)
    pwsFlag = 0;
end
% fdata = fdata./abs(fdata);
%
nf = length(f);
nv = length(v);
%
f=f(:);
v=v(:);
x=x(:)';
%
fv = zeros(nf,nv);
% --------
% cannot use this nv loop for PWS-phaseshift which will bring in
% bias, so I change it into nf loop to solve pws following the frequency axis
% this nf/nv loop has no effect on the original phaseshift
% --------
% tempfx = f*x;
% for i = 1:nv
%     exptemp = exp(1i*2*pi*tempfx/v(i)*abs(cos(angle/180*pi)));
%     if pwsFlag == 0
%         fv(:,i)=abs(sum(exptemp.*fdata,2));
%     else
%         % pws
%         fv(:,i) = abs(Fstack(exptemp.*fdata,pwsFlag,1));
%     end
% end
%%
if length(pwsFlag) == 2
    nuFlag = pwsFlag(2);
    pwsFlag = pwsFlag(1);
else
    nuFlag = 1;
end
tempvx = 1./v*x;
for i = 1:nf
    exptemp = exp(1i*2*pi*f(i)*tempvx*abs(cos(angle/180*pi)));
    % pws
    fv(i,:) = abs(Fstack(exptemp.*(ones(nv,1)*fdata(i,:)),pwsFlag,nuFlag));
end
%%
fv = fv.';


end