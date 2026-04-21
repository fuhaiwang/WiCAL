function  [theta_gt_1_6_errormat, phi_gt_1_6_errormat] = look_figure(theta_gt,phi_gt, mark_peak)

mark_peak_theta1 = fliplr(rot90(reshape(mark_peak(1:40,1),[4,10])));
mark_peak_phi1 = fliplr(rot90(reshape(mark_peak(1:40,2),[4,10])));

mark_peak_theta2 = fliplr(rot90(reshape(mark_peak(41:80,1),[4,10])));
mark_peak_phi2 = fliplr(rot90(reshape(mark_peak(41:80,2),[4,10])));

mark_peak_theta3 = fliplr(rot90(reshape(mark_peak(81:110,1),[3,10])));
mark_peak_phi3 = fliplr(rot90(reshape(mark_peak(81:110,2),[3,10])));

mark_peak_theta4 = fliplr(rot90(reshape(mark_peak(111:150,1),[4,10])));
mark_peak_phi4 = fliplr(rot90(reshape(mark_peak(111:150,2),[4,10])));

mark_peak_theta5 = fliplr(rot90(reshape(mark_peak(151:190,1),[4,10])));
mark_peak_phi5 = fliplr(rot90(reshape(mark_peak(151:190,2),[4,10])));

mark_peak_theta6 = fliplr(rot90(reshape(mark_peak(191:210,1),[2,10])));
mark_peak_phi6 = fliplr(rot90(reshape(mark_peak(191:210,2),[2,10])));

mark_peak_theta1_6 = [mark_peak_theta3,mark_peak_theta2,mark_peak_theta1, mark_peak_theta6, mark_peak_theta5,mark_peak_theta4];
mark_peak_phi1_6 = [mark_peak_phi3,mark_peak_phi2,mark_peak_phi1, mark_peak_phi6, mark_peak_phi5,mark_peak_phi4];

theta_gt_1_6_errormat = abs(theta_gt - mark_peak_theta1_6);
phi_gt_1_6_errormat = abs(phi_gt - mark_peak_phi1_6);

index_phi = find(phi_gt_1_6_errormat (:)>180);
phi_gt_1_6_errormat(index_phi) = abs(phi_gt_1_6_errormat(index_phi) - 360);
phi_gt_1_6_errormat(5,11) = 0;

theta_gt_1_6_errormat(5,11) = 0;