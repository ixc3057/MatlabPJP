clear, clc, close all, format compact

%% Inputs
% Patient number
patient_number = 10;
% Fraction numbers to compare to each other
fraction_number_init = 1;
fraction_number = fraction_number_init;
fxnums = 15;
% Number of slices above and below PTV to truncate
num_slices_PTV = 5;

% Structure of interest
% ROI_name = 'STOMACH';
% ROI_name = 'DUODENUM';
% ROI_name = 'SMALLBOWEL';
ROI_name = 'LARGEBOWEL';

%ROI_name = 'Skin';
%ROI_name_full = ROI_name;

epsilon = 1e-6;
fixed_distance = 10;

vinterval = [0:3:120];
vint_graph = 0:length(vinterval)-1;

base_dir = 'C:\Users\ichen\Documents\data_anon\Patient_';
results_dir = 'Analysis';

% Read fraction distance map
fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir,'\', ROI_name, '_Fx1_Dmap_linear_array.raw'];
fid = fopen(fnameout,'r');
Dmap_Fx1_contour=fread(fid,'double');
fclose(fid);


fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir,'\', ROI_name, '_PTV_Dmap_linear_array.raw'];
fid = fopen(fnameout,'r');
Dmap_PTV_contour=fread(fid,'double');
fclose(fid);

% Read union distance map
fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir,'\', ROI_name, '_Fx1_union_Dmap_linear_array.raw'];
fid = fopen(fnameout,'r');
Dmap_Fx1_union=fread(fid,'double');
fclose(fid);

Fx1_union_hist = hist(Dmap_Fx1_union,vinterval) ./ sum(hist(Dmap_Fx1_union,vinterval))*100;
cum_Fx1_union_hist = cumsum(Fx1_union_hist);

h=figure(1);
bar(vinterval/10,Fx1_union_hist);set(gca,'FontSize',20)
xlabel('Distance (cm)','FontSize',20,'FontWeight', 'bold')
ylabel('% Pixels','FontSize',20,'FontWeight', 'bold')
title(['Histogram (union), Patient #', num2str(patient_number), ', ROI: ', ROI_name],'FontSize',24,'FontWeight', 'bold')
set(h,'Position',[56 117 1200 818])
axis tight

h=figure;
bar(vinterval/10,cum_Fx1_union_hist);set(gca,'FontSize',20)
xlabel('Distance (cm)','FontSize',20,'FontWeight', 'bold')
ylabel('% Pixels','FontSize',20,'FontWeight', 'bold')
title(['Cumulative Histogram (union), Patient #', num2str(patient_number), ', ROI: ', ROI_name],'FontSize',24,'FontWeight', 'bold')
set(h,'Position',[56 117 1200 818])
axis tight

disp('Union histogram')
% ind = find(cum_Fx1_union_hist < 90, 1, 'last' );
% disp(['Distance covering 90% motion: ', num2str(vinterval(ind)/10), ' cm'])
ind = find(cum_Fx1_union_hist < 95, 1, 'last' );
dist_95 = interp1([cum_Fx1_union_hist(ind) cum_Fx1_union_hist(ind+1)],[vinterval(ind) vinterval(ind+1)],95);
dd = 2;
DD = 10^(dd-ceil(log10(dist_95)));
dist_95 = round(dist_95*DD)/DD;
disp(num2str([cum_Fx1_union_hist(ind) cum_Fx1_union_hist(ind+1)]))
disp(num2str([vinterval(ind) vinterval(ind+1)]))
% disp(num2str(cum_Fx1_union_hist(ind)), ' ', num2str(cum_Fx1_union_hist(ind+1)]), ' ', num2str([vinterval(ind) vinterval(ind+1)]))
disp(['Distance covering 95% motion: ', num2str(dist_95/10), ' cm'])


Fx1_hist = hist(Dmap_Fx1_contour,vinterval) ./ sum(hist(Dmap_Fx1_contour,vinterval))*100;
cum_Fx1_hist = cumsum(Fx1_hist);

h=figure;
bar(vinterval/10,Fx1_hist);set(gca,'FontSize',20)
xlabel('Distance (cm)','FontSize',20,'FontWeight', 'bold')
ylabel('% Pixels','FontSize',20,'FontWeight', 'bold')
title(['Histogram, Patient #', num2str(patient_number), ', ROI: ', ROI_name],'FontSize',24,'FontWeight', 'bold')
set(h,'Position',[56 117 1200 818])
axis tight

h=figure;
bar(vinterval/10,cum_Fx1_hist);set(gca,'FontSize',20)
xlabel('Distance (cm)','FontSize',20,'FontWeight', 'bold')
ylabel('% Pixels','FontSize',20,'FontWeight', 'bold')
title(['Cumulative Histogram, Patient #', num2str(patient_number), ', ROI: ', ROI_name],'FontSize',24,'FontWeight', 'bold')
set(h,'Position',[56 117 1200 818])
axis tight

disp('Concatenated histogram')
% ind = find(cum_Fx1_hist < 90, 1, 'last' );
% disp(['Distance covering 90% motion: ', num2str(vinterval(ind)/10), ' cm'])
ind = find(cum_Fx1_hist < 95, 1, 'last' );
dist_95 = interp1([cum_Fx1_hist(ind) cum_Fx1_hist(ind+1)],[vinterval(ind) vinterval(ind+1)],95);
disp(num2str([cum_Fx1_hist(ind) cum_Fx1_hist(ind+1)]))
disp(num2str([vinterval(ind) vinterval(ind+1)]))
dd = 2;
DD = 10^(dd-ceil(log10(dist_95)));
dist_95 = round(dist_95*DD)/DD;
disp(['Distance covering 95% motion: ', num2str(dist_95/10), ' cm'])

