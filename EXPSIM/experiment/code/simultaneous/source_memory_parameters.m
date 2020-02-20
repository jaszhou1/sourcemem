function res = source_memory_parameters()
%SOURCE_MEMORY_PARAMETERS Generates source memory parameter structure
%   Generates a structure containing the parameters for the source memory
%   experiment.
%
% Simon Lilburn <lilburns AT unimelb DOT edu DOT au>

res = struct();

% Structure parameters.
res.num_blocks = 2; % 14 blocks in 50 mins
res.num_encode_trials = 2; %10
res.num_maths_trials = 2; %10
res.num_recog_trials = 2; %10
res.num_test_trials = 2; %10


% Timing parameters.
res.fixation_duration_ms = 600;
res.encode_error_duration_ms = 1000;
res.angle_display_duration_ms = 600; 
res.angle_repeat_duration_ms = 250;
res.word_encoding_ms = 1500;
res.word_memory_ms = 1500;
res.encode_iti_ms = 500;
res.test_iti_ms = 500;
res.intro_time = 1000;

% Colour parameters.
% 
res.word_colour = [255, 255, 255];
res.inactive_circle_colour = [96, 96, 96];
res.circle_colour = [64, 64, 64];
res.fixation_cross_colour = [0, 0, 0];
res.cross_colour = [0, 0, 0];
res.cursor_colour = [196, 2, 51]; % psychological red (NCS)
res.error_text_colour = [196, 2, 51]; % psychological red (NCS)
res.confidence_bar_back = [75, 75, 75];
res.confidence_bar_front = [192, 192, 192];

% Sizing/positioning parameters.
res.word_size_px = 24;
res.circle_radius_px = 191; % computed 20px as being around 6% of the circle
res.circle_thickness_px = 3;
res.cross_size_px = 25;
res.cross_thickness_px = 5;
res.cursor_size_px = 4;
res.fixation_cross_size_px = 5;
res.fixation_cross_width_px = 1;
res.line_width_px = 4;

% Misc. parameters.
res.max_encode_reproduction_error_rad = deg2rad(6);
res.font_name = 'Courier New';
res.mouse_limit = 10000;

end

