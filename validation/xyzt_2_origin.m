function xyzt = xyzt_2_origin(xyzt)
    mins = min(xyzt(:,1:3));
    xyzt = [xyzt(:,1:3) - mins, xyzt(:,4)];
end