function [m, after_Trans_phase] = Trans_phase(row,flag,pha_csi_ant_60sub_time,self_calibration)  

pha_csi_ant_60sub_time_ = pha_csi_ant_60sub_time;

m0=-58:4:58;%30  116


calibration = self_calibration;
if length(calibration) ~= 1
    m = m0 - calibration'/0.13 *0.3; 
else
    m = m0;
end

for t_ = 1 : row
    k = (pha_csi_ant_60sub_time_(30,t_) - pha_csi_ant_60sub_time_(1,t_))./116;
    b = sum(pha_csi_ant_60sub_time_(:,t_))/30;
    for i_sub=1:30
%         after_Trans_phase(i_sub,t_) = pha_csi_ant_60sub_time_(i_sub,t_)-b; %linear transformation
        after_Trans_phase(i_sub,t_) = pha_csi_ant_60sub_time_(i_sub,t_)- k*m(i_sub)-b; %linear transformation
    end
end

















%%
% pha_csi_ant_60sub_time_ = pha_csi_ant_60sub_time;
% m=[-28:2:-2,-1,1:2:27,28];%30
% % m=[-58:4:58];% 116 
% 
% % phase
% % t_ = 1;
% for t_ = 1 : row
%     k = (pha_csi_ant_60sub_time_(30,t_) - pha_csi_ant_60sub_time_(1,t_))./56;
%     b = sum(pha_csi_ant_60sub_time_(:,t_))/30;
%     for i_sub=1:30
%         after_Trans_phase(i_sub,t_) = pha_csi_ant_60sub_time_(i_sub,t_) - k*m(i_sub)-b; %linear transformation
%     end
% end

% https://blog.csdn.net/a_beatiful_knife/article/details/119247331