//NuclearRim_Intensity_measure.ijm

// File organization:
// Each coverslip is organized in its own folder with subdirectories "ROIs" containing .zip of nuclear ROIs and "TIFs" containing .tif of images
// Each image has a unique name that is shared in both the "ROIs" and "TIFs" folders: ex) "628WT_DIV10_Img0007.zip" corresponds to "628WT_DIV10_Img0007_(channelname).tif"
// ROI saved in the .zip file includes slice number info as well as the actual nuclear rim trace
// TIFs folder includes z-stacks for individual channels with channel name identifier appended to the image id (see above)

// In this macro, we will take the ROI .zip files (folder 'ROIs') and .tif files (folder 'TIFs') to analyze nuclear rim intensity
// 1) open directory, get number of ROI files 
// 2) Loop through each ROI and open file for desired channel (FITC = Nup153 ; TRITCH = Nup358)
// 3) For each file, open file and measure the nuclear rim intensity by making a 4px-wide band outlining the nuclear periphery



// Set parent directory: // change as needed
path = "/Users/suminkim/Dropbox (University of Michigan)/from_box/Imaging/20220527_Nup153_358_DIV10-18/";

// Set imaging folder (folder for this coverslip):  // change as needed
imgfolder = "631WT/DIV10";

// Using this parent and imaging directories, set TIF and ROI paths:
TIFpath = path+imgfolder+"/TIFs/";
ROIpath = path+imgfolder+"/ROIs/";

// Make a filelist of MIP files and ROI files
TIFlist= getFileList(TIFpath);
ROIlist = getFileList(ROIpath);

// Set channel to analyze:   /// change as needed
ch = "TRITC";
// Set measurement params:
run("Set Measurements...", "area mean min shape stack display redirect=None decimal=3");

// Loop through ROI file list, open corresponding TIF file of desired channel, and analyze
for (f=0; f <ROIlist.length; f++) {

	// Get ROI name to retrieve image ID
	imgid = File.getNameWithoutExtension(ROIlist[f]);

	// Open corresponding image in the desired channel:
	imgname = imgid+"_"+ch+".tif";
	open(TIFpath + imgname);

	// Open ROI zip file and get number of ROIs
	fullroipath = ROIpath+imgid+".zip";
	roiManager("Open", fullroipath);
	nROIs = roiManager("count");

	// Loop through each ROI to make a 4px band of the nuclear rim and measure
	for (i=0; i< nROIs; i++) {
		roiManager("Select", i); // select ROIs sequentially
		run("Enlarge...", "enlarge=-2"); // shrink by 2 px (this way the original ROI outline is in the middle of the 4px-wide band)
		run("Make Band...", "band=4"); // Make band of 4px width
		roiManager("Update"); // update ROI with 4px-wide band
		roiManager("Measure"); // measure nuclear rim intensity
	}
	
	roiManager("reset"); // reset ROI manager after processing each MIP image to prepare for next image
	close(); // close current image
}

// Save results 
folderdivID = replace(imgfolder,'/','_');
saveAs("Results", path+folderdivID+"_"+ch+"_4px_band_measurements.csv");

