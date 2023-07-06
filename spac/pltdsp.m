% pltdsp
%   Plot Dispersion Energy Image or Curve on new or existing figure/subfigure
%
% Usage
%   pltdsp(f,v) % plot dsp curve on existing figure
%   pltdsp(f,v,fv) % plot dsp image on existing figure
%   pltdsp(f,v,fv,normFlag,[],offset) % plot dsp image on existing figure
%   pltdsp(f,v,fv,normFlag,figure_handle,offset)
%
% INPUT:
%   f, 1D frequency series [nf]
%   v, 1D velocity series [nv]
%   fv, 2D dispersion energy matrix [nv,nf]
%   normFlag, optional flag for frequency normalization 1/ 0 or not
%   figure_handle, optional flag for new figure numeric or [] hold on the current figure
%   offset, optional info as input for function pltNyqwavL
%
% OUTPUT:
%
% DEPENDENCES:
%   1. deSample2d
%   2. Figure
%   3. rwb
%
% AUTHOR:
%   F. CHENG ON mars-OSX.local
%
% UPDATE HISTORY:
%   Initial code, 05-Jan-2016
%   add optional info for Nyquist Wavlen limitation, 14-Oct-2016
%   add quick imaging option, 01-Jan-2018
%   add Figure with an existing figure_handle, 14-Mar-2018
%   add function for 1D dispersion curve plot, 07-May-2018
%   add exist function to support optional vargin, 29-Mar-2020
%   add fkFlag to support fk domain dispersion spectra, 05-Apr-2020
% 
% ------------------------------------------------------------------
%%
function dspfig = pltdsp(f,v,fv,normFlag,figure_handle,offset,fkFlag)
% 
if exist('figure_handle', 'var') && ~isempty(figure_handle)
    Figure(figure_handle);
    set(gcf,'Units','normalized','Position',[0.2 0.2 0.4 0.4]);
end
% 
if exist('fv', 'var') && ~isempty(fv)
    % quick imaging
%     [f,v,fv]=deSample2d(f,v,fv);
    %
    if exist('normFlag', 'var') && normFlag == 1
        fv = bsxfun(@rdivide, fv, max(abs(fv),[],1));
    end
    % 
    dspfig=imagesc(f,v,fv);
    set(dspfig,'CDataMapping','scaled') 
    set(dspfig,'alphadata',~isnan(fv))
    colormap(gca, whitejet3)
%     colormap(gca, rwb)
    % colorbar('EastOutside');
else
    plot(f,v,'k','LineWidth',2);
end

axis xy
xlabel('Frequency (Hz)');
ylabel('Phase velocity (m/s)');
setplt
% fkFlag indicate fv/v/f are fk spectra
if exist('fkFlag', 'var') && fkFlag
    xlabel('Frequency (Hz)');
    ylabel('Wavenumber (1/m)');
    setplt
    return
end
% title(datestr(now))
if exist('offset','var') && numel(offset) > 1
    pltNyqwavL(f,offset)
end

end


