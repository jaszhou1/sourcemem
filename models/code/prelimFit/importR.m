function [Fit_Data] = importR(data)
[J1, J2, J3] = xlsread(data);
%Empty array for Participant data structures to live

participants = [1,2,3,4,5,6,7,8,9,10,11,12,13,15,16,17,18,19,20];
Subject = cell(length(participants),2);
for i = participants
    [LOW,HIGH] = makesubject(i,J1);
    Subject{i,1} = LOW;
    Subject{i,2} = HIGH;
end

%Now I need to makelike, which gives us just the error and RTs (what the
%model fits need)

Fit_Data = cell(length(participants),1); 
for i = participants
    Fit_Data{i,1} = makelike(Subject{i,1},Subject{i,2});
end
end


% 
% D1 = makelike(D1a,D1b);
% D2 = makelike(D2a,D2b);
% D3 = makelike(D3a,D3b);
% D4 = makelike(D4a,D4b);
% D5 = makelike(D5a,D5b);
% D6 = makelike(D6a,D6b);
% D7 = makelike(D7a,D7b);
% D8 = makelike(D8a,D8b);
% D9 = makelike(D9a,D9b);
% D10 = makelike(D10a,D10b);
% D11 = makelike(D11a,D11b);
% D12 = makelike(D12a,D12b);
% D13 = makelike(D13a,D13b);
% D15 = makelike(D15a,D15b);
% D16 = makelike(D16a,D16b);
% D17 = makelike(D17a,D17b);
% D18 = makelike(D18a,D18b);
% D19 = makelike(D19a,D19b);
% D20 = makelike(D10a,D20b);
