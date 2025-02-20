function [R, t, E] = computeAnalyticalRTandE(R1, R2, cam1_position, cam2_position)
    % Compute translation vector t (normalized)
    t = (cam2_position - cam1_position)';
    t_norm = t / norm(t); % Normalize t
    
    % Compute relative rotation matrix
    R = R2 * R1'; % Rotation from Camera 1 to Camera 2
    
    % Compute skew-symmetric cross-product matrix of t
    t_cross = [  0,   -t_norm(3),  t_norm(2);
                t_norm(3),    0,  -t_norm(1);
               -t_norm(2),  t_norm(1),   0 ];
    
    % Compute Essential Matrix
    E = t_cross * R;
end