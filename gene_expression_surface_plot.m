% gene_expression is a matrix where the rows are the genes and the columns are the time points.

% gene_expression_surface_plot(gene_expression, time_points, 'Gene expression', 'Time', 'Genes', 'Expression')

function gene_expression_surface_plot(gene_expression, time_points, plot_title, x_label, y_label, z_label)

  n = size(gene_expression,1);

  h=figure('units', 'centimeters', 'position', [0, 0, 30, 24]);

  clear title;

  set(gcf, 'PaperPositionMode', 'manual');
  set(gcf, 'PaperUnits', 'centimeters');
  set(gcf, 'PaperPosition', [0 0 30 24]);
  set(gcf, 'PaperUnits', 'centimeters');
  set(gcf, 'PaperSize', [30 24]);
  axisLabelFontSize = 30;


  surf(gene_expression,'FaceColor','interp','EdgeColor','none');

  xlim([1,length(time_points)]);

  set(gca,'XTick',1:length(time_points),'Xticklabel',time_points);
  set(gca,'FontSize',11);

  ylim([1,n]);

  zlim([min(min(gene_expression)),max(max(gene_expression))]);

  xlabel(x_label, 'FontSize', axisLabelFontSize);

  ylabel(y_label, 'FontSize', axisLabelFontSize);

  zlabel(z_label, 'FontSize', axisLabelFontSize);

  title(plot_title, 'FontSize', axisLabelFontSize);

end


function dummy_function()

% To plot the expression of a cluster of genes
cluster_index = 1;
gene_expression_surface_plot(gene_expression(list_of_gene_clusters{cluster_index},:), time_points, 'Gene expression', 'Time', 'Genes', 'Expression')






end