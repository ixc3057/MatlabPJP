function [Dmap_Fx1_contour, Dmap_PTV_contour] = WriteDistanceMapArray(contourmask1, contourmask2, Dmap_Fx1, Dmap_PTV, epsilon)

% Create difference of new fraction mask and first fraction
union_sub = and(~contourmask1, contourmask2);

% Create linear array of non-zero elements of distance map of
% subtracted image wrt Fx1 and PTV
% Multiply distance map to binary mask
Dmap_Fx1_tmp = Dmap_Fx1 .* union_sub;
Dmap_PTV_tmp = Dmap_PTV .* union_sub;
% Linearize arrays
union_sub_flat = union_sub(:);
Dmap_Fx1_contour = Dmap_Fx1_tmp(:);
Dmap_PTV_contour = Dmap_PTV_tmp(:);
% Separate non-zero elements of mask
[non_zero_ind] = find(union_sub_flat>0+epsilon);
Dmap_Fx1_contour = Dmap_Fx1_contour(non_zero_ind);
Dmap_PTV_contour = Dmap_PTV_contour(non_zero_ind);
