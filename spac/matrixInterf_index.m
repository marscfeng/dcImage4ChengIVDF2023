% matrixInterf_index
%   apply seismic interferometry method on noise matrix
%       COR=Ub*conj(Ua)
%       COH = Ub*conj(Ua)/[|Ub|*|Ua|]
%       DeCov = Ub*conj(Ua)/[|Ua|*|Ua|]
%   note: virtual source is the conj one [A]
%
%   matrixInterf_index is upgrade version of matrixInterf with speedup
%        use Index to avoid duplicated FFT calculation
%   matrixInterf_index supports multiple virtual sources
%
% Usage
%   interfmethod = 'Coherence';
%   interftimespan =  'acausal+causal';
%   whiteNoise =2; 
%   tfpresent = 'temporal';
%   [interf_matrix, interf_tAxes, errlog] = matrixInterf_index(uxt, vsIndex_S, vsIndex_R, dt, ...
%       interfmethod, interftimespan, whiteNoise, tfpresent, hugeDataFlag, df);
%
% INPUT:
%   uxt, npts*ntrace matrix for noise matrix
%   vsIndex_S, nSRpair*1 vector for Index of virtual sources
%   vsIndex_R, nSRpair*1 vector for Index of virtual receivers
%   dt, time sampling step for A/B time series
%   interfmethod, 'Correlation'/'Coherence'/'Deconvolution'
%   interftimespan, temporal output 'causal'/'acausal'/'acausal+causal'
%   whiteNoise, white noise to normalize spectra division percent 100%
%   tfpresent, output 'temporal'/'spectral'/or'spac' SPAC coefficient
%   hugeDataFlag, control fft point to be reasonable small for huge data, default 0
%   df, control fft point with defined output frequency interval, default not design
%   twindow4acsp, limit time window for output acausal or causal spectra,
%       e.g., out spectra using only 4s from 10s causal lag
%           which will help surface wave dsp imaging
%
% OUTPUT:
%   interf_matrix, interferometric records
%   interf_tAxes, time axes or frequency axes
%   errlog, error log
%
% DEPENDENCES:
%
% AUTHOR:
%   F. CHENG ON mars-OSX.local
%
% UPDATE HISTORY:
%   Initial code, 22-Feb-2020
%   add normalization for spac coefficient calculation, 29-Mar-2020
%   add df to pre-design frequency resolution, 29-Mar-2020
%   replace fdata swap with deal function, 08-Apr-2020
%   update xcorr-spectrum to support separated acausal or causal lag, 20-Apr-2020
%   add twindow4acsp to control output spectra of separated acausal or causal lag, 20-Apr-2020
%   replace core xcorr algorithm using matrixInterf4finput function, 06-Jul-2020
%   add hugeDataFlag=2 option to manually set nf to a reasonable number, 10-May-2021
%
% SEE ALSO:
%   matrixInterf
% ------------------------------------------------------------------
%%
function [interf_matrix, interf_tAxes, errlog] = matrixInterf_index(uxt, vsIndex_S, vsIndex_R, dt, interfmethod, interftimespan, whiteNoise, tfpresent, hugeDataFlag, df, twindow4acsp)

interf_matrix = []; interf_tAxes = [];
% check spac
if strcmp(tfpresent,'spac') && ~strcmp(interfmethod,'Coherence')
    errlog = sprintf(...
        'Interferometry method should be Coherence rather than %s for SPAC output!',interfmethod);
    return
end
%
npts = size(uxt,1);
% avoid FFT further increase calculation burden
if exist('hugeDataFlag','var') && hugeDataFlag
    if hugeDataFlag == 1
        nf = ceil(npts/2)*2;
    elseif hugeDataFlag == 2
        nf = 2^14;
    end
else
    nf = max(2^nextpow2(npts), 1024);
end
%
if exist('df','var') && ~isempty(df)
    nf = max( ceil(1/dt/df/2)*2,  ceil(npts/2)*2 );
    % nf = ceil(1/dt/df/2)*2;
