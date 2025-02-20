function intrinsics = K_2_cameraIntrinsics(K, frame_width, frame_height)
    % Given intrinsic matrix K
    % K = [fx,  0, cx;
    %       0, fy, cy;
    %       0,  0,  1];

    % Extract parameters
    focalLength = [K(1,1), K(2,2)]; % [fx, fy]
    principalPoint = [K(1,3), K(2,3)]; % [cx, cy]
    
    % Define the image size (width and height in pixels)
    imageSize = [frame_width, frame_height]; % Replace with actual values
    
    % Create the cameraIntrinsics object
    intrinsics = cameraIntrinsics(focalLength, principalPoint, imageSize);
end