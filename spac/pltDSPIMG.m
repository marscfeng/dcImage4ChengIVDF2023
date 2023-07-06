function pltDSPIMG(f,v,fv,normFlag,figure_handle,x,famp,fmin_cut,fmax_cut,strTag,picFilename, fkFlag)
%
Figure(figure_handle);
set(gcf,'Units','normalized','Position',[0.2 0.2 0.4 0.5]);
subplot('position', [0.1 0.1 0.8 0.6])
pltdsp(f,v,fv,normFlag,[],x)
% 
if exist('fkFlag', 'var') && fkFlag
	ylabel('Wavenumber (1/m)')
end
ax1 = gca;
setplt
% 
if ~isempty(famp)
	xLimits = get(gca,'XLim');
	subplot('position', [0.1 0.75 0.8 0.2])
	plot(f, famp, 'k-', 'linewidth',1);
	vline(fmin_cut, 'k');
	vline(fmax_cut, 'k');
	xlim(xLimits)
	ylabel('Spectrum amplitude')
	title(sprintf('%s Dispersion Image at %s', strTag, gcdSTR));
	setplt
end
% 
axes(ax1);
% 
if ~isempty(picFilename)
    savepdf(figure_handle,picFilename);
end
