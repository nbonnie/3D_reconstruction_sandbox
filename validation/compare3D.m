function errors = compare3D(df1, df2)
    % Require sizes are equivalent
    if size(df1) ~= size(df2)
        error 'Sizes of provided matrices must match'
        errors = NaN;    %#ok
        return
    end
    % Compute per-point error at each time step
    errors = zeros(size(df1,1), 3); % Preallocate for xyz errors
    
    for t = 1:size(df1,1)
        % Compute Euclidean distance for each point at time t
        err = vecnorm(df1(t,1:3) - df2(t,1:3));
        errors(t, 1:3) = err;
    end
    
end