% Process csv into matlab-friendly data structures
[J1, J2, J3] = xlsread("EXPINT_data.csv");

% Code conditions numerically in J1
J3(1,:) = [];
J1(strcmp(J3(:,5), 'unrelated'), 5) = 1;
J1(strcmp(J3(:,5), 'orthographic'), 5) = 2;
J1(strcmp(J3(:,5), 'semantic'), 5) = 3;
% Add one to some indices (trial, block), because javascript is 0 indexed
% and I don't really like that
J1(:,3) = J1(:,3) + 1;
J1(:,6) = J1(:,6) + 1;

% First, exclude the practice blocks
all_data = J1(J1(:,3) ~= 0,:);

% Remove foils
all_data = all_data(all_data(:,7) == 1,:);

% Then, exclude trials with invalid RTs
all_data = all_data(all_data(:, 15) ~= 0,:);

% Finally, exclude trials where the target word was not recognised
all_data = all_data(all_data(:, 9) == 1,:);

% Get a list of participants
participants = unique(all_data(:,1));

% Get a list of conditions. Data will be sorted as conditions nested in participants
conditions = unique(all_data(:,5));
data = cell(length(participants),3);

% Rescale response times to be in seconds, not ms
all_data(:,8) = all_data(:,14)/1000;

% Each cell is a participant
% [response error, response time, response angle, target angle,intrusion angle 1 ... intrusion angle 9]
for i = 1:length(participants)
    for j = 1:length(conditions)
        this_data = all_data((all_data(:,1) == i) & ...
            (all_data(:,5) == j), :);
        this_cell = zeros(length(this_data), 40);
        this_cell(:,1) = this_data(:,13); % source error
        this_cell(:,2) = this_data(:,14)/1000; % source RT, in seconds
        this_cell(:,3) = this_data(:,12); % response angle
        this_cell(:,4) = this_data(:,11); % target angle
        this_cell(:,5) = this_data(:,6); % trial number (in block)
        this_cell(:,6:12) = this_data(:,23:29); % intrusion offsets
        this_cell(:,13:19) = this_data(:,30:36); % intrusion lags
        this_cell(:,20:26) = this_data(:,37:43); % intrusion spatial distances
        this_cell(:,27:33) = this_data(:,44:50); % Orthographic
        this_cell(:,34:40) = this_data(:,51:57); % Semantic
        this_cell(:,41:47) = this_data(:, 16:22); % Intrusion Angles
        data{i,j} = this_cell;
    end
end