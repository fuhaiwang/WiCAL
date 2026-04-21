function [angel_all_cali_1] = Group_align(angel_all)

    angel_all_cali_1 = angel_all - angel_all(:,[1,1,1,6,6,6,8,8,8,10,10,10,15,15,15,18,18,18]);

    angel_all_cali_1(:,1:3) = angel_all_cali_1(:,1:3)+angel_all_cali_1(:,13);
    angel_all_cali_1(:,4:6) = angel_all_cali_1(:,4:6);
    angel_all_cali_1(:,7:9) = angel_all_cali_1(:,7:9)+angel_all_cali_1(:,17);
    angel_all_cali_1(:,10:12) = angel_all_cali_1(:,10:12) + angel_all_cali_1(:,16);









