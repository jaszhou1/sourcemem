participants = [1,2,3,4,5,6,7,8,9,10,11,12,13,15,16,17,18,19,20];

jointDist = cell(length(participants),1);

for i = participants
time_density = GVM_LL_Preds_Recognised{i, 3}{1};
theta_density = GVM_LL_Preds_Recognised{i, 3}{3};
joint_density = theta_density(2,:)' * time_density(2,:);
joint_distribution = cumsum(joint_density, 2);
jointDist{i,:} = joint_distribution ./ max(joint_distribution, 1);

filename = [num2str(i),'time','.csv'];
csvwrite(filename,time_density);

filename = [num2str(i),'theta','.csv'];
csvwrite(filename,theta_density);

filename = [num2str(i),'jointDist','.csv'];
csvwrite(filename,joint_distribution);

end
contour(theta_density(1, :), time_density(1, :), (joint_distribution ./ max(joint_distribution, 1))')