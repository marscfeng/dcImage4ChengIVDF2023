function str = gcdSTR(nstr)
% gcdSTR
% 	get current date time with YYYYMMDDTHHMM format
% Usage:
% 	str = gcdSTR;
% INPUT:
% 	
% OUTPUT:
% 	str, string of current date time 
% DEPENDENCES:
% 	
% AUTHOR:
% 	F. CHENG ON mars-OSX.local

% UPDATE HISTORY:
% 	Initial code, 04-Dec-2017
% 	
% ------------------------------------------------------------------
%%

tempstr = datestr(now,30);
% 20171204T220959
% 123456789012345

if exist('nstr','var') && nstr>0
    str = tempstr;
else
    str = tempstr(1:13);
end
%%------------------------ 
