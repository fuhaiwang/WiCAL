function [aoa_packet_data] = URA_ss_non(csi_trace_, Mx, My, Fc, sub_freq_delta, antenna_d, theta_vec,phi_vec,source_num,tau_vec,SubCarrInd)

%% DEBUG AND OUTPUT VARIABLES-----------------------------------------------------------------%%
    csi_cal = csi_trace_;
    [aoa_packet_data] = aoa2D_tof_music(...
            csi_cal, Mx, My, Fc, sub_freq_delta, antenna_d,theta_vec,phi_vec,source_num,tau_vec,SubCarrInd);  
end
%% 
function [Pmusic] = aoa2D_tof_music(csi, Mx, My, Fc, sub_freq_delta, antenna_d, theta_vec, phi_vec,source_num,tau_vec,SubCarrInd)
    P = size(csi,1);
    [M, N] = size(csi{1}); 
    c = 3e8; 
    wavelength = c/Fc; 
    B = sub_freq_delta*N;
    Pmusic = zeros(length(theta_vec),length(phi_vec),length(tau_vec));
    for ii = 1:length(theta_vec) 
        [smoothed_csi_y] = smooth_csi(csi, Mx, My, N); 
        smoothed_csi_y = smoothed_csi_y(:,1:16:end,1:15:end);

        if ndims(smoothed_csi_y) == 3
            [xx,yy] = size(squeeze(smoothed_csi_y(1,:,:)));
            Ry_all = zeros(P,xx,xx);
            for p = 1:P
                smoothed_csi_y_ = squeeze(smoothed_csi_y(p,:,:));
                Ry_all(p,:,:) = (smoothed_csi_y_ * smoothed_csi_y_')/size(smoothed_csi_y_,2);  %  P1-(1.13)
            end
            Ry = squeeze(sum(Ry_all,1))./size(Ry_all, 1);
        else
            Ry = (smoothed_csi_y * smoothed_csi_y')/size(smoothed_csi_y, 2);  %  P1-(1.13)
        end
        
        [eigenvectors, eigenvalue_matrix] = eig(Ry); 
        
        num_computed_paths = adaptive_threshold(eigenvalue_matrix,smoothed_csi_y,source_num,ii);
        [~ , lambda_index ] = sort(diag(eigenvalue_matrix),'descend');
        beta = eigenvectors(:, lambda_index);
        G = beta(:, num_computed_paths + 1: end);
        
        for kk = 1:length(phi_vec)  
            steering_vector = compute_steering_vector(theta_vec(ii), phi_vec(kk), wavelength, antenna_d, Mx, My); 
            PP = (steering_vector'*steering_vector)/real(steering_vector' * G * G' * steering_vector);  % MUSIC!! 
            Pmusic(ii, kk) = PP; 
        end
    end
end


function [smoothed_csi_y] = smooth_csi(csi_all, Mx, My, N) 
    num_packets = size(csi_all,1);
    csi = zeros(Mx*My*N, num_packets);
    for p = 1:num_packets
        xx = csi_all{p};
        for i=1:size(xx,1)
            a = xx(i,:).';
            csi((i-1)*N+1:i*N, p) = a;
        end
    end
    smoothed_csi_y = smooth_csi_y(csi, Mx, My, N);

end

function smoothed_csi = smooth_csi_y(csi_y, Mx, My, N)
    N_s= N/2;           
    y = csi_y; 
    num_packets = size(csi_y,2); 
    Mx_s = 2;
    My_s = 3;
    if N==1
        Y = y;
    else
        Y = zeros(num_packets,(N_s+1)*Mx_s*My_s,((Mx-Mx_s)+1)*((My-My_s)+1)*(N-N_s));
        B1 = zeros(Mx_s,N_s+1,My_s);
        y_ = y.';
        CSI_matrix = reshape(y_, num_packets, N*Mx, My);
        for p = 1:num_packets
            CSI_single = squeeze(CSI_matrix(p,:,:));
            CSI_smoothed = zeros((N_s+1)*Mx_s*My_s,((Mx-Mx_s)+1)*((My-My_s)+1)*(N-N_s));
            tmp = 1;
            for x_i = 1: Mx-Mx_s+1 
                for y_j = 1:My-My_s+1 
                    B = CSI_single( (x_i-1)*N+1:(x_i+(Mx_s-1))*N, y_j:y_j+(My_s-1));
                    for tau_k = 1:N_s
                        for ii = 1:Mx_s
                            B1(ii,:,:) = B((ii-1)*N + tau_k: (ii-1)*N + tau_k+N_s,:);
                        end
                        B2 = permute(B1, [2, 1, 3]);
                        CSI_Block = B2(:);
                        CSI_smoothed(:,tmp) = CSI_Block;
                        tmp = tmp + 1;
                    end
                end
            end
            Y(p,:,:) = CSI_smoothed;
        end
    end
    smoothed_csi = Y; 
end


function steering_vector_s = compute_steering_vector(theta, phi, wavelength, antenna_d, Mx, My) 
    Mx_s = Mx-1;
    My_s = My-1;
    d = antenna_d;
    lambda = wavelength;
    ax = exp(1j *2*pi*d/lambda * sin(theta/180*pi) * cos((phi)/180*pi) * (0:Mx_s-1)');
    ay = exp(1j *2*pi*d/lambda * sin(theta/180*pi) * sin((phi)/180*pi) * (0:My_s-1)');
    steering_vector_s = kron(ay, ax);
end














































































