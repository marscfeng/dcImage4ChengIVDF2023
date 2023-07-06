% col2row
%   Switch row vectors to column ones with flag =2, vice versa with flag =1
% 
% Usage
%   s=col2row(s,flag)
% 
% INPUT:
%   s [N]
%   flag, 1 to ensure N*1 or 2 to ensure 1*N
% 
% OUTPUT:
%   s [N]
% 
% DEPENDENCES:
% 
% AUTHOR:
%   F. CHENG ON mars-OSX.local
% 
% UPDATE HISTORY:
%   Initial code, 31-May-2015
%   use .' to avoid conjugate for complex matrix, 09-Nov-2016
% 	update row/column detector with isrow/iscolum, rather size, 01-Apr-2020
% 
% ------------------------------------------------------------------
%%
function s=col2row(s,flag)
% 
if flag == 1
    %switch to column vectors
    if ~iscolumn(s); s = s.'; end
else
    %switch to row vectors
    if ~isrow(s); s = s.'; end
end