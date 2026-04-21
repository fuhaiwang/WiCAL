% clc; clear; close all;
function [angel12_avg, angel13_avg, m_calibrated] = test_initial_phase_calibration_test3(read_root_path, files)

    for index_num = 1:length(files)
        read_path = strcat(read_root_path,files(index_num).name);
        csi_trace = read_bf_file(read_path);
        csi_trace(cellfun(@isempty,csi_trace))=[];  % 
        row = size(csi_trace, 1);                   % the number of data packets
        loop = row;
        if loop>100
            loop = 200;
        end

        temp = 0;        
        start_index = 1;
        rssi_a_ = zeros(loop-start_index,1);
        rssi_b_ = zeros(loop-start_index,1);
        rssi_c_ = zeros(loop-start_index,1);
        csi_ant_ =zeros(3, loop-start_index);

        angel1 = zeros(30,loop-start_index);
        angel2 = zeros(30,loop-start_index);
        angel3 = zeros(30,loop-start_index);


        for i = start_index :loop
            csi_entry = csi_trace{i};
            rssi_a_(i) = csi_entry.rssi_a;
            rssi_b_(i) = csi_entry.rssi_b;
            rssi_c_(i) = csi_entry.rssi_c;
    
            csi = get_scaled_csi(csi_entry); % extract the csi matrix 
            csi_dim = size(csi);
            if csi_dim(2)==3  
                temp = temp + 1;
            end
            csi_ant = squeeze(csi(1,:,1));  
            angel1(:,i-start_index+1) = unwrap(angle(squeeze(csi(1,1,:)))); 
            angel2(:,i-start_index+1) = unwrap(angle(squeeze(csi(1,2,:)))); 
            angel3(:,i-start_index+1) = unwrap(angle(squeeze(csi(1,3,:))));
        end            
    end

%     figure
%     subplot(1,3,1)
%     plot(angel1);
%     subplot(1,3,2)
%     plot(angel2);
%     subplot(1,3,3)
%     plot(angel3);
%     legend('angel1','angel2','angel3')

%     figure
%     subplot(1,3,1)
%     plot(angel1.');
%     subplot(1,3,2)
%     plot(angel2.');
%     subplot(1,3,3)
%     plot(angel3.');
%     legend('angel1','angel2','angel3')

    %%
    [~, angel1_subfreq_calibration] = Trans_phase(loop-start_index,1,angel1,0);
    [~, angel2_subfreq_calibration] = Trans_phase(loop-start_index,2,angel2,0);
    [~, angel3_subfreq_calibration] = Trans_phase(loop-start_index,3,angel3,0);

    angel1_ = angel1_subfreq_calibration;
    angel2_ = angel2_subfreq_calibration;
    angel3_ = angel3_subfreq_calibration;

    %%
%     figure
%     subplot(1,3,1)
%     plot(angel1_);
%     subplot(1,3,2)
%     plot(angel2_);
%     subplot(1,3,3)
%     plot(angel3_);
%     legend('angel1','angel2','angel3')
%     figure
%     subplot(1,3,1)
%     plot(angel1_.');
%     subplot(1,3,2)
%     plot(angel2_.');
%     subplot(1,3,3)
%     plot(angel3_.');
%     legend('angel1','angel2','angel3')

    angel1_mean = round(mean(angel1_,2),3);
    angel2_mean = round(mean(angel2_,2),3);
    angel3_mean = round(mean(angel3_,2),3);

    [m_calibrated1, angel1_subfreq_self_calibration] = Trans_phase(loop-start_index,1,angel1,angel1_mean);
    [m_calibrated2, angel2_subfreq_self_calibration] = Trans_phase(loop-start_index,2,angel2,angel2_mean);
    [m_calibrated3, angel3_subfreq_self_calibration] = Trans_phase(loop-start_index,3,angel3,angel3_mean);
    
    m_calibrated = (m_calibrated1 + m_calibrated2)/2;

    angel1 = angel1_subfreq_self_calibration;
    angel2 = angel2_subfreq_self_calibration;
    angel3 = angel3_subfreq_self_calibration;
    %%
    angel1_mean_new = round(mean(angel1,2),3);
    angel2_mean_new = round(mean(angel2,2),3);
    angel3_mean_new = round(mean(angel3,2),3);

    %%
    angel12 = angel1 - angel2;
    angel13 = angel1 - angel3;

    if angel12(angel12<-pi)
        index_ = find(angel12<-pi); 
        index_n = fix( (angel12(index_)+pi) /(2*pi))-1;
        angel12(index_) = angel12(index_) - 2*pi*index_n; 
    end

    if angel12(angel12>pi)
        index_ = find(angel12>pi);
        index_n = fix((angel12(index_)-pi)/(2*pi))+1; 
        angel12(index_) = angel12(index_) - 2*pi*index_n;
    end


    if angel13(angel13<-pi) 
        index_ = find(angel13<-pi);
        index_n = fix( (angel13(index_)+pi) /(2*pi))-1;
        angel13(index_) = angel13(index_) - 2*pi*index_n;
    end

    if angel13(angel13>pi)
        index_ = find(angel13>pi);
        index_n = fix((angel13(index_)-pi)/(2*pi))+1; 
        angel13(index_) = angel13(index_) - 2*pi*index_n;
    end


    angel12_max = max(angel12(:));
    angel12_min = min(angel12(:));    
    if angel12_max - angel12_min > 3*pi/2 
        index = find(angel12(:)>0);
        angel12(index) = angel12(index) - 2*pi;
        angel12_fanzhe_med=median(angel12(:));
        if angel12_fanzhe_med < -pi
            angel12_fanzhe_med = angel12_fanzhe_med +2*pi;
        end
    else
        angel12_fanzhe_med = median(angel12(:));
    end

    angel13_max = max(angel13(:));
    angel13_min = min(angel13(:));    
    if angel13_max - angel13_min > 3*pi/2 
        index = find(angel13(:)>0);
        angel13(index) = angel13(index) - 2*pi;
        angel13_fanzhe_med=median(angel13(:));
        if angel13_fanzhe_med < -pi
            angel13_fanzhe_med = angel13_fanzhe_med +2*pi;
        end
    else
        angel13_fanzhe_med = median(angel13(:));
    end
    
    angel12_avg = angel12_fanzhe_med;
    angel13_avg = angel13_fanzhe_med;
    
end




















