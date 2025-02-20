function [R1, R2, t1, t2] = decomposeEssentialMatrix(E, varargin)
    % Step 1: Compute SVD of Essential Matrix
    [U, ~, V] = svd(E);
    
    % Ensure determinant is positive to maintain a valid rotation matrix
    if det(U) < 0, U = -U; end
    if det(V) < 0, V = -V; end
    
    % Step 2: Define the special W matrix
    W = [0 -1 0; 1 0 0; 0 0 1];

    % Step 3: Compute Two Possible Rotations
    R1 = U * W * V';
    R2 = U * W' * V';

    % Ensure R1 and R2 are valid rotation matrices (det(R) should be +1)
    if det(R1) < 0, R1 = -R1; end
    if det(R2) < 0, R2 = -R2; end

    % Step 4: Extract Two Possible Translations
    t1 = U(:,3);
    t2 = -U(:,3);  % Translation is defined up to scale
    
    if isscalar(varargin)
            % Display results for debugging
            disp('Possible Rotation Matrices:');
            disp('R1 = '); disp(R1);
            disp('R2 = '); disp(R2);
            disp('Possible Translation Vectors:');
            disp('t1 = '); disp(t1);
            disp('t2 = '); disp(t2);
    end
end
