clear;clc;clf;

%% Read in files
folder_path = "/Users/nbonnie/Desktop/3d_test/pyralis_20240608";
addpath(genpath(folder_path))
fnames = dir(strcat(folder_path,"/*.mat"));
data1 = load(strcat(folder_path, "/",fnames(1).name));
data2 = load(strcat(folder_path, "/",fnames(2).name));


%% Loads in corresponding data, extracts information needed
fns1 = fieldnames(data1);
fns2 = fieldnames(data2);

df1 = data1.(fns1{1}).xyt;
df2 = data2.(fns2{1}).xyt;
c1n = data1.(fns1{1}).n;
c2n = data2.(fns2{1}).n;

try
    frame_width = size(data1.ff.bkgrStack,2);
    frame_height = size(data1.ff.bkgrStack,1);
catch
    frame_width = 1920;
    frame_height = 1080;
    disp("Warning: Movie information not read in from files")
end

%% This is where you would remove persistent objects

%% Load in functions
addpath(genpath("/Users/nbonnie/Desktop/3D_reconstruction_sandbox/calfree_scripts"))
addpath(genpath("/Users/nbonnie/Desktop/3D_reconstruction_sandbox/new_scripts"))
addpath(genpath("/Users/nbonnie/Desktop/3D_reconstruction_sandbox/validation"))

%% Calculates the time difference in frames
dk = dkRobust(c1n, c2n);
disp(strcat("Frame delta: ",string(dk)))
fprintf("\n\n")

%% Find all 1-flash-frames to calibrate on:
calTraj = extractCalibrationTrajectories(df1,df2,dk);

%% Pull in camera intrinsic matrix and create CameraIntrinsics variable
load('sony_camera_parameters.mat')
K = sony_camera_parameters.CameraParameters1.K; % Theoretically this should be the same for every camera-lens pair
intrinsics = K_2_cameraIntrinsics(K, 1920, 1080);

%% Calculate F matrix
% normalize to get third coordinate equal to 1 (see Matlab doc)
points1 = calTraj.j1(:,1:2)./calTraj.j1(:,3);
points2 = calTraj.j2(:,1:2)./calTraj.j2(:,3);

% calculate fundamental matrix
F  = estimateFundamentalMatrix(points1, points2, 'Method', 'Norm8Point');


%% Estimate R, t (with constraint), and E
[R, t]= estimate_R_with_t_constraint(calTraj.j1(:,1:2), calTraj.j2(:,1:2), intrinsics);
distance_between_camera_meters = 5;

% Scale traslation matrix to use real world units
t2 = t2 ./ (1/distance_between_camera_meters);

% Store parameters for matching
stereoParams.t = -t;
stereoParams.R = R;
stereoParams.F = F;

%% Match Points
fprintf('Beginning point matching and triangulation...\nStart time: %s\n',datetime('now'))
% Finds matching points frame by frame after solving epipolar constraint
[matched_points_1,matched_points_2]=matchStereo(df1, df2, stereoParams, dk, 10000);

%% Triangulate
P1 = K * [eye(3), zeros(3,1)];
P2 = K * [stereoParams.R, stereoParams.t];
xyz = triangulate(matched_points_1(:,1:2), matched_points_2(:,1:2), P1', P2');
xyzt = [xyz, matched_points_1(:,3)];

% Flip back from camera coordinates (-x,z,y) to real coordinates (x,y,z)
xyzt(:,1) = -xyzt(:,1);
xyzt(:, [2, 3]) = xyzt(:, [3, 2]);

%% Plot
figure;
scatter3( xyzt(:,1) , xyzt(:,2) , xyzt(:,3), 20, xyzt(:,4), 'filled')
xlabel('X'); ylabel('Y'); zlabel('Z');