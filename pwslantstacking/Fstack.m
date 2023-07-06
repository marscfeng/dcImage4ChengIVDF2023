% Fstack
%   stack input matrix by
%       mean stacking (0);
%       phase-weight stacking (1);
%       semblance-weight stacking (2)
%
% Usage:
%   dataStack = Fstack(matrixCell, stackFlag, nu)
%
% INPUT:
%   matrixCell, input data for stacking, could be 2D/3D matrix or cell array for both real and complex values
%   stackFlag, 0 for mean stack/ 1 for phase-wight stack/ 2 for semblance-weight stack
%   nu, power term used for phase-weighted stack. larger nu, larger influence of the phase-cohenrecy
%       weighting, so nu = 0 is equivalent to mean stack. recommond nu = 1
%
% OUTPUT:
%   dataStack, stacked matrix
%
% DEPENDENCES:
%
% AUTHOR:
%   F. CHENG ON fcheng-m36.dhcp.lbl.gov
%
% UPDATE HISTORY:
%   Initial code, 29-May-2019
%   add real option for instanPhaseEstimator input to support complex matrix, 07-May-2020
%   add parfor option, 07-Jul-2020
%   remove switch judge inside parfor loop by converting matrix into uniform cell form, 09-Nov-2021
%
% SEE ALSO:
%   dsi_stackFiles, tf_pws
%
% ------------------------------------------------------------------
%%
function [dataStack, mstack] = Fstack(matrixCell, stackFlag, nu, parallelFlag)
%
if ~exist('stackFlag','var')
    stackFlag = 0;
end
%
if ~exist('nu','var')
    nu = 1;
end
%
if exist('parallelFlag', 'var') && parallelFlag
    parforArgs = Inf;
else
    parforArgs = 0;
end
%
if iscell(matrixCell)
    % each cell element contains the 1D/2D data for stacking
    nStack = numel(matrixCell);
    mstack = zeros(size(matrixCell{1}));
elseif ismatrix(matrixCell)
    % each column contains the array for stacking
    nStack = size(matrixCell, 2);
    mstack = zeros(size(matrixCell, 1), 1);
    % convert matrix to cell to avoid switch judge inside parfor loop
    tmp = cell(nStack, 1);
    for i = 1 : nStack
        tmp{i} = matrixCell(:,i);
    end
    matrixCell = tmp; clearvars tmp;
    %
else
    % 3D matrix of [npts, ntrace, nstack]
    nStack = size(matrixCell, 3);
    mstack = zeros(size(matrixCell(:,:,1)));
    % convert matrix to cell to avoid switch judge inside parfor loop
    tmp = cell(nStack, 1);
    for i = 1 : nStack
        tmp{i} = matrixCell(:,:,i);
    end
    matrixCell = tmp; clearvars tmp;
end
coherencySum = zeros(size(mstack));
%
% for i = 1 : nStack
parfor (i = 1 : nStack, parforArgs)
    %
    data_in = matrixCell{i};
    %
    switch stackFlag
        case 0
            coherencySum = coherencySum + zeros(size(data_in));
        case 1
            coherencySum = coherencySum + instanPhaseEstimator(real(data_in));
        case 2
            coherencySum = coherencySum + data_in.^2;
        case 3
            coherencySum = coherencySum + PhaseEstimator(data_in);
    end
    %
    mstack = mstack + data_in;
end
%
mstack = mstack./nStack;
%
if stackFlag
    switch stackFlag
        case {1,3}
            phaseWeight = power(abs(coherencySum/nStack), nu);
        case 2
            phaseWeight = mstack.^2./coherencySum;
    end
    dataStack = mstack .* phaseWeight;
else
    dataStack = mstack;
end


end


%
function [phaseshiftMat] = instanPhaseEstimator(gather)
%%
%
phiMat = angle(hilbert(gather));
phaseshiftMat = exp(sqrt(-1)*phiMat);

end


%
function [phaseshiftMat] = PhaseEstimator(gather)
%%
%
% phiMat = angle(gather);
% phaseshiftMat = exp(sqrt(-1)*phiMat);

phaseshiftMat = gather./abs(gather);
end