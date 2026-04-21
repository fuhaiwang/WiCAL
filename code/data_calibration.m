%{
1.首先先对原始csi数据进行位置顺序矫正。
2.对每组内的初始相位和线路相位偏差校准。（天线间的初始相位差是由网卡决定的，相位斜率偏差是由子载波在不同线路长度引起的相位差）
3.对组间的连接天线的数据包相位对齐。（组间相位差主要是由 网卡随机采样不同步导致的相位偏差，斜率不同是包间飞行时间不同导致的相位差）
输出： 校准后的数据是，csi数据都与天线一子载波一 同步对齐。 可用于后续角度估计。
%}  

%{
1. First, perform positional order correction on the raw CSI data.
2. Calibrate the initial phase and cable/slope phase offsets within each group.
   (The initial phase difference between antennas is determined by the NIC,
   while the phase slope deviation is caused by varying cable lengths across subcarriers.)
3. Align the packet phases of the connection antennas between groups.
   (The inter-group phase difference is mainly due to random sampling asynchrony of the NIC,
   and the slope discrepancy is caused by different Time-of-Flight (ToF) between packets.)
Output:
   The calibrated CSI data is synchronized and aligned to Antenna 1, Subcarrier 1.
   This data is ready for subsequent angle estimation (e.g., MUSIC).
%}

function csi_cal_re = data_calibration(csi_entry1,csi_entry2,csi_entry3,csi_entry4,csi_entry5,csi_entry6,init_phase)
    
    csi_all_antenna1 = get_scaled_csi(csi_entry1);
    csi_1 = csi_all_antenna1(1, :, :);
    csi1 = squeeze(csi_1);

    csi_all_antenna2 = get_scaled_csi(csi_entry2);
    csi_2 = csi_all_antenna2(1, :, :);
    csi2 = squeeze(csi_2); 

    csi_all_antenna3 = get_scaled_csi(csi_entry3);
    csi_3 = csi_all_antenna3(1, :, :);
    csi3 = squeeze(csi_3);

    csi_all_antenna4 = get_scaled_csi(csi_entry4);
    csi_4 = csi_all_antenna4(1, :, :);
    csi4 = squeeze(csi_4);

    csi_all_antenna5 = get_scaled_csi(csi_entry5);
    csi_5 = csi_all_antenna5(1, :, :);
    csi5 = squeeze(csi_5); 

    csi_all_antenna6 = get_scaled_csi(csi_entry6);
    csi_6 = csi_all_antenna6(1, :, :);
    csi6 = squeeze(csi_6);

%    Step 1: Initial Phase Calibration (Initial antenna phase difference and cable length delay difference).
%    The slope represents the cable length, while the intercept corresponds to the initial phase difference.
    a_init_phase = exp(1j.*init_phase);
    csi_raw_all = [csi1;csi2;csi3;csi4;csi5;csi6];  
    csi_init_phase_cal = csi_raw_all .* a_init_phase.';

    % Step 2: Inter-group alignment
    angel_all = unwrap(angle(csi_init_phase_cal.')); 

    % Step 3:
    [phase_gap_new] = Group_align(angel_all);

    b_init_phase = exp(1j.*phase_gap_new);   
    csi_gap_cal = b_init_phase.';
    csi_cal = csi_gap_cal(1:12,:);

    csi_cal_re =csi_cal;
    csi_cal_phase = unwrap(angle(csi_cal.'));

    angle_bb = unwrap(angle(b_init_phase));























