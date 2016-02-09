clear, clc, close all, format compact

%% Inputs
% Patient number
patient_number = 5;
% Fraction numbers to compare to each other
fraction_number = 1;
fxnums = 25;
% Number of slices above and below PTV to truncate
num_slices_PTV = 5;

% Structure of interest
ROI_name = 'DUODENUM';

%ROI_name = 'Skin';
%ROI_name_full = ROI_name;

epsilon = 1e-6;
fixed_distance = 20;

vinterval = [0:3:120];
vint_graph = 0:length(vinterval)-1;

% Read fraction distance map
fnameout =  ['C:\Users\ichen\Documents\data-anon-matlab\Patient_0', num2str(patient_number), '\Analysis\', ROI_name, '_Fx1_Dmap_linear_array.raw'];
fid = fopen(fnameout,'r');
Dmap_Fx1_contour=fread(fid,'double');
fclose(fid);


fnameout =  ['C:\Users\ichen\Documents\data-anon-matlab\Patient_0', num2str(patient_number), '\Analysis\', ROI_name, '_PTV_Dmap_linear_array.raw'];
fid = fopen(fnameout,'r');
Dmap_PTV_contour=fread(fid,'double');
fclose(fid);


Fx1_hist = hist(Dmap_Fx1_contour,vinterval) ./ sum(hist(Dmap_Fx1_contour,vinterval))*100;
cum_Fx1_hist = cumsum(Fx1_hist);

figure(1)
bar(vinterval,Fx1_hist)
xlabel('Distance (mm)')
ylabel('% Pixels')
title(['Histogram, Patient #', num2str(patient_number), ', ROI: ', ROI_name])
axis tight

figure(2)
bar(vinterval,cum_Fx1_hist)
xlabel('Distance (mm)')
ylabel('% Pixels')
title(['Cumulative Histogram, Patient #', num2str(patient_number), ', ROI: ', ROI_name])
axis tight

ind = find(cum_Fx1_hist < 90, 1, 'last' );
disp(['Distance covering 90% motion: ', num2str(vinterval(ind)/10), ' cm'])
ind = find(cum_Fx1_hist < 95, 1, 'last' );
disp(['Distance covering 95% motion: ', num2str(vinterval(ind)/10), ' cm'])

ind = find(Dmap_PTV_contour<epsilon);
Dmap_PTV_contour(ind) = epsilon;
PTV_weights = 1./(Dmap_PTV_contour).^2;
PTV_weights = PTV_weights./sum(PTV_weights);

% Weighted histogram
histw = histwc_int(Dmap_Fx1_contour, PTV_weights, vinterval);
histw = histw*100;
figure(3)
bar(vinterval,histw)
xlabel('Distance (mm)')
ylabel('% Pixels')
title(['Weighted Histogram, Patient #', num2str(patient_number), ', ROI: ', ROI_name])
axis tight

% Cumulative weighted
cum_Fx1_hist_weight = cumsum(histw);
figure(4)
bar(vinterval,cum_Fx1_hist_weight)
xlabel('Distance (mm)')
ylabel('% Pixels')
title(['Cumulative Weighted Histogram, Patient #', num2str(patient_number), ', ROI: ', ROI_name])
axis tight

ind = find(cum_Fx1_hist_weight < 90, 1, 'last' );
disp(['Distance covering 90% motion: ', num2str(vinterval(ind)/10), ' cm'])
ind = find(cum_Fx1_hist_weight < 95, 1, 'last' );
disp(['Distance covering 95% motion: ', num2str(vinterval(ind)/10), ' cm'])

% Only accounting for pixels within a fixed distance of PTV
ind = find(Dmap_PTV_contour<fixed_distance);
PTV_fixed_dist_map = Dmap_Fx1_contour(ind);

Fx1_hist_fix_dist = hist(PTV_fixed_dist_map,vinterval) ./ sum(hist(PTV_fixed_dist_map,vinterval))*100;
cum_Fx1_hist_fix_dist = cumsum(Fx1_hist_fix_dist);

figure(5)
bar(vinterval,Fx1_hist_fix_dist)
xlabel('Distance (mm)')
ylabel('% Pixels')
title(['Histogram w-i ', num2str(fixed_distance/10), ' cm of PTV, Patient #', num2str(patient_number), ', ROI: ', ROI_name])
axis tight

figure(6)
bar(vinterval,cum_Fx1_hist_fix_dist)
xlabel('Distance (mm)')
ylabel('% Pixels')
title(['Cumulative Histogram w-i ', num2str(fixed_distance/10), ' cm of PTV, Patient #', num2str(patient_number), ', ROI: ', ROI_name])
axis tight

ind = find(cum_Fx1_hist_fix_dist < 90, 1, 'last' );
disp(['Distance covering 90% motion ', 'w-i ', num2str(fixed_distance/10), ' cm of PTV: ', num2str(vinterval(ind)/10), ' cm'])
ind = find(cum_Fx1_hist_fix_dist < 95, 1, 'last' );
disp(['Distance covering 95% motion ', 'w-i ', num2str(fixed_distance/10), ' cm of PTV: ', num2str(vinterval(ind)/10), ' cm'])

figure(7)
plot(sort(PTV_weights))