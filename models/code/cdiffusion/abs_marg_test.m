input_cells = HY_LL_Preds_Recognised;
data_cells = input_cells(:, 6);


for i = 1:length(input_cells)
    if isempty(data_cells{i, :})
        continue
    end
    %Combine Conditions
    data_cells{i,:} = vertcat(data_cells{i,1}{1,1},data_cells{i,1}{1,2});
    
    %Make Absolute
    data_cells{i,1}(:,1) = abs(data_cells{i,1}(:,1));
end



model_cells = input_cells(:, 3);
%empty array
res = cell(length(input_cells),2);

for i = 1:length(input_cells)
     if isempty(model_cells{i, 1})
         continue
     end
    % Combine imageability conditions
    res{i,1} = (model_cells{i,1}{1,1} + model_cells{i,1}{1,2})/2;
    res{i,2} = (model_cells{i,1}{1,3} + model_cells{i,1}{1,4})/2; 
  
%     % Make Absolute DO THIS TONIGHT
    res{i,3}(1,:) = res{i,2}(1,(ceil(length(res{1,2})/2):length(res{1,2})));
    
    %   zero
    %res{i,3}(2,1) = res{i,2}(2,ceil(length(res{1,2})/2));
    
    % All other bins (plot is symmetric so just taking half the model predictions, can
    % finish averaging model if we observe assymetry)
    z = 0;
    for j = 1:length(res{i,3})
        res{i,3}(2,j) = res{i,2}(2,(ceil(length(res{1,2})/2)+z));
        z = z+1;
    end
end