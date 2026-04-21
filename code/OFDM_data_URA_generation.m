% OFDM_data_generation
function csi_trace = OFDM_data_URA_generation(phi_in, theta_in, l_in, d, lambda, Fc, sub_freq_delta, m0, Mx, My, N, num_packets, s_coh_flag)        

Num_Source = length(phi_in);
csi_trace = cell(num_packets,1);

SNR = 50;
sigma2 = 0.0001;               
SN = sigma2 * 10^(SNR/10);

S = sqrt(SN)*randn(1,1);   

kd = 2*pi*d/lambda;
c = 3e8;
tau = l_in/c;
for i=1:Num_Source
    ax = exp(-1i*2*pi*d/lambda*sin(theta_in(i)).*(cos(phi_in(i)-pi)*(0:Mx-1)'));
    ay = exp(-1i*2*pi*d/lambda*sin(theta_in(i)).*(sin(phi_in(i)-pi)*(0:My-1)')); 
    a = kron(ay, ax);
    time_phase = exp(-1i * 2 * pi * sub_freq_delta * tau(i)).^m0; 
    steering_vector = kron(a, time_phase.'); 
    A(:,i) = steering_vector; 
end

W = complex(randn(Mx*My,N), randn(Mx*My,N));
Xn = sqrt(sigma2/2)*W; 

if s_coh_flag==0   
    for num_packets_index = 1:num_packets
        S1 = (randn(Num_Source, 1) + ( 1i * randn(Num_Source, 1))) .* sqrt(SN/2);
        noise  = (randn(Mx*My*N, 1) + ( 1i * randn(Mx*My*N, 1))) * (sqrt(sigma2/2));
        csi_ = A*S1 + noise;
        csi = zeros(Mx*My,N);
        for n = 1:N
            csi(:, n) = csi_(n:N:end);
        end
        csi_trace{num_packets_index} = csi;
    end
else              
    for num_packets_index = 1:num_packets
        S1 = ones(Num_Source, 1).* sqrt(SN);
        noise  = (randn(Mx*My*N, 1) + ( 1i * randn(Mx*My*N, 1))) * (sqrt(sigma2/2));
        csi_ = A*S1 + noise;
        csi = zeros(Mx*My,N);
        for n = 1:N
            csi(:, n) = csi_(n:N:end);
        end
        csi_trace{num_packets_index} = csi;
    end
end
































