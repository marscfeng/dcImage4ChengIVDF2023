% matrixInterf4finput
%   apply seismic interferometry method on frequency domain noise matrix
%       COR=Ub*conj(Ua)
%       COH = Ub*conj(Ua)/[|Ub|*|Ua|]
%       DeCov = Ub*conj(Ua)/[|Ua|*|Ua|]
%   note: virtual source is the conj one [A]
%
%   matrixInterf4finput is basic algorithm for matrixInterf (frequency xcorr/xcoh/decov)
%
% Usage
%   interfmethod = 'Coherence';
%   interftimespan =  'acausal+causal';
%   waterLevel =2; 
%   tfpresent = 'temporal';
%   [interf_matrix, interf_tAxes, errlog] = matrixInterf4finput(fdata_vs, fdata_vr, f,...
%        interfmethod, interftimespan, whiteNoise, tfpresent, twindow4acsp, t)
%
% INPUT:
%   fdata_vs, npts*ntrace matrix for noise matrix of virtual sources
%   fdata_vr, npts*ntrace matrix for noise matrix of virtual receivers
%   f, frequency axis, like fdata, they only contains oneside fft spectra
%   interfmethod, 'Correlation'/'Coherence'/'Deconvolution'
%   interftimespan, temporal output 'causal'/'acausal'/'acausal+causal'
%   whiteNoise, white noise to normalize spectra division percent 100%
%   tfpresent, output 'temporal'/'spectral'/or'spac' SPAC coefficient
%   twindow4acsp, limit time window for output acausal or causal spectra, 
%       e.g., out spectra using only 4s from 10s causal lag 
%           which will help surface wave dsp imaging 
%   t, time axis of input/output temporal wavefield
%   nf, fft sampling number used for input fdata which is only necessary for spectra/spac output
% 
% OUTPUT:
%   interf_matrix, interferometric wavefield
%   interf_tAxes, time axes or frequency axes
%   errlog, error log
%
% DEPENDENCES:
%
% AUTHOR:
%   F. CHENG ON mars-OSX.local
%
% UPDATE HISTORY:
%   Initial code, 06-Jul-2020
%   add eps to avoid dividing 0, 12-Dec-2020
%   add option to zeropadding ifftrl txy when nf < npts, 10-May-2021
%   add whiten option into Coherence and decov, 17-Nov-2021
%
% SEE ALSO:
%   matrixInterf
% ------------------------------------------------------------------
%%
function [interf_matrix, interf_tAxes, errlog] = matrixInterf4finput(fdata_vs, fdata_vr, f, interfmethod, interftimespan, whiteNoise, tfpresent, twindow4acsp, t, nf)
% 
interf_matrix = []; 
interf_tAxes  = [];
errlog        = [];
% check spac
if strcmp(tfpresent,'spac')
    if ~strcmp(interfmethod,'Coherence')
        errlog = sprintf(...
            'Interferometry method should be Coherence rather than %s for SPAC output!',interfmethod);
        return
    end
end
% in acausal case, replace receiver and source
if strcmp(interftimespan, 'acausal')
    [fdata_vs, fdata_vr] = deal(fdata_vr, fdata_vs);
end
%
switch interfmethod
    case 'Correlation'
        % cross-correlation
        fxy = (fdata_vr.*conj(fdata_vs));
    case 'Coherence'
        % cross-coherence
        tmp = abs(fdata_vr).*abs(fdata_vs);
        %
        if strcmp(whiteNoise, 'runSmooth')
            % apply runSmooth whiten
            hw = max(ceil(size(tmp, 1)*0.005/2),2);
            %
            lw = runSmooth(tmp, 2*hw);
            % avoid lw to be zero
            [indx, indy] = find(lw == 0);
            if ~isempty(indx) && ~isempty(indy)
                whiteNoise = 2;
                lw_eps = whiteNoise/100 .* mean (lw,1);
                lw(indx, indy) = lw(indx, indy) + ones(length(indx),1)*lw_eps(indy);
            end
            %
            fxy = (fdata_vr.*conj(fdata_vs))./lw;
        else
            tmp_eps = whiteNoise/100 * mean (tmp);
            % add eps to zero to avoid Nan values
            tmp_eps(tmp_eps==0) = eps;
            %
            fxy = (fdata_vr.*conj(fdata_vs))./(tmp + tmp_eps);
        end
    case 'Deconvolution'
        % deconvolution
        tmp = abs(fdata_vs).^2;
        %
        if strcmp(whiteNoise, 'runSmooth')
            % apply runSmooth whiten
            hw = max(ceil(size(tmp, 1)*0.005/2),2);
            %
            lw = runSmooth(tmp, 2*hw);
            % avoid lw to be zero
            [indx, indy] = find(lw == 0);
            if ~isempty(indx) && ~isempty(indy)
                whiteNoise = 2;
                lw_eps = whiteNoise/100 .* mean (lw,1);
                lw(indx, indy) = lw(indx, indy) + ones(length(indx),1)*lw_eps(indy);
            end
            %
            fxy = (fdata_vr.*conj(fdata_vs))./lw;
        else
            tmp_eps = whiteNoise/100 .* mean (tmp);
            % add eps to zero to avoid Nan values
            tmp_eps(tmp_eps==0) = eps;
            %
            fxy = (fdata_vr.*conj(fdata_vs))./(tmp + tmp_eps);
        end
    otherwise
        errlog = 'Unidentified interferometry method!';
        return
