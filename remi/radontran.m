% radontran
%   radon transform to convert xt to fp
%
% Usage
% 	[fp, f, p] = radontran(uxt,x,t,1/500, 1/100, 100) % forward
% 	[fp, f, p] = radontran(uxt,x,t,-1/500, -1/100, 100) % backward
%   [fp, f, p] = radontran(uxt,x,t,1/500, 1/100, 100,df)
%
% INPUT:
%   uxt, 2D seismic matrix [npts,ntrace]
%   x, 1D offset info [ntrace]
%   dt, time step
%   pmin/pmax/np, interested slowness series [np]
% 	df, potential output frequency interval
%
% OUTPUT:
%   fp, 2D dispersion energy matrix [np,nf]
%   f, 1D frequency series [nf]
% 	p, 1D slowness series [np]
%
% DEPENDENCES:
%   fftrl
%
% AUTHOR:
%   F. CHENG ON mars-OSX.local
%
% UPDATE HISTORY:
%   Initial code, 04-Apr-2020
% 	add normalization option, 04-Apr-2020
% 	modify nf setting to make sure sufficient nfft, 08-Apr-2020
%
% SEE ALSO:
% 	Ftaup/remi
% ------------------------------------------------------------------
%%

function [fp, f, p, tp, t, tpMat] = radontran(uxt,x,dt,pmin,pmax,np,df,normFlag)
%
[npts, ntrace] = size(uxt);
t = (0:npts-1)*dt;
%
p = linspace(pmin, pmax, np);
% negative p
if pmin <= 0
	p = -1*linspace(abs(pmin), abs(pmax), np);
end
p = col2row(p, 1);
% --------------------------- slant-stacking
tp = zeros(np*npts, 1);
tpMat= zeros(np*npts, ntrace);
uxt_nmo = zeros(npts+1,ntrace);     % add one more element for exceed npts+1
uxt_nmo(1:npts,:) = uxt;
for i=1:ntrace
    nmo_Index = round(bsxfun(@plus,x(i)*p,t)/dt);
    nmo_Index( nmo_Index > npts ) = npts+1;
    nmo_Index( nmo_Index < 1 ) = npts+1;
%     tp = tp + uxt_nmo(nmo_Index,i);
    tpMat(:,i) = uxt_nmo(nmo_Index,i);
end
% 
tp = Fstack(tpMat, 0);
% 
tp = reshape( tp, np, npts);
% series code for tau-p / slant-stacking
% 
% tp=zeros(npts,np);
% for i = 1:np
%     for j = 1:npts
%         for k = 1:ntrace
%             t0 = t(j)+p(i)*x(k);
%             idx = round(t0/dt);
%             if idx <= npts && idx > 0
%                 tp(j,i) = tp(j,i)+uxt(idx,k);
%             end
%         end
%     end   
% end
% --------------------------- fft
%
if exist('df','var') && ~isempty(df)
    nf = max( ceil(1/dt/df/2)*2, ceil(npts/2)*2 ); % insufficient NFFT will cause some issues during imaging
else
    nf = ceil(npts/2)*2;
end
%
[fp,f] = fftrl(tp.',t,0.1, nf);
fp = abs(fp).';

%%------------------------ Spectral Normalization
if exist('normFlag','var') && normFlag
    fp=bsxfun(@rdivide, fp, max(abs(fp),[],1));
    fp=fp.^2;
end

fp(isnan(fp)) = 0;


end