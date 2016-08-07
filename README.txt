LIST OF FILES TO USE TO PROCESS THE DATA, RUN IN THIS ORDER:

**DICOM_anonymize.m: **
Use to load the dicom files and anonymize them. Also homogenizes the file and folder names
Will throw error if more than one structure file in the folder, keep only 1 structure file in the folder

**ExamineStructureNames.m **
Will display the names of all structures
Look at the name of PTV, it is not consistently called PTV in all files, could be called PTV_4500 or something similar

**MakeMaskFromPolygonBatch2.m **
Create binary masks for each structure - stomach, duodenum, small bowel and large bowel for all the fractions in the image
For each run, change variable patient_number, fraction_number_init if not using Fx #1 as baseline, fxnums (total number of fractions), PTV_name
Also change variables base_dir for input file location and results_dir for output file location

**ViewOverlayAllROIs.m **
View an overlay of all ROIs on the image

**ViewOverlay.m **
View a 4 panel figure, 
#1: Image overlaid with baseline ROI in blue, union image in red
#2: Distance map
#3: Binary of baseline fx ROI
#4: Multiplication of distance map and subtraction of union image binary and baseline binary

**WriteCumulativeDmapArray2.m **
Write the concatenated distance maps of all fractions for each ROI

**BuildHistogram.m **
Analyze the results with histograms and 95% distance metrics

**DCMImageViewer.m **
Load, stack and view the MRI image or CT image. Assumes all MRI files named 'MRI*.dcm' and only this prefix unique to volume of interest in the folder. 
If more than 1 sequence is named in this manner and stored in same folder, it will load and sort 2 volumes and treat as one.

OTHER POTENTIALLY USEFUL FILES

**CompareDmapMeans.m **
If created cumulative distance maps using more than 1 fx, compare them using t-test

**MakeMaskFromPolygon3.m**
Create single binary mask from structure and image, not tested for latest changes, may need to be updated

IMPORTANT FUNCTIONS CALLED BY MAIN SCRIPTS

**load_VR_MRI.m **
Loads the MRI images. This file assumes all the dicom MRI images are named 'MRI*.dcm'. If more than 1 sequence is named in this manner and stored in same folder, it will throw error

**MakeMask.m **
Main function that creates binary mask from structures and dicom images

**StructureExamine.m **
Get important indices for ROIs