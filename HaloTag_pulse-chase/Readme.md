This folder ('HaloTag_pulse-chase') contains matlab code used to process files.
It also contains Jupyter notebook files used to generate plots and process the data ('n_calculator.ipynb' for getting #n, mean, stdev by group; 'SuperPlots_WT_KO.ipynb' for plotting)

Input files are as follows: 
- All images to be processed (.tif) were saved in a folder named "TIFs_forAnalysis". The filenames were in the format of 'fileid_channelname.tif'. 
- Images are single slices and channels were exported separately.
- Corresponding binary masks of nuclear ROIs (manually drawn) were saved in a folder named "Masks". The filenames were in the format of 'fileid-Mask.tif'.
- Folder organization was: 'all data/replicateID/age(DIV)/'. 
  - for example: "/Users/suminkim/Dropbox (University of Michigan)/Dropbox_Imaging/SIM/HaloTag_DIV4-10_PulseChase/0610_4_KO/DIV4/TIFs_forAnalysis"

The code was run in the following order:

1) Overlaymask_outputtiff.m 
  - Inputs .tif images and masks
  - Obtains ROI area (original and after 15px erosion to exclude curving NE), circularity 
  - Thresholds image (Otsu) and overlays binary mask, saves this image as .tif, one nucleus per image in folder '<channelname>_Overlayed'
2) SIM_NPC_Analysis_SK2.m 
  - Get # of unique peaks per nucleus
  - Outputs .tif of all peaks (without cleaning up peaks that span multiple pixels) in folder '<channelname>_Output'
3) RoundupCoordsAndOutput.m 
  - Get coordinates of unique peaks (i.e. address the issue of peaks spanning multiple pixels) by taking centroid of all peaks
  - Outputs .tif of rounded coordinates in folder 'RoundedCoords'
4) JF646_JFX554_process.m 
  - Identifies unique "new JF646" peaks that do not overlap with JFX554 using .tifs of JF646 peaks (from 'JF646_Output' folder saved from 'SIM_NPC_analysis_SK2.m') and .tifs of JFX554 images overlayed/thresholded (from 'JFX554_Overlayed' folder saved from 'Overlaymask_outputtiff.m')
  - Outputs peaks of just new JF646 signal (without cleaning up peaks spanning multiple pixels) and counts of just the new JF646 signal per nucleus
  - Output .tifs are saved to 'JF646_Unique_Output' folder

  ** NPC counts for channels are unique JF646 peaks are all saved in .mat files in steps 2-4.
  ** ROI parameters measured in 'overlaymask_outputtiff.m' are also saved in .mat

5) CombineData.m 
  - Uses .mat outputs from previous steps, calculates density. 
  - Combines outputs including the ROI paramters from 'Overlaymask_outputtiff.m' from previous steps
  - Ouputs aggregate data with replicate #, DIV info, and genotype (denoted as WT=0; KO=1) in .csv and .mat
  - .csv can now be imported on the jupyter notebook to make plots.

