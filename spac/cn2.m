function cn2=cn2(ntrace)
% cal CN2 pair nums for cross-correlation
%
% Usage
%   cn2=cn2(ntrace)
%
% INPUT:
%   ntrace, trace number
%
% OUTPUT:
%   cn2 = ntrace*(ntrace-1)/2
%
% DEPENDENCES:
%   
%
% AUTHOR:
%   F. CHENG ON mars-OSX.local
%
% UPDATE HISTORY:
%   Initial code, 29-Jan-2019
%
% SEE ALSO:
%   
% ------------------------------------------------------------------
%%
%
cn2 = ntrace*(ntrace-1)/2 ; 
% %%
% index = 0;
% for i  = 1:ntrace-1
%     for j = i+1:ntrace
%         index = index+1;
%     end
% end