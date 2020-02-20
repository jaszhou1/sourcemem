time_density = MX_LL_Preds_Recognised{1, 3}{1};
theta_density = MX_LL_Preds_Recognised{1, 3}{3};
joint_density = theta_density(2,:)' * time_density(2,:);
joint_distribution = cumsum(joint_density, 2);
cum_joint_distribution = joint_distribution ./ max(joint_distribution, 1);

contour(theta_density(1, :), time_density(1, :), (joint_distribution ./ max(joint_distribution, 1))')