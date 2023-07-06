% cal distance between two points
%
% Usage
%   D=ABdist2D(R,cartFlagR,S,cartFlagS,cartFlagD)
%
% INPUT:
%   R/S should be in the same scale
%       R M*2, S M*2,
%   cartFlag R/S means coordinate type, 1 for cartesian (X, Y); 0 for polar(Az, R)
%
% OUTPUT:
%   D, M*1
%
% DEPENDENCES:
%   cart2pol/pol2cart
%
% AUTHOR:
%   F. CHENG ON mars-OSX.local
%
% UPDATE HISTORY:
%   Initial code, 26-Jan-2019
%
% SEE ALSO:
%   noiseModelplan
% ------------------------------------------------------------------
%%
function D=ABdist2D(R,cartFlagR,S,cartFlagS)

%
if size(R,1) ~= size(S,1)
    error('R,S should be in the same scale!');
else
    D = zeros(size(R,1),1);
end
%%

if cartFlagR ~= cartFlagS
    if cartFlagS
        % cartesian coordinates
        [R(:,1), R(:,2)]= pol2cart(R(:,1), R(:,2)); %az, r
    else
        % polar(spherical) coordinates
        [R(:,1), R(:,2)]= cart2pol(R(:,1), R(:,2));% az, r
    end   
end
if cartFlagS
    % cartesian coordinates
    x1=R(:,1); y1=R(:,2);
    x2=S(:,1); y2=S(:,2);
    D(:) = sqrt((x1-x2).^2 + (y1-y2).^2);
else
    % polar(spherical) coordinates
    az1=R(:,1);r1=R(:,2);
    az2=S(:,1);r2=S(:,2);
    D(:) = sqrt(r1.^2+r2.^2-2*r1.*r2.*cos(az1-az2));
end
