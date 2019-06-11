function [] = mat_to_csv(filename, model_string, input_cells)
%MAT_TO_CSV Output a CSV file from .MAT structure with diffusion runs
%   Generate a CSV file at the given output (as well as the table for
%   the CSV as the returned output of this function) from the .MAT
%   structure taken from the output of the diffusion runs.
%


  %% Parameters for the plots.
  time_quantiles = [0.1, 0.5, 0.9];
  n_theta_obs_quantiles = 7;
  time_step = 0.01;
  min_rt_filter = 0.15;
  max_rt_filter = 5.5;
  
  %% Open the file
  fp = fopen(filename, 'w');
  
  %% Extract the required quantities from the cell array.
  data_cells = input_cells(:, 6);
  model_cells = input_cells(:, 5);
  
  %% Print the header line in the CSV.
  header_line = 'model_name, participant, is_model, is_high, quantile_idx, rt, theta';
  fprintf(fp, [header_line '\n']);
  
  %% For each observer in the cell array...
  n_observers = min(size(data_cells, 1), ...
                    size(model_cells, 1));

  for i = 1:n_observers
    %% There appears to be a strange observer without any data in them, so
    %  let's skip over anyone who doesn't seem to have data.
    if isempty(data_cells{i, :}) || isempty(model_cells{i, :})
       continue 
    end
      
    %% Get the appropriate data and models.
    
    %troubleshooting
    disp('Participant')
    disp(i);
    %
    
    this_data_cell = data_cells{i, :};
    this_model_cell = model_cells{i, :};

    low_image_data = this_data_cell{1, 1};
    high_image_data = this_data_cell{1, 2};

    low_time_vector = this_model_cell{1, 1};
    low_theta_vector = this_model_cell{2, 1};
    low_joint = this_model_cell{3, 1};
    high_time_vector = this_model_cell{1, 2};
    high_theta_vector = this_model_cell{2, 2};
    high_joint = this_model_cell{3, 2};
    
    %% Output the high imagability predictions (the quantile lines).
    [high_pred_qlines, high_pred_theta] = ...
        joint_dist_to_qlines(high_time_vector, high_theta_vector, ...
                             high_joint, time_quantiles, time_step);
    for j = 1:size(time_quantiles, 2)
      for k = 1:size(high_pred_theta, 2)
        this_quantile = time_quantiles(j);
        this_qline_point = high_pred_qlines(k, j);
        this_line = {model_string, num2str(i), 'true', 'true', ...
                     num2str(this_quantile), num2str(this_qline_point), ...
                     num2str(high_pred_theta(k))};
        this_line = strjoin(this_line, ', ');
        fprintf(fp, [this_line '\n']);
      end
    end
    
    
    %% Output the high imagability observed data QxQ points.
    [qxq_high, qxq_thetas_high] = data_to_qxq(high_image_data, ...
                                              n_theta_obs_quantiles, ...
                                              time_quantiles, ...
                                              min_rt_filter, ...
                                              max_rt_filter);
    for j = 1:size(time_quantiles, 2)
      for k = 1:size(qxq_thetas_high, 2)
        this_quantile = time_quantiles(j);
        this_qxq_rt = qxq_high(j, k);
        this_qxq_theta = qxq_thetas_high(k);
        this_line = {model_string, num2str(i), 'false', 'true', ...
                     num2str(this_quantile), num2str(this_qxq_rt), ...
                     num2str(this_qxq_theta)};
        this_line = strjoin(this_line, ', ');
        fprintf(fp, [this_line '\n']);
      end
    end

    %% Output the low imagability predictions (the quantile lines).
    [low_pred_qlines, low_pred_theta] = joint_dist_to_qlines(low_time_vector,...
                                           low_theta_vector, low_joint, ...
                                           time_quantiles, time_step);
                                       
    for j = 1:size(time_quantiles, 2)
      for k = 1:size(low_pred_theta, 2)
        this_quantile = time_quantiles(j);
        this_qline_point = low_pred_qlines(k, j);
        this_line = {model_string, num2str(i), 'true', 'false', ...
                     num2str(this_quantile), num2str(this_qline_point), ...
                     num2str(low_pred_theta(k))};
        this_line = strjoin(this_line, ', ');
        fprintf(fp, [this_line '\n']);
      end
    end

    %% Output the low imagability observed data QxQ points.
    [qxq_low, qxq_thetas_low] = data_to_qxq(low_image_data, ...
                                            n_theta_obs_quantiles, ...
                                            time_quantiles, ...
                                            min_rt_filter, ...
                                            max_rt_filter);
                                        
    for j = 1:size(time_quantiles, 2)
      for k = 1:size(qxq_thetas_low, 2)
        this_quantile = time_quantiles(j);
        this_qxq_rt = qxq_low(j, k);
        this_qxq_theta = qxq_thetas_low(k);
        this_line = {model_string, num2str(i), 'false', 'false', ...
                     num2str(this_quantile), num2str(this_qxq_rt), ...
                     num2str(this_qxq_theta)};
        this_line = strjoin(this_line, ', ');
        fprintf(fp, [this_line '\n']);
      end
    end
  end
  
  %% Close the file
  fclose(fp);
end
