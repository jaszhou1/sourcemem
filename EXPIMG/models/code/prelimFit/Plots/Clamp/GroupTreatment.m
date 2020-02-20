function [Group_Data] = GroupTreatment()
%   Data Treatment script to make EXPSOURCE model fitting code cooperate with
%   EXPIMG data
%
% Jason Zhou <jasonz1 AT student DOT unimelb DOT edu DOT au>

%% 
%Read Data in
%[J1, J2, J3] = xlsread(data); %J2 and J3 are auxiliary, tells you what the column headers are.
% MATLAB doesnt like having strings and numbers together)
load('Jindiv_Simple.mat'); %shortcut

%Split high and low recog conf

%Split
J_LC = J1(J1(:,2)<3,:);
J_HC = J1(J1(:,2)>=3,:);

%Reminder that 1 is low, 2 is high

Group_Data = cell(1,2); %the array handed out
Recognised = cell(1,2);
Unrecognised = cell(1,2);

%Empty structures 
    ntrials_Y_LOW = length(J_HC(J_HC(:,1)==1)); %recognised (>=3) and Low Imageability condition
    ntrials_Y_HIGH = length(J_HC(J_HC(:,1)==2));
    ntrials_N_LOW = length(J_LC(J_LC(:,1)==1));
    ntrials_N_HIGH = length(J_LC(J_LC(:,1)==2));


    [Y_LOW,Y_HIGH] = makesubject_simple(:, J_HC,ntrials_Y_LOW,ntrials_Y_HIGH);
    [N_LOW,N_HIGH] = makesubject_simple(:, J_LC,ntrials_N_LOW,ntrials_N_HIGH);
    

% Recognised(:,1) = J_LC(:,6);
% Recognised(:,2) = J_LC(:,7);
% 
% Data2(:,1) = J_HC(:,6);
% Data2(:,2) = J_HC(:,7);
% 
% Group_Data{1,1} = Data1;
% Group_Data{1,2} = Data2;

end

