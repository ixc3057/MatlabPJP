clear, clc, close all, format compact

%% Inputs
% Patient number
patient_number = 5;
% Fraction numbers to compare to each other
fraction_number_init = 2;
fraction_number = fraction_number_init;
fxnums = 25;
% Number of slices above and below PTV to truncate
num_slices_PTV = 5;

% Structure of interest
ROI_name = {4,1};
ROI_name{1} = 'STOMACH';
ROI_name{2} = 'DUODENUM';
ROI_name{3} = 'SMALLBOWEL';
ROI_name{4} = 'LARGEBOWEL';

base_dir = 'C:\Users\ichen\Documents\data_anon\Patient_';
results_dir1 = 'Analysis';
results_dir2 = 'Analysis2';

for iter = 1:length(ROI_name)
    % Read fraction distance map
    fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir1,'\', ROI_name{iter}, '_Fx1_Dmap_linear_array.raw'];
    fid = fopen(fnameout,'r');
    Dmap_Fx1=fread(fid,'double');
    fclose(fid);
    
    % Read fraction distance map
    fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir2,'\', ROI_name{iter}, '_Fx1_Dmap_linear_array.raw'];
    fid = fopen(fnameout,'r');
    Dmap_Fx2=fread(fid,'double');
    fclose(fid);
    
    disp([ROI_name{iter}])
    [h, p] = ttest2(Dmap_Fx1, Dmap_Fx2,0.05,'right','unequal')
    %     [p,h] = ranksum(Dmap_Fx1, Dmap_Fx2)
end