function saveimg(figure_handle,filename,res,crop,transparent)
% saveimg
%   save current figure or figure_handle to hardcopy
%
% Usage
%   saveimg(figure_handle,filename,ftype,path)
%
% INPUT:
%   figure_handle, figure number handle, 0 for current figure
%   filename, saved filename 'Figure_1.png'
%   res, picture resolution
%   crop, crop the blank border
%   transparent, save transparent pic
%
% OUTPUT:
%
% DEPENDENCES:
%   pdfcrop, ImageMagick
%
% AUTHOR:
%   F. CHENG ON mars-OSX.local
%
% UPDATE HISTORY:
%   Initial code, 08-Nov-2015
%   add emf/eps format; add figure_handle flag, 29-Nov-2017
%   defaulted file type be consisent with filename, 03-Jan-2018
%   add crop and transparent handle, 18-Apr-2018
%   add opengl warning compression, 27-Jul-2022
% ------------------------------------------------------------------
%%
warning('off','MATLAB:prnRenderer:opengl');
% 
sTenv;
if nargin < 1
    figure_handle = 0;
end
if figure_handle > 0
    figure_handle=figure(figure_handle);
else
    figure_handle = gcf;
end

if exist('filename','var')==0 || isempty(filename)==1
    filename=['Figure_',num2str(figure_handle),'_',gcdSTR,'.png'];
end

format=lower(filename(end-2:end));


if exist('res','var')==0 || isempty(res)==1
    res=300;
end

% if exist('autosize','var')==0 || isempty(autosize)==1
%     autosize=1;
% end

if exist('crop','var')==0 || isempty(crop)==1
    crop=1;
end

if exist('transparent','var')==0 || isempty(transparent)==1
    transparent=1;
end

if transparent == 0
    rend = '-zbuffer';
else
    rend = '-opengl';
end
% set(gcf, 'color','w')
matrelease=version('-release');
if str2double(matrelease(1:4))>2014
    figure_handle=get(figure_handle,'Number');
    if strcmpi(format,'fig')==1
        savefig(figure_handle,filename);
    elseif strcmpi(format,'pdf')==1
        print(['-f' num2str(figure_handle)],['-r',num2str(res)],['-d',format],...
            '-painters',[filename,'.tmp']);
        movefile([filename,'.tmp'],filename);
    elseif strcmpi(format,'jpg')==1
        print(['-f' num2str(figure_handle)],['-r',num2str(res)],'-djpeg',...
            rend,[filename,'.tmp']);
        movefile([filename,'.tmp'],filename);
    else
        print(['-f' num2str(figure_handle)],['-r',num2str(res)],['-d',format],...
            '-opengl',[filename,'.tmp']);
        movefile([filename,'.tmp'],filename);
    end
else
    if strcmpi(format,'fig')==1
        saveas(figure_handle,filename);
    elseif strcmpi(format,'pdf')==1
        print(['-f' num2str(figure_handle)],['-r',num2str(res)],['-d',format],...
            '-painters',[filename,'.tmp']);
        movefile([filename,'.tmp'],filename);
    elseif strcmpi(format,'jpg')==1
        print(['-f' num2str(figure_handle)],['-r',num2str(res)],'-djpeg',...
            rend,[filename,'.tmp']);
        movefile([filename,'.tmp'],filename);
    else
        print(['-f' num2str(figure_handle)],['-r',num2str(res)],['-d',format],...
            rend,[filename,'.tmp']);
        movefile([filename,'.tmp'],filename);
    end
end

if crop==1 && strcmpi(format,'fig')~=1
    if strcmpi(format,'pdf')==1
        unix(['pdfcrop --margins 10 ',filename,' ',filename]);
    else
        if isunix==1
            unix(['/opt/homebrew/bin/convert ',filename,' -trim ',filename]);
            unix(['/opt/homebrew/bin/convert ',filename,' -bordercolor White -border 50 ',filename]);
        else
            unix(['img_convert ',filename,' -trim ',filename]);
            unix(['img_convert ',filename,' -bordercolor White -border 50 ',filename]);
        end
    end
end