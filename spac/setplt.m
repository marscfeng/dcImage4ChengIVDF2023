% setplt()
%   common figure control for matlab plot
%
% Usage
%   setplt
%
% INPUT:
%
% OUTPUT:
%
% DEPENDENCES:
%
% AUTHOR:
%   F. CHENG ON mars-OSX.local
%
% UPDATE HISTORY:
%   Initial code, 13-Sep-2017
%   add global envs, 6-Mar-2018
%   add layer stick, 25-Mar-2019
% 
% ------------------------------------------------------------------
function setplt()
%% colorbar('EastOutside');
% box off
set(gca,'Fontsize',12,'FontWeight','normal');
set(get(gca,'XLabel'),'FontWeight','normal','FontSize',14);%,'Interpreter','latex')
set(get(gca,'YLabel'),'FontWeight','normal','FontSize',14);%,'Interpreter','latex')
set(gca,'xminortick','on');
set(gca,'yminortick','on');
% set(gca,'ticklength',[0.005 0.0005]);
set(gca,'ticklength',[0.007 0.0007]);
ax = gca;
Xax = ax.XAxis;
Yax = ax.YAxis;
set(Xax,'tickdir','in');
set(Yax,'tickdir','out');
% set(gca,'tickdir','out');
set(gca,'layer','top')
set(gca, 'LineWidth', 1);
grid on

%%
set(gca,'color','w');
set(gcf,'color','w');
% set(gca,'color','none');
% set(gcf,'color','none');