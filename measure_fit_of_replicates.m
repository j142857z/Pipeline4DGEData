function measure_fit_of_replicates()

  set_paths_and_imports;
  
  global Dynamics4GenomicBigData_HOME;
  
  input_file_name = input('Enter the input file name: ');
  
  cd('Input');
  
  [GEO_number, condition, samples, time_points, number_of_top_DRGs] = read_input(input_file_name);
  
  cd('..');
  
  number_of_replicates = size(samples,2);
  
  for i=1:number_of_replicates
  
    replicate_condition = [condition '_replicate_' num2str(i)];
    
    samples_replicate = samples(:,i);    
    
    [gene_expression{i}, standardized_gene_expression{i}, time_points_replicate{i}] = step_2(GEO_number, samples_replicate, time_points, false);
    
    standardized_gene_expression{i} = cell2mat(table2cell(standardized_gene_expression{i}(:, 3:size(standardized_gene_expression{i},2))));
    
    list_of_genes{i} = table2cell(gene_expression{i}(:,2));
    
    list_of_probe_ids{i} = table2cell(gene_expression{i}(:,1));
  end
  
  general_comparison_folder = [Dynamics4GenomicBigData_HOME 'Output/' GEO_number '/Comparison_of_replicates/' condition];
  mkdir(general_comparison_folder);
  
  % The following two lines measure the noise between the replicates.
  % The results are stored in variable list_of_probes_genes_noise, which is a cell array where the first column is the probe ids, the second column is the gene names and the third column is the noise measurements across the replicates.
  % The order of the probe ids/gene names is the same as in the original GEO matrix.
  noise_per_gene = measure_noise_between_replicates(standardized_gene_expression);
  list_of_probes_genes_noise = [strtrim(list_of_probe_ids{1}) strtrim(list_of_genes{1}) num2cell(noise_per_gene)];
  
  list_of_probes_genes_noise = [[{'Probe IDs'} {'Gene names'} {'Noise'}]; list_of_probes_genes_noise];
  
  % The following lines perform the same function, but the resulting cell array lists probe ids/gene names sorted by noise, from lower to higher noise.
  [B,I] = sort(noise_per_gene);
  list_of_probes_genes_noise_sorted_by_noise = [num2cell(I) strtrim(list_of_probe_ids{1}(I)) strtrim(list_of_genes{1}(I)) num2cell(noise_per_gene(I))];
    
  list_of_probes_genes_noise_sorted_by_noise = [[{'Row in GSE matrix'} {'Probe IDs'} {'Gene names'} {'Noise'}]; list_of_probes_genes_noise_sorted_by_noise];
    
  cd(general_comparison_folder);
    
  % The two cell arrays constructed earlier are exported as .csv files.
  writetable(cell2table(list_of_probes_genes_noise), [condition '_noise_per_gene_ALL_GENES.csv'], 'WriteVariableNames',false);  
  writetable(cell2table(list_of_probes_genes_noise_sorted_by_noise), [condition '_noise_per_gene_ALL_GENES_SORTED_BY_NOISE.csv'], 'WriteVariableNames',false);
    
  for probe_id_index_seq = 1:min(10, length(I))
    probe_id_index = I(probe_id_index_seq);
    
    gene_expression_to_plot = [];
    for condition_index = 1:number_of_replicates
      gene_expression_to_plot = [gene_expression_to_plot; standardized_gene_expression{condition_index}(probe_id_index,:)];
    end
    gene_expression_plot(gene_expression_to_plot, time_points, ['Probe ' list_of_probe_ids{1}(probe_id_index)], 'Time', 'Expression level', 'Expression');
      
    print(gcf,'-dpdf', [num2str(probe_id_index_seq) '_Probe_' list_of_probe_ids{1}{probe_id_index}]);
    close all;
  end

  for probe_id_index_seq = floor(linspace(min(10, length(I)),max(0,length(I)-10),10))
    probe_id_index = I(probe_id_index_seq);
    
    gene_expression_to_plot = [];
    for condition_index = 1:number_of_replicates
      gene_expression_to_plot = [gene_expression_to_plot; standardized_gene_expression{condition_index}(probe_id_index,:)];
    end
    gene_expression_plot(gene_expression_to_plot, time_points, ['Probe ' list_of_probe_ids{1}(probe_id_index)], 'Time', 'Expression level', 'Expression');
      
    print(gcf,'-dpdf', [num2str(probe_id_index_seq) '_Probe_' list_of_probe_ids{1}{probe_id_index}]);
    close all;
  end
  
  for probe_id_index_seq = max(0,length(I)-10):length(I)
    probe_id_index = I(probe_id_index_seq);
    
    gene_expression_to_plot = [];
    for condition_index = 1:number_of_replicates
      gene_expression_to_plot = [gene_expression_to_plot; standardized_gene_expression{condition_index}(probe_id_index,:)];
    end
    gene_expression_plot(gene_expression_to_plot, time_points, ['Probe ' list_of_probe_ids{1}(probe_id_index)], 'Time', 'Expression level', 'Expression');
    
    print(gcf,'-dpdf', [num2str(probe_id_index_seq) '_Probe_' list_of_probe_ids{1}{probe_id_index}]);
    close all;
  end
  
  cd(Dynamics4GenomicBigData_HOME);

