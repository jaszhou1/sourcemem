load('Jindiv_Simple.mat');
J1 = J1(J1(:,8)~=1,:);
J1 = J1(J1(:,8)~=9,:);
J1 = J1(J1(:,8)~=13,:);
J1 = J1(J1(:,8)~=15,:);
J1 = J1(J1(:,8)~=17,:);

J1 = J1(J1(:,7)>0.25,:);
%Split high and low recog conf

%Split by Confidence
J_HC = J1(J1(:,2)>=3,:);
J_LC = J1(J1(:,2)<3,:);

%Split by Condition
Y_LOW = J_HC(J_HC(:,1)==1,:); %recognised (>=3) and Low Imageability condition
Y_HIGH = J_HC(J_HC(:,1)==2,:);
N_LOW = J_LC(J_LC(:,1)==1,:);
N_HIGH = J_LC(J_LC(:,1)==2,:);

lowRecog(:,1) = Y_LOW(:,6);
lowRecog(:,2) = Y_LOW(:,7);
highRecog(:,1) = Y_HIGH(:,6);
highRecog(:,2) = Y_HIGH(:,7);
lowUnrecog(:,1) = N_LOW(:,6);
lowUnrecog(:,2) = N_LOW(:,7);
highUnrecog(:,1) = N_HIGH(:,6);
highUnrecog(:,2) = N_HIGH(:,7);



groupRecognised{1,1} = lowRecog;
groupRecognised{1,2} = highRecog;
groupUnrecognised{1,1} = lowUnrecog;
groupUnrecognised{1,2} = highUnrecog;
