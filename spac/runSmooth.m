% runSmooth()
%   use medfilt1 to realize running meaning
%   flip two ends to extend the data for running mean
% 
% Usage
%   normSeis = runSmooth(dataSeis,nw,edgepadTag)
%
% INPUT:
%   dataSeis, [npts,numStack,ntrace] separated noise data 
%       the first dim should be averaged, dataSeis could be multiple dim
%   nw, length (sample num) of the running smooth window
%
% OUTPUT:
%   normSeis, smoothed noise data
%
% DEPENDENCES:
%
% AUTHOR:
%   F. CHENG ON mars-OSX.local
%
% UPDATE HISTORY:
%   Initial code, 25-Jul-2018
%   add size/reshape to adapt input for multiple dim (1D/2D/3D), 26-Jul-2018
%   major change by using medflilt1 to rebuild the code, 03-Apr-2019
% 
% SEE ALSO:
%   ramnorm; medfilt1
% 
% ------------------------------------------------------------------
%%
function normSeis = runSmooth(dataSeis, nw)
% 
if ~exist('edgeFlag','var')
edgepadTag = 'pad';
end
%  ----------------------------use size & reshape to adapt for multiple dim
sx = size(dataSeis); % [npts,numStack,ntrace] 
len = cumprod(sx); len = len(end);
sx1 = sx(1);
sx2 = len/sx(1);
dataSeis = reshape(dataSeis,sx1,sx2);
%  ----------------------------runSmooth
if sx1 < 2*nw+1
    logStr = sprintf('nw (%d) is too big, or npts (%d) is too small!',nw,sx1);
    error(logStr);
end
% padding the ends of the data
tmpSeis = [flipud(dataSeis(1:nw,:)); dataSeis; flipud(dataSeis(end-nw+1:end,:))];
% cal the running mean with medfilt1
tmpSeis = medfilt1(tmpSeis,nw,[],1);
% change index back
normSeis = tmpSeis(1+nw:end-nw,:);
%%  ----------------------------reshape back to the original dim
normSeis = reshape(normSeis, sx);

end