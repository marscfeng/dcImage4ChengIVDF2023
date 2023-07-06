function fig = Figure(figure_handle)
% Figure
% 	new figure with common figure setting
%
% Usage:
%   Figure(figure_handle)
%
% INPUT:
%   figure_handle, >0 create a new figure with specified figurenumber
%                  =0 create a new invisible figure
%                  empty, get current figure
%
% OUTPUT:
%   fig, output figure handle
%
% DEPENDENCES:
%   setplt
%
% AUTHOR:
% 	F. CHENG ON d-ip-10-194-35-196.sec-ceeusers.nor.ou.edu
%
% UPDATE HISTORY:
% 	Initial code, 06-Mar-2018
%   Add figure handle check, 28-Mar-2018
%   update Figure options, 23-Jan-2020
% ------------------------------------------------------------------
%%

if figure_handle > 0
    if ishandle(figure_handle)
        figure(figure_handle);close;
    end
    fig = figure(figure_handle);
elseif figure_handle==0
    fig=figure('visible','off');
elseif isempty(figure_handle)
    fig = gcf;
end

%%------------------------
