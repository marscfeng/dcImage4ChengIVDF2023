% pltNyqwavL
%   Add Nyquist wavelength limitation on existing dispersion image
%   Only 1D linear array with even-sampling are considered
% 	f*2*dx defiens the maximum slowness
% 	f*N*dx defines the minimum slowness
% 	refer Forbriger et al., 2003
% 
% Usage
%   pltNyqwavL(f,fx)
% 
% INPUT:
%   f, 1D frequency series for the existing dispersion image
%   fx, 1D offset info for 1D linear arry
% 
% OUTPUT:
% 
% AUTHOR:
%   F. CHENG ON mars-OSX.local
% 
% UPDATE HISTORY:
%   Initial code, 12-Oct-2016
%   change ntrace*dx to fx(ntrace) to include minoffset, 07-Dec-2017
%   add sort for fx to prevent right side source, 06-Apr-2019
% 
% ------------------------------------------------------------------
%%
function pltNyqwavL(f,fx)
% keep fx increasing to prevent reverse shot
fx = sort(fx);
% 
dx = fx(2)-fx(1);
wavel = [2*dx fx(end)-fx(1)];
hold on
plot(f,f*dx,'b--','linewidth',2);
% plot(f,f*wavel(1),'b--','linewidth',2);
plot(f,f*wavel(2),'b--','linewidth',2);
hold off

end