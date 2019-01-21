%% Open Data

%Opens and organises the data into recognised/unrecognised and low/high imageability
%Fit_Data = Treatment_Simple('stimulus.xlsx'); 
%This is real slow, so I
%have Jindiv_simple for my data set. For future use, switch this on, and
%the following line off. You will need to do this in Treatment_Simple as
%well.
Group_Data = GroupTreatment;

Unrecognised = Group_Data(:,1);
Recognised = Group_Data(:,2);

%Fit the data, generate predictions.

[ll, bic, Pred, pest] = FitVP(Unrecognised{1});

[ll, bic, Pred, pest] = FitVP(Recognised{1});

[ll, bic, Pred, pest] = FitMix(Recognised{1});

[ll, bic, Pred, pest] = FitMix(Unrecognised{1});