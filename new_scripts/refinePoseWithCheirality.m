function [R_final, t_final] = refinePoseWithCheirality(R1, R2, t1, t2, proj1, proj2, K)
    P1 = K * [eye(3), zeros(3,1)]; % Reference camera projection matrix
    
    % Four possible (R, t) pairs
    candidates = {
        {R1, t1}, {R1, t2},
        {R2, t1}, {R2, t2}
    };
    
    best_count = 0;
    R_final = R1;
    t_final = t1;
    
    % Test all candidates to see which has the most points in front of both cameras
    for i = 1:4
        R_test = candidates{i}{1};
        t_test = candidates{i}{2};
        P2_test = K * [R_test, t_test];
        
        % Triangulate 3D points
        points3D = triangulate(proj1(:,1:2), proj2(:,1:2), P1', P2_test');
        
        % Count number of points with positive depth in both cameras
        num_in_front = sum(points3D(:,3) > 0);
        
        if num_in_front > best_count
            best_count = num_in_front;
            R_final = R_test;
            t_final = t_test;
        end
    end
end
