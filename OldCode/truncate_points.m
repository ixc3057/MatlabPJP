function points_out = truncate_points(points_in, min_z, max_z, SliceThickness, num_slices)
% Function to truncate points to 5 slices above and below PTV
%
%
%
% (C) Ishita Chen, 1/26/2016

lower_lim = min_z - num_slices*SliceThickness;
upper_lim = max_z + num_slices*SliceThickness;
points_out = points_in(points_in(:,3)<=upper_lim & points_in(:,3)>=lower_lim,:);