ind = find(Dmap_PTV_contour<epsilon);
Dmap_PTV_contour(ind) = epsilon;
PTV_weights_tmp = 1./(Dmap_PTV_contour).^2;
PTV_weights = PTV_weights_tmp./sum(PTV_weights_tmp);

% Weighted histogram
histw = histwc_int(Dmap_Fx1_contour, PTV_weights, vinterval);
histw = histw*100;
h=figure;
bar(vinterval/10,histw);set(gca,'FontSize',20)
xlabel('Distance (cm)','FontSize',20,'FontWeight', 'bold')
ylabel('% Pixels','FontSize',20,'FontWeight', 'bold')
title(['Weighted Histogram, Patient #', num2str(patient_number), ', ROI: ', ROI_name],'FontSize',24,'FontWeight', 'bold')
set(h,'Position',[56 117 1200 818])
axis tight

% Cumulative weighted
cum_Fx1_hist_weight = cumsum(histw);
h=figure;
bar(vinterval/10,cum_Fx1_hist_weight);set(gca,'FontSize',20)
xlabel('Distance (cm)','FontSize',20,'FontWeight', 'bold')
ylabel('% Pixels','FontSize',20,'FontWeight', 'bold')
title(['Cumulative Weighted Histogram, Patient #', num2str(patient_number), ', ROI: ', ROI_name],'FontSize',24,'FontWeight', 'bold')
set(h,'Position',[56 117 1200 818])
axis tight

disp('Weighted histogram')
% ind = find(cum_Fx1_hist_weight < 90, 1, 'last' );
% disp(['Distance covering 90% motion: ', num2str(vinterval(ind)/10), ' cm'])
ind = find(cum_Fx1_hist_weight < 95, 1, 'last' );
dist_95 = interp1([cum_Fx1_hist_weight(ind) cum_Fx1_hist_weight(ind+1)],[vinterval(ind) vinterval(ind+1)],95);
disp(num2str([cum_Fx1_hist_weight(ind) cum_Fx1_hist_weight(ind+1)]))
disp(num2str([vinterval(ind) vinterval(ind+1)]))
dd = 2;
DD = 10^(dd-ceil(log10(dist_95)));
dist_95 = round(dist_95*DD)/DD;
disp(['Distance covering 95% motion: ', num2str(dist_95/10), ' cm'])
% disp(['Distance covering 95% motion: ', num2str(vinterval(ind)/10), ' cm'])

% Only accounting for pixels within a fixed distance of PTV
ind = find(Dmap_PTV_contour<fixed_distance);
PTV_fixed_dist_map = Dmap_Fx1_contour(ind);

Fx1_hist_fix_dist = hist(PTV_fixed_dist_map,vinterval) ./ sum(hist(PTV_fixed_dist_map,vinterval))*100;
cum_Fx1_hist_fix_dist = cumsum(Fx1_hist_fix_dist);

h=figure;
bar(vinterval/10,Fx1_hist_fix_dist);set(gca,'FontSize',20)
xlabel('Distance (cm)','FontSize',20,'FontWeight', 'bold')
ylabel('% Pixels','FontSize',20,'FontWeight', 'bold')
title(['Histogram w-i ', num2str(fixed_distance/10), ' cm of PTV, Patient #', num2str(patient_number), ', ROI: ', ROI_name],'FontSize',24,'FontWeight', 'bold')
set(h,'Position',[56 117 1200 818])
axis tight

h=figure;
bar(vinterval/10,cum_Fx1_hist_fix_dist);set(gca,'FontSize',20)
xlabel('Distance (cm)','FontSize',20,'FontWeight', 'bold')
ylabel('% Pixels','FontSize',20,'FontWeight', 'bold')
title(['Cumulative Histogram w-i ', num2str(fixed_distance/10), ' cm of PTV, Patient #', num2str(patient_number), ', ROI: ', ROI_name],'FontSize',24,'FontWeight', 'bold')
set(h,'Position',[56 117 1200 818])
axis tight

disp(['w-i ', num2str(fixed_distance/10), ' cm of PTV: '])
% ind = find(cum_Fx1_hist_fix_dist < 90, 1, 'last' );
% disp(['Distance covering 90% motion: ', num2str(vinterval(ind)/10), ' cm'])
ind = find(cum_Fx1_hist_fix_dist < 95, 1, 'last' );
dist_95 = interp1([cum_Fx1_hist_fix_dist(ind) cum_Fx1_hist_fix_dist(ind+1)],[vinterval(ind) vinterval(ind+1)],95);
disp(num2str([cum_Fx1_hist_fix_dist(ind) cum_Fx1_hist_fix_dist(ind+1)]))
disp(num2str([vinterval(ind) vinterval(ind+1)]))
dd = 2;
DD = 10^(dd-ceil(log10(dist_95)));
dist_95 = round(dist_95*DD)/DD;
disp(['Distance covering 95% motion: ', num2str(dist_95/10), ' cm'])
% disp(['Distance covering 95% motion: ', num2str(vinterval(ind)/10), ' cm'])

% h=figure;
% plot(sort(PTV_weights))