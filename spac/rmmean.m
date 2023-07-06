function normSeis = rmmean(dataSeis)
% rmmean()
%   remove mean, aim for active surface waves 
%
% Usage
%   normSeis = rmmean(dataSeis,pre)
%
% INPUT:
%   dataSeis, [npts,numStack,ntrace] or [npts,numStack] or [npts] separated noise data 
%       the first dim should be averaged, dataSeis could be multiple dim
%
% OUTPUT:
%   normSeis, normalized noise data
%
% DEPENDENCES:
%
% AUTHOR:
%   F. CHENG ON mars-OSX.local
%
% UPDATE HISTORY:
%   Initial code, 29-Mar-2020
%
% SEE ALSO:
%   rmtrend
% ------------------------------------------------------------------
%%
%  ---------------------------- use size & reshape to adapt for multiple dim
sx = size(dataSeis); % [npts,numStack,ntrace] 
len = cumprod(sx); len = len(end);
sx1 = sx(1);
sx2 = len/sx(1);
dataSeis = reshape(dataSeis,sx1,sx2);
%  ---------------------------- remove mean
% 
normSeis =  dataSeis - ones(sx1,1)*mean(dataSeis,1);
%  ----------------------------reshape back to the original dim
normSeis = reshape(normSeis, sx);