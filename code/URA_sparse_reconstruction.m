function [p_SR] = URA_sparse_reconstruction(csi_y, Mx, My, d, wavelength, theta_vec,phi_vec)

    theta_vec = 0:1:90;     %  
    phi_vec = -180:1:180;   % 
    temp = 0;
    for i=1:length(phi_vec)
        for j=1:length(theta_vec) 
            temp = temp + 1; 
            ax = exp(1i*2*pi*d/wavelength*sind(theta_vec(j)).*(cosd(phi_vec(i))*(0:Mx-1)')); 
            ay = exp(1i*2*pi*d/wavelength*sind(theta_vec(j)).*(sind(phi_vec(i))*(0:My-1)')); 
            A(:,temp) = kron(ay, ax); 
        end 
    end 

    M = length(phi_vec)*length(theta_vec);

    lambda = 0.05;

    epsilon = 0.001 * norm(csi_y(:,1), 2);
    cvx_begin
        variable s(M, 1) complex;
        minimize(norm(s, 1));
        subject to
            norm(A * s - csi_y(:,1), 2) <= epsilon;
    cvx_end

    p_SR = reshape(abs(s),length(theta_vec),length(phi_vec));
end







