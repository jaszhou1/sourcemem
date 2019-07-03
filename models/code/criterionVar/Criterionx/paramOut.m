function [] = paramOut(filename,model_string,input_cells)
%Output parameter values

%% Open the file
fp = fopen(filename, 'w');

%% Extract the required quantities from the cell array.
param_cells = input_cells(:, 4);

if strcmp('Continuous',model_string)
    parameters = ', v1a, v2a, v1b, v2b, eta1, eta2, a, Ter, st, sa';
elseif strcmp('Threshold',model_string)
    parameters = ', v1a, v2a, v1b, v2b, a1, a2, pi1, pi2, Ter,st,sa';
elseif strcmp('Hybrid',model_string)
    parameters = ', v1a, v2a, v1b, v2b, eta1, eta2, a1, a2, pi1, pi2, Ter,st,sa';
elseif strcmp('GVM',model_string)
    parameters = ', nunorm1, nunorm2, kappa1, kappa2, eta, rho, a, Ter, st, sa';
end

header = 'model_name, participant';
header_line = strcat (header,parameters);
fprintf(fp, [header_line '\n']);

% For each observer in the cell array...
n_observers = size(param_cells, 1);

for i = 1:n_observers
    % Skip Empty Participants
    if isempty(param_cells{i, :})
        continue
    end
    
    this_line = ...
        strjoin(horzcat(model_string, num2str(i), ...
                        string(param_cells{i})), ', ');
    fprintf(fp, strcat(this_line, '\n'));
end

%% Close the file
fclose(fp);

end

