function data = source_memory_recog_trial(screen, par, word, type, cond)
%SOURCE_MEMORY_RECOG_TRIAL
%   Provides the interface for a trial in the recognition phase of the source
%   memory experiment.

%   Jason Zhou <jasonz1 AT student  DOT unimelb DOT edu DOT au>
recog_fixation (screen, par);

% Obtain a six-point Old/New rating from the participant.
[recog_rating, recog_response_time] = recog_confidence_key (screen, par, word);

% Package up the data.
data = struct();
data.word = word;
data.type = type;
data.cond = cond;
data.recognition_rating = recog_rating;
data.recognition_response_time = recog_response_time;
end

