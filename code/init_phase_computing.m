function init_phase_all = init_phase_computing(read_root_path,files)
    
    read_path = strcat(read_root_path,files.name);
    csi_trace = read_bf_file(read_path);
    csi_trace(cellfun(@isempty,csi_trace))=[]; 

    P = length(csi_trace);
    p_num = floor(P/6);
    init_phase_all = zeros(30,3*6);
    flag = 1;
    temp = 0;
    for p=1:p_num:P 
        loop = p; 
        angel1 = zeros(30,p_num);
        angel2 = zeros(30,p_num);
        angel3 = zeros(30,p_num);
        for i = loop:loop+p_num-1
            csi_entry = csi_trace{i};
            csi = get_scaled_csi(csi_entry); % extract the csi matrix 
            temp = temp + 1;
            angel1(:,temp) = unwrap(angle(squeeze(csi(1,1,:))));
            angel2(:,temp) = unwrap(angle(squeeze(csi(1,2,:)))); 
            angel3(:,temp) = unwrap(angle(squeeze(csi(1,3,:)))); 
        end
    
        
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
        

        %% 
        angel12_max = max(angel12(:));
        angel12_min = min(angel12(:));    
        if angel12_max - angel12_min > 3*pi/2 
            index = find(angel12(:)>0);
            angel12(index) = angel12(index) - 2*pi;
            angel12_fanzhe_med=median(angel12,2);
            if angel12_fanzhe_med < -pi
                angel12_fanzhe_med = angel12_fanzhe_med +2*pi;
            end
        else
            angel12_fanzhe_med = median(angel12,2);
        end
    
        angel13_max = max(angel13(:));
        angel13_min = min(angel13(:));    
        if angel13_max - angel13_min > 3*pi/2 
            index = find(angel13(:)>0);
            angel13(index) = angel13(index) - 2*pi;
            angel13_fanzhe_med=median(angel13,2);
            if angel13_fanzhe_med < -pi
                angel13_fanzhe_med = angel13_fanzhe_med +2*pi;
            end
        else
            angel13_fanzhe_med = median(angel13,2);
        end
        

        antenna_sub_angel11 = zeros(30,1);
        antenna_sub_angel12 = angel12_fanzhe_med;
        antenna_sub_angel13 =angel13_fanzhe_med;
        antenna_sub_angel12 = median(antenna_sub_angel12,"all")*ones(30,1);
        antenna_sub_angel13 = median(antenna_sub_angel13,"all")*ones(30,1);
        
    
        init_phase = [antenna_sub_angel11, antenna_sub_angel12, antenna_sub_angel13];
        
        init_phase_all(:,(flag-1)*3+1:flag*3) = init_phase;
        flag = flag + 1;
        temp = 0;
    end








