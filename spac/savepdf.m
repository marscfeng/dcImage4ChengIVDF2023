function savepdf(figure_handle,filename,res)
% savepdf
%   save current figure or figure_handle to hardcopy with export_fig
%
% Usage
%   savepdf(figure_handle,filename,ftype,path)
%
% INPUT:
%   figure_handle, figure number handle, 0 for current figure
%   filename, fullpath name of pictures
%
% OUTPUT:
%
% DEPENDENCES:
%
% AUTHOR:
%   F. CHENG ON mars-OSX.local
%
% UPDATE HISTORY:
%   Initial code, 09-Sep-2015
%   add figure_handle flag, 29-Nov-2017
%   modify argins with a fullfile filename, 18-Feb-2019
%   add res to control picture resolution, 06-Apr-2019
%   add warning suppress for export_fig, 06-Jul-2020
%   add '-silent' option to suppress warning, 17-Jun-2022
%   add opengl warning compression because silent mode doesn't do this job, 27-Jul-2022
% 
% ------------------------------------------------------------------
%%
warning('off','MATLAB:prnRenderer:opengl');
% 
if nargin < 1
    figure_handle = 0;
end
if nargin < 2
    filename=['Figure_',num2str(figure_handle),'_',gcdSTR,'.pdf'];
end
if nargin < 3
    res = 200;
end
res = ['-r',num2str(res)];
%
[picpath, filename, ftype] = fileparts(filename);

if isempty(picpath)
    picpath = './';
end

if isempty(figure_handle) || figure_handle == 0
    figure_handle=gcf;
end
figure(figure_handle)   % Make figure the current figure
filename = fullfile(picpath,[filename,ftype]);
% 
switch lower(ftype)
    case '.pdf'
        export_fig(filename,'-pdf', '-nofontswap', '-opengl',res,'-silent');
    case '.tif'
        export_fig(filename,'-tif','-transparent',res,'-silent');
    case '.eps'
        export_fig(filename,'-eps',res,'-silent');
    case '.png'
        export_fig(filename,'-png',res,'-silent');
    otherwise
        saveimg(figure_handle,filename,res);
end
% 