end
% free memory
clearvars fdata_vs fdata_vr;
% 
npts = length(t);
dt = t(2)-t(1);
%
switch tfpresent
    case 'temporal'
        % 
        rfxy = real(fxy); 
        ifxy = imag(fxy);
        % remove mean of real part 
        rfxy = rmmean(rfxy);
        % 
        fxy = complex(rfxy, ifxy);
        % remove the direct-current component
        fxy(1,:) = 0;
        % 
        [txy, tt] = ifftrl(fxy, f);
        % extend txy in case nf < npts
        if length(txy) < npts
            txy = [txy; zeros(npts-length(txy),size(txy,2))];
            tt = dt*(0:npts-1)';
        end
        %
        switch interftimespan
            case {'causal', 'acausal'}
                interf_matrix = txy(1:npts,:);
                interf_tAxes = tt(1:npts);
            case 'acausal+causal'
                txy_ac = flipud(txy);
                tt_ac = -1*tt;
                interf_matrix = [txy_ac(npts-1:-1:1,:); txy(1:npts,:)];
                interf_tAxes = [col2row(tt_ac(npts:-1:2), 1); col2row(tt(1:npts),1)];
            otherwise
                errlog = 'Unidentified interferometry time span, only support [causal, acausal, acausal+causal]!';
                return
        end
    case 'spectral'
        switch interftimespan
            case {'causal', 'acausal'}
                %
                if exist('twindow4acsp', 'var') && ~isempty(twindow4acsp)
                    npts = round(twindow4acsp/dt);
                    t = (0:npts-1)*dt;
                end
                %
                txy = ifftrl(fxy, f);
                % extend txy in case nf < npts
                if length(txy) < npts
                    txy = [txy; zeros(npts-length(txy),size(txy,2))];
                end
                uxt = txy(1:npts,:);
                [fxy, f] = fftrl(uxt,t,0.1,nf);
                interf_matrix = fxy;
                interf_tAxes = f;
            case 'acausal+causal'
                %
                interf_matrix = fxy;
                interf_tAxes = f;
            otherwise
                errlog = 'Unidentified interferometry time span, only support [causal, acausal, acausal+causal]!';
                return
        end
    case 'spac'
        %
        switch interftimespan
            case {'causal', 'acausal'}
                %
                if exist('twindow4acsp', 'var') && ~isempty(twindow4acsp)
                    npts = round(twindow4acsp/dt);
                    t = (0:npts-1)*dt;
                end
                %
                txy = ifftrl(fxy, f);
                % extend txy in case nf < npts
                if length(txy) < npts
                    txy = [txy; zeros(npts-length(txy),size(txy,2))];
                end
                uxt = txy(1:npts,:);
                [fxy, f] = fftrl(uxt,t,0.1,nf);
                interf_matrix = real(fxy./abs(fxy));
                interf_tAxes = f;
            case 'acausal+causal'
                %
                interf_matrix = real(fxy./abs(fxy));
                interf_tAxes = f;
            otherwise
                errlog = 'Unidentified interferometry time span, only support [causal, acausal, acausal+causal]!';
                return
        end
    otherwise
        errlog = 'Unidentified temporal/frequency presentation, only support [temporal, spectral, spac]!';
        return
end


end
