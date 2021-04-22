function [Data1, Data2] = makesubject(sno, Alldata)
% ==============================================================================
% Make data structure for one subject for Jason Zhou's experiment.
%    [Data1, Data2] = makesubject(sno, Alldata)
%    Columns are subject, trialno, targtheta, rt, resptheta, error
% Maximum subject number is 15: missing 4, 6,
% ==============================================================================
ntrials1 = 320;  % Different numbers for Short and Long!
ntrials2 = 360;
Data1 = zeros(ntrials1, 6);
Data2 = zeros(ntrials2, 6);
t1 = 1;
t2 = 1;
sz = size(Alldata);
for i = 1:sz(1)
    if round(Alldata(i,1) == sno)  % Include this subject
         targtheta = Alldata(i,3);
         rt = Alldata(i,5);
         resptheta = Alldata(i,6);
         error = Alldata(i,7);
         if round(Alldata(i,4) == 1) % Long
             Data1(t1, 1) = sno;
             Data1(t1, 2) = t1;
             Data1(t1, 3) = targtheta;
             Data1(t1, 4) = rt;
             Data1(t1, 5) = resptheta;
             Data1(t1, 6) = error;
             t1 = t1 + 1;
        else % Short
             Data2(t2, 1) = sno;
             Data2(t2, 2) = t2;
             Data2(t2, 3) = targtheta;
             Data2(t2, 4) = rt;
             Data2(t2, 5) = resptheta;
             Data2(t2, 6) = error;
             t2 = t2 + 1;
       end
    end
end


