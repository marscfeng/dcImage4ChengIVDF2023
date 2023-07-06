% interp1_p2v
% 	apply 1D linear interpolation of 2d matrix along row direction
% 	like between velocity and slowness
% 	e.g., tp <-> tv, fp <-> fv
% 
% Usage:
%   [fv, v] = interp1_p2v(fp,p)
% 
% INPUT:
% 	fp, 2D matrix [np,nf]
%   p, 1D slowness [np]
% 
% OUTPUT:
% 	fv,  2D matrix [np,nf]
%   v, 1D velocity [np]
% 
% DEPENDENCES:
% 	
% AUTHOR:
% 	F. CHENG ON mars-OSX.local
% 	
% UPDATE HISTORY:
% 	Initial code, 02-Jan-2018
% 
% SEE ALSO:
% 	interp1_v2k
% ------------------------------------------------------------------
%%
function [fv, v] = interp1_p2v(fp, p)

%% transform fp to fv and linear interpolation
[np, nf] = size(fp);
% 
p2v = 1./p;
v = linspace(min(p2v),max(p2v),np);
fv  = zeros(np, nf);
for i = 1:nf
    fv( :,i) = interpnan(p2v(:), fp(:,i),v);
end