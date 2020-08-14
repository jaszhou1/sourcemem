function [Fit_Data] = conf_data()
%CONF_DATA Reads in filtered data, and structures it into high and low
%confidence datasets, pooled across imageability ratings, for each participant

load('dataFiltered3.mat'); % Filtered version
J1(:,1) = [];
%Split high and low recog conf

J_HC = J1(J1(:,2)==6,:);
J_LC = J1(J1(:,2)>3,:);
J_LC = J_LC(J_LC(:,2)<6,:);

%Conditions: 1 is LOW, 2 is HIGH

participants = [1,2,3,4,5,6,7,8,9,10,11,12,13,15,16,17,18,19,20];
Subject = cell(length(participants),2);
for i = participants
    %disp(size(J_HC))
    ntrials_Y_LOW = length(J_HC(J_HC(:,1)==1&J_HC(:,8)==i,:)); %recognised (>=3) and Low Imageability condition
    ntrials_Y_HIGH = length(J_HC(J_HC(:,1)==2&J_HC(:,8)==i,:));
    ntrials_N_LOW = length(J_LC(J_LC(:,1)==1&J_LC(:,8)==i,:));
    ntrials_N_HIGH = length(J_LC(J_LC(:,1)==2&J_LC(:,8)==i,:));
    
    [Y_LOW,Y_HIGH] = makesubject_simple(i, J_HC,ntrials_Y_LOW,ntrials_Y_HIGH);
    [N_LOW,N_HIGH] = makesubject_simple(i, J_LC,ntrials_N_LOW,ntrials_N_HIGH);
    
    Subject{i,1} = vertcat(Y_LOW,Y_HIGH);
    Subject{i,2} = vertcat(N_LOW,N_HIGH);    
end

% Extract response error and RTs

Fit_Data = cell(length(participants),1); 
%First column is recognised items, second column is unrecognised items.
for i = participants
    Fit_Data{i,1} = makelike_simple(Subject{i,1},Subject{i,2},size(Subject{i,1}),size(Subject{i,2}));
end
end


