function [fmin,fmax, famp] = cutFreq(fdata,f,threshold)
% cutFreq
%   CAL cutoff frequency for FFTRL to avoid imaging alias
%   Based upon a threshold energy percentage threshold
%   the cutoff frequency is computed. Starting with the lowest
%   frequency, cutoff is the frequency sample for which the cumulative
%   energy is larger than threshold% of the total energy. Restricting the later
%   computations to cutoff saves a lot of time, since cutoff is sometimes
%   only a fraction of the total frequency range.
%
% Usage
%   [fmin,fmax,famp] = cutFreq(fdata,f,threshold)
%
% INPUT:
%   fdata, 2D seismic data spectra [nf, ntrace]
%   f, 1D time series [nf]
%   threshold, optional threshold energy percentage, default 99.7
%
% OUTPUT:
%   fmin, lower cutoff frequency
%   fmax, upper cutoff frequency
%   famp, stacked data spectra energy [nf]
%
% AUTHOR:
%   F. CHENG ON mars-OSX.local
%
% UPDATE HISTORY:
%   Initial code, 26-Jun-2017
%   add 'omitnan' option into sum, 09-Aug-2021
% ------------------------------------------------------------------
%%
% fdata(isnan(fdata)) = 0; 
% 
if ~exist('threshold','var')
    threshold = 99.7;
end
%
if length(f) ~= size(fdata,1)
    error('conflict input vector/matrix numbers!')
end
%
famp = abs(sum(fdata,2,'omitnan'));
% total spectra energy
E_total = sum(famp);
% cumulate spectra energy
E = cumsum(famp);

%
index = between(0, 1-threshold/100, E/E_total, 2);
if isempty(index) || index(1) == 0
    index = 1;
end
fmin = f(index(end));
index = between(threshold/100, Inf, E/E_total, 2);
fmax = f(index(1));

end