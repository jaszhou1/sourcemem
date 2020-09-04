function [Fit_Data] = Treatment_Simple()
%
% Jason Zhou <jasonz1 AT student DOT unimelb DOT edu DOT au>

%Read Data in
% % J2 and J3 are auxiliary, tells you what the column headers are.
% % MATLAB doesnt like having strings and numbers together
%  [J1, J2, J3] = xlsread("dataFiltered3.csv"); 
%  J1(:,1)=[];
%  J3(:,1)=[];

load('dataFiltered3.mat'); % Filtered version
J1(:,1) = [];
%Split high and low recog conf

%Split
% J_HC = J1(J1(:,2)>=3,:);
% J_LC = J1(J1(:,2)<3,:);

% Fit Confidence Individually 10/08
% In response to reviews, confidence bands will be fit individually
% I am repurposing "LC", which stood for "Low Confidence" (less than 3)


J_HC = J1(J1(:,2)>=3,:);
J_LC = J1(J1(:,2)<3,:);

%For the highest recognition, 14/03
% J_HC = J1(J1(:,2)==6,:);
% J_LC = J1(J1(:,2)<3,:);

%Conditions: 1 is LOW, 2 is HIGH

%The following needs to be in a loop for each participant
%Need the size of each participant in the 2x2 factorial thing
% ntrials_Y_LOW = length(J_HC(J_HC(:,1)==1&J_HC(:,8)==1,:)); %recognised (>=3) and Low Imageability condition
% ntrials_Y_HIGH = length(J_HC(J_HC(:,1)==2&J_HC(:,8)==1,:));
% ntrials_N_LOW = length(J_LC(J_LC(:,1)==1&J_LC(:,8)==1,:));
% ntrials_N_HIGH = length(J_LC(J_LC(:,1)==2&J_LC(:,8)==1,:));
% 
% [Y_1_LOW,Y_1_HIGH] = makesubject_simple(1, J_HC,ntrials_Y_LOW,ntrials_Y_HIGH);
% [N_1_LOW,N_1_HIGH] = makesubject_simple(1, J_LC,ntrials_N_LOW,ntrials_N_HIGH);

%Analogue for makesubject
participants = [1,2,3,4,5,6,7,8,9,10,11,12,13,15,16,17,18,19,20];
Subject = cell(length(participants),4);
for i = participants
    %disp(size(J_HC))
    ntrials_Y_LOW = length(J_HC(J_HC(:,1)==1&J_HC(:,8)==i,:)); %recognised (>=3) and Low Imageability condition
    ntrials_Y_HIGH = length(J_HC(J_HC(:,1)==2&J_HC(:,8)==i,:));
    ntrials_N_LOW = length(J_LC(J_LC(:,1)==1&J_LC(:,8)==i,:));
    ntrials_N_HIGH = length(J_LC(J_LC(:,1)==2&J_LC(:,8)==i,:));
    
    [Y_LOW,Y_HIGH] = makesubject_simple(i, J_HC,ntrials_Y_LOW,ntrials_Y_HIGH);
    [N_LOW,N_HIGH] = makesubject_simple(i, J_LC,ntrials_N_LOW,ntrials_N_HIGH);
    
    Subject{i,1} = Y_LOW;
    Subject{i,2} = Y_HIGH;
    Subject{i,3} = N_LOW;
    Subject{i,4} = N_HIGH;
    
end

%Now I need to makelike, which gives us just the error and RTs (what the
%model fits need)

%I'm so so sorry for future me, the following seems unnecessarily complex. So the reason
%there need to be these weird as arguments is because I am splitting the
%data up by recognised (>=3) and unrecognised (<3). Because this split is
%dependent on how the individual participant used the rating numbers, the
%number of trials in each of these data subsets varies between
%participants. For this reason, Philip's existing code that specified a
%given number of trials in each condition needed to be modified.

Fit_Data = cell(length(participants),2); 
%First column is recognised items, second column is unrecognised items.
for i = participants
    Fit_Data{i,1} = makelike_simple(Subject{i,1},Subject{i,2},size(Subject{i,1}),size(Subject{i,2}));
    Fit_Data{i,2} = makelike_simple(Subject{i,3},Subject{i,4},size(Subject{i,3}),size(Subject{i,4}));
end
end