end
%
t = (0:npts-1)*dt;
[fdata, f] = fftrl(uxt,t,0.1,nf);
% free memory
clearvars uxt;
%
% separate receivers and sources
fdata1 = fdata(:, vsIndex_S(:));
fdata2 = fdata(:, vsIndex_R(:));
% call matrixInterf4finput for Interf using frequency domain wavefield
if ~exist('twindow4acsp', 'var')
    twindow4acsp = [];
end
[interf_matrix, interf_tAxes, errlog] = matrixInterf4finput(fdata1, fdata2, f, interfmethod, interftimespan, whiteNoise, tfpresent, twindow4acsp,t,nf);

% % in acausal case, replace receiver and source
% if strcmp(interftimespan, 'acausal')
%     [fdata1, fdata2] = deal(fdata2, fdata1);
% end
% %
% switch interfmethod
%     case 'Correlation'
%         % cross-correlation
%         fxy = (fdata2.*conj(fdata1));
%     case 'Coherence'
%         % cross-coherence
%         tmp = abs(fdata2).*abs(fdata1);
%         tmp_eps = whiteNoise/100 * mean (tmp);
%         fxy = (fdata2.*conj(fdata1))./(tmp + tmp_eps);
%     case 'Deconvolution'
%         % deconvolution
%         tmp = abs(fdata1).^2;
%         tmp_eps = whiteNoise/100 .* mean (tmp);
%         fxy = (fdata2.*conj(fdata1))./(tmp + tmp_eps);
%     otherwise
%         errlog = 'Unidentified interferometry method!';
%         return
% end
% % free memory
% clearvars fdata1 fdata2;
% %
% switch tfpresent
%     case 'temporal'
%         [txy, tt] = ifftrl(fxy, f);
%         switch interftimespan
%             case {'causal', 'acausal'}
%                 interf_matrix = txy(1:npts,:);
%                 interf_tAxes = tt(1:npts);
%             case 'acausal+causal'
%                 txy_ac = flipud(txy);
%                 tt_ac = -1*tt;
%                 interf_matrix = [txy_ac(npts-1:-1:1,:); txy(1:npts,:)];
%                 interf_tAxes = [col2row(tt_ac(npts:-1:2), 1); col2row(tt(1:npts),1)];
%             otherwise
%                 errlog = 'Unidentified interferometry time span, only support [causal, acausal, acausal+causal]!';
%                 return
%         end
%     case 'spectral'
%         switch interftimespan
%             case {'causal', 'acausal'}
%                 %
%                 if exist('twindow4acsp', 'var') && ~isempty(twindow4acsp)
%                     npts = round(twindow4acsp/dt);
%                     t = (0:npts-1)*dt;
%                 end
%                 %
%                 txy = ifftrl(fxy, f);
%                 uxt = txy(1:npts,:);
%                 [fxy, f] = fftrl(uxt,t,0.1,nf);
%                 interf_matrix = fxy;
%                 interf_tAxes = f;
%             case 'acausal+causal'
%                 %
%                 interf_matrix = fxy;
%                 interf_tAxes = f;
%             otherwise
%                 errlog = 'Unidentified interferometry time span, only support [causal, acausal, acausal+causal]!';
%                 return
%         end
%     case 'spac'
%         %
%         switch interftimespan
%             case {'causal', 'acausal'}
%                 %
%                 if exist('twindow4acsp', 'var') && ~isempty(twindow4acsp)
%                     npts = round(twindow4acsp/dt);
%                     t = (0:npts-1)*dt;
%                 end
%                 %
%                 txy = ifftrl(fxy, f);
%                 uxt = txy(1:npts,:);
%                 [fxy, f] = fftrl(uxt,t,0.1,nf);
%                 interf_matrix = real(fxy./abs(fxy));
%                 interf_tAxes = f;
%             case 'acausal+causal'
%                 %
%                 interf_matrix = real(fxy./abs(fxy));
%                 interf_tAxes = f;
%             otherwise
%                 errlog = 'Unidentified interferometry time span, only support [causal, acausal, acausal+causal]!';
%                 return
%         end
%     otherwise
%         errlog = 'Unidentified temporal/frequency presentation, only support [temporal, spectral, spac]!';
%         return
% end


end