end

% Input
% gene_expression_of_replicates is a R-sized cell array where each element is an MxN matrix of double values representing the gene expression of one replicate. The rows of the matrix are the genes and the columns are the time points. It is assumed that all matrices have the same size. That is to say, it is assumed that all replicates provided as input have the same number of genes and time points.

% Output
% A column (vertical) vector of doubles where the k-th element is a measure of the noise observed in the expression of the k-th gene in the expression matrices provided as input.

% Example
% Two 'replicates', A and B, with three genes and seven time points.

%  A = [2 4 5 9 1 2 3; 1 5 9 4 2 1 5; 2 7 9 4 8 5 9];
%  
%  B = [9 6 1 3 4 5 2; 2 2 1 6 4 3 7; 2 9 6 4 7 1 1];
%  
%  gene_expression_of_replicates = [{A} {B}];
%  
%  noise_per_gene = measure_noise_between_replicates(gene_expression_of_replicates);
%  
%  % Returns
%  
%  noise_per_gene =
%  
%      0.6529
%      0.5580
%      0.3754
%
%  %  The third gene is the most consistent across the two replicates.

function noise_per_gene = measure_noise_between_replicates(gene_expression_of_replicates)

  noise_per_gene = [];
  
  for gene_index = 1:size(gene_expression_of_replicates{1},1)
  
    expression_of_current_gene_across_replicates = [];
    
    for replicate_index=1:length(gene_expression_of_replicates)
    
      gene_expression_of_replicate = gene_expression_of_replicates{replicate_index};
      
      expression_of_current_gene_in_current_replicate = gene_expression_of_replicate(gene_index,:);
      
      expression_of_current_gene_across_replicates = [expression_of_current_gene_across_replicates; expression_of_current_gene_in_current_replicate];
    end
    
    % In the following four lines, the coefficient of variation of each gene across the R replicates.
%      mean_of_current_gene = mean(expression_of_current_gene_across_replicates);    
%      std_of_current_gene = std(expression_of_current_gene_across_replicates);    
%      coefficient_of_variation_of_current_gene = std_of_current_gene./mean_of_current_gene;    
%      noise_of_current_gene = mean(coefficient_of_variation_of_current_gene);
    
    % The following line is an alternative to the previous four lines and measures noise as the
    % average of the gene's standard deviation across the R replicates.
    noise_of_current_gene = mean(std(expression_of_current_gene_across_replicates));
    
%      noise_of_current_gene = max(std(expression_of_current_gene_across_replicates));
    
    noise_per_gene = [noise_per_gene; noise_of_current_gene];
  
  end

end