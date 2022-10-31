% Joint (Q-Q)
% General function to get a set of qq points from a set of data, simulated
% or observed.
    function [qq] = get_qq(Data)

        % Response Error Quantiles
        error_quantiles = [.1,.3,.5,.7,.9];

        % Response Time Quantiles
        time_quantiles = [.1,.3,.5,.7,.9];

        % Change response error to absolute, because we don't care about
        % asymmetry along the y-axis
        Data(:,1) = abs(Data(:,1));
        Data = sortrows(Data, 1);

        % Find the theta bin boundaries (based on error quantile values)
        % Appending a zero to the start of the vector to give us a lower
        % bound for the first bin
        error_bins = [0, quantile(Data(:,1), error_quantiles)];
        
        % Empty structure for all quantiles to be stored in
        qq = zeros(length(time_quantiles) * length(error_quantiles), 4);
        for i = 1:length(error_quantiles)
            this_bin_qq = zeros(length(time_quantiles), 4);
            % Subset the data to be between the two quantile boundaries of
            % each bin
            this_bin = Data(Data(:,1) >= error_bins(i) & Data(:,1) < error_bins(i+1),:);

            % Find the RT quantiles within this bin of data
            this_bin_rt = quantile(this_bin(:,2), time_quantiles)';

            % Assemble a structure of qq co-ords for this error bin
            this_bin_qq(:,1) = error_bins(i+1); % Upper boundary of bin, error quantile, x co-ord on plot
            this_bin_qq(:,2) = this_bin_rt; % RT quantiles, y co-ord
            this_bin_qq(:,3) = i; % Not sure if necessary, just quantile index for error and time. 
            this_bin_qq(:,4) = 1:5;

            qq((1:length(time_quantiles))+(i-1)*length(time_quantiles),:) = this_bin_qq; % cooked indexing?? 
        end
    end