clc; clear; close all;  

xx = 1.97:-0.2:0.17;
yy = 2:-0.2:-2;
zz = 2;

[X,Y,Z] = meshgrid(xx,yy,zz);

[azimuth,elevation,r] = cart2sph(X-0.97,Y,Z);
theta_gt = 90-rot90(elevation.',2)/pi*180;
phi_gt = rot90(azimuth,1)/pi*180;

figure 
heatmap(theta_gt)
set(gcf,'Position',[800,100,900,400])
title('theta');

figure 
heatmap(phi_gt)
set(gcf,'Position',[800,600,900,400])
title('phi');

% Set the true values based on the position.
colRanges = {
    8:11,   % 
    4:7,    %
    1:3,    % 
    18:21,  %
    14:17,  % 
    12:13   %
};

theta_vecs = cell(1,6);
phi_vecs   = cell(1,6);

for i = 1:6
    cols = colRanges{i};

    % theta
    theta_tmp = rot90(flipud(theta_gt(:, cols)), 1);
    theta_vecs{i} = theta_tmp(:);

    % phi
    phi_tmp = rot90(flipud(phi_gt(:, cols)), 1);
    phi_vecs{i} = phi_tmp(:);
end

% theta_phi_gt 
theta_phi_gt = [
    theta_vecs{1}, phi_vecs{1};
    theta_vecs{2}, phi_vecs{2};
    theta_vecs{3}, phi_vecs{3};
    theta_vecs{4}, phi_vecs{4};
    theta_vecs{5}, phi_vecs{5};
    theta_vecs{6}, phi_vecs{6}
];

%%  % Data used for calibaration
read_root_path = '.\data\test.2024.9.5\'; 
files_for_calibration = dir([char(strcat(read_root_path)), '21_1.1.dat']); 

mark_p_coloc = zeros(210,2);
mark_p_MUSIC_ss = zeros(210,2);
mark_p_MUSIC_ss_non = zeros(210,2);
mark_peak_SPICE  = zeros(210,2);
mark_peak_SPICE_N = zeros(210,2);
mark_p_MUSIC_imusic_non = zeros(210,2);
mark_p_MUSIC_imusic = zeros(210,2);
mark_p_MUSIC_non_music = zeros(210,2);
mark_p_MUSIC_music = zeros(210,2);

tic

% i: index=1-190, calibration data = 21-1.1.dat; index=191-210,calibration data=21_1-6.dat    202
% You can select arbitrary data for estimation testing $i$ using the MUSIC algorithm.
for i = 1:3       
    disp(i)
    tic
    files_raw_csi = dir([char(strcat(read_root_path)), num2str(i), '_1.dat']);  
    %% data loader
    disp("1. Is loading...");
    [csi_all] = data_loader(read_root_path,files_raw_csi);
    %% 
    if i >= 191
        files_for_calibration = dir([char(strcat(read_root_path)), '21_1.2.dat']); 
    end
    disp("2. Is computing init_phase_dif...");
    init_phase_cumulant = init_antenna_subcarrier_phase_dif(read_root_path,files_for_calibration); 
    %% Multi-packet acquisition and calibration
    disp("3. Is calibrating...");
    temp = 1;
    cali_num = 0;
    for pp = 300 : 20 :500
        %% data calibration ： 
        csi_cal = data_calibration(csi_all{pp},csi_all{pp+1000},csi_all{pp+2000},csi_all{pp+3000},csi_all{pp+4000},csi_all{pp+5000},init_phase_cumulant); % 1.Remove the initial phase
        if csi_cal == 0
            cali_num = cali_num+1;
            continue
        end
        csi_trace_real{temp,:} = csi_cal;
        temp = temp + 1;
    end
    %% Set system parameters
    Fc = (5.2e9+5.18e9)/2;  
    c = 3e8;
    wavelength = c/Fc;  
    d = wavelength/(1+sind(60));   
    Mx = 3; 
    My = 4; 
    
    N = 30;   
    sub_freq_delta_ = 312.5e3;
    sub_freq_delta = sub_freq_delta_*4;  % kHz  
    m0=-58:4:58;
    num_packets = 20;
    
    theta_vec = 0:0.5:90;     
    phi_vec = -180:0.5:180;   
    theta_vec_spice=0:1:90;  
    phi_vec_spice = -180:1:180;

    Q = length(theta_vec)*length(phi_vec);
    B = sub_freq_delta*N; 
    ToF = 1/(2*B);
    d_res = ToF*c;
    tau_vec = (1:1:20)*(d_res/10/c);
    
    [csi_y_N] = cook_csi(csi_trace_real, Mx, My, N);

    R = zeros(30,Mx*My,Mx*My);
    for kk=1:30
        R(kk,:,:) = csi_y_N(kk:30:end,:)*csi_y_N(kk:30:end,:)'/size(csi_y_N, 2);
    end
    Ry_N = squeeze(mean(R,1));


    csi_y = csi_y_N(15:30:end,:);
    if ndims(csi_y) == 3
            [xx,yy] = size(squeeze(csi_y(1,:,:)));
            Ry_all = zeros(P,xx,xx);
            for p = 1:P
                csi_y_ = squeeze(csi_y(p,:,:));
                Ry_all(p,:,:) = (csi_y_ * csi_y_')/size(csi_y_,2);  
            end
            Ry = squeeze(sum(Ry_all,1))./size(Ry_all, 1);
    else
        Ry = (csi_y * csi_y')/size(csi_y, 2); 
    end
    Rx1 = Ry; 

    smoothed_csi1 = smooth_csi_y(csi_y, Mx, My, 1);
    P = size(smoothed_csi1,1);
    if ndims(smoothed_csi1) == 3
        [xx,yy] = size(squeeze(smoothed_csi1(1,:,:)));
        Ry_all = zeros(P,xx,xx);
        for p = 1:P
            smoothed_csi_y_ = squeeze(smoothed_csi1(p,:,:));
            Ry_all(p,:,:) = (smoothed_csi_y_ * smoothed_csi_y_')/size(smoothed_csi_y_,2); 
        end
        Ry_ss1 = squeeze(sum(Ry_all,1))./size(Ry_all, 1);
    end

    theta_in = [17.7]/180*pi;      
    phi_in   = [-90]/180*pi;  
    % l_in     = [2];                
    source_num = length(theta_in); 
    % tau = l_in/c;
    % Coherent_signal_flag = 1;  % 0=Incoherent，1=coherent
    % csi_trace_ = OFDM_data_URA_generation(phi_in, theta_in, l_in, d, wavelength, Fc, sub_freq_delta_, m0, Mx, My, N, num_packets, Coherent_signal_flag);
    % exsample_csi = csi_trace_{1};

    SubCarrInd = m0;
    % 
    [p_MUSIC_ss_non] = URA_ss_non(csi_trace_real, Mx, My, Fc,sub_freq_delta_,d, theta_vec,phi_vec,source_num,tau_vec,SubCarrInd);

    figure
    s = surf(phi_vec,theta_vec,  10 * ((p_MUSIC_ss_non(:,:,1)))); 
    s.EdgeColor = 'none';
    axis tight; 
    set(gca, 'FontSize', 12); 
    xlabel('$\phi ^\circ$', 'Interpreter', 'latex', 'FontSize',15)
    ylabel('$\Theta ^\circ$', 'Interpreter', 'latex', 'FontSize',15)
    title('$P_{Music}$','Interpreter','latex');
  
    toc
end
toc


function [cooked_csi_y] = cook_csi(csi_all, Mx, My, N) 
    N = 30;
    num_packets = size(csi_all,1);
    csi = zeros(Mx*My*N, num_packets);
    for p = 1:num_packets
        xx = csi_all{p};
        for i=1:size(xx,1)
            a = xx(i,:).';
            csi((i-1)*N+1:i*N, p) = a; 
        end
    end
    cooked_csi_y = csi;
end  


function smoothed_csi = smooth_csi_y(csi_y, Mx, My, N)         
    y = csi_y; 
    num_packets = size(csi_y,2); 
    Mx_s = 2;
    My_s = 3;
    if N==1
        N_s = 1;
        Y = zeros(num_packets,(N_s)*Mx_s*My_s,((Mx-Mx_s)+1)*((My-My_s)+1)*(N_s));
        y_ = y.';
        CSI_matrix = reshape(y_, num_packets, N*Mx, My);
        for p = 1:num_packets
            CSI_single = squeeze(CSI_matrix(p,:,:));
            CSI_smoothed = zeros((N_s)*Mx_s*My_s,((Mx-Mx_s)+1)*((My-My_s)+1)*(N_s));
            tmp = 1;
            for x_i = 1: Mx-Mx_s+1      
                for y_j = 1:My-My_s+1  
                    B = CSI_single( (x_i-1)*N+1:(x_i+(Mx_s-1))*N, y_j:y_j+(My_s-1));
                    CSI_Block = B(:);

                    CSI_smoothed(:,tmp) = CSI_Block;
                    tmp = tmp + 1;
                end
            end
            Y(p,:,:) = CSI_smoothed;
        end
    end
    smoothed_csi = Y; 
end





