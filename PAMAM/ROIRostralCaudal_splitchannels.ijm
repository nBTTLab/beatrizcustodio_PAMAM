/* Authors: Beatriz Custódio and Mafalda Sousa
*  Macro rotates the animal to a horizontal position, saves each channel (brightfield, mpeg:eGFP and Rhodamine) of the whole animal and brightfield of the whole animal, caudal and rostral regions with black background.
* Input: *
*                      * file or folder with multiple tiff files
*                     
* Output:                     
*                      * 3 images BF (whole animal, caudal and rostral part)
*                      * mpeg:eGFP, PAMAM and BF rotated
*                      * ROIs for quality control
* 
* "The authors acknowledge the support of i3S Scientific Platform Advanced Light Microscopy, member of the national infrastructure PPBI-Portuguese Platform of BioImaging (supported by POCI-01-0145-FEDER-022122)."
* 
* Date: 2023
* Adapted from a macro provided by:
* Author: Mafalda Sousa, Advanced Ligth Microscopy, I3S 
* PPBI-Portuguese Platform of BioImaging
*/

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tiff") suffix

processFolder(input);
print("=========Done===========");

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	//clear and close
	run("Clear Results");
	roiManager("reset");
	run("Close All");
	run("Remove Overlay");

	//open image and get image name
	open(input + File.separator + file);
	original = getTitle();
	title = substring(original, 0,indexOf(original, ".tif"));
	
	//Draw middle line 
	waitForUser("Draw middle line and press ok.");
	roiManager("add"); //add to manager
	roiManager("select", 0);
	Overlay.addSelection; //add to overlay

	//Rotate image based in the middle line. Straight line is drawn from start to end middle-line points
	Dialog.create("Rotate image (contrary to the clock hand!)");
	Dialog.addRadioButtonGroup("Rotate your image", newArray("0","45", "90","180","270"), 1, 5, "90"); 
	Dialog.show();
	angle = parseInt(Dialog.getRadioButton());

	//draw line based on middle line
	getSelectionCoordinates( x, y );
	makeLine(x[0],y[0],x[x.length-1],y[y.length-1]);
	line_angle = getValue("Angle");
	run("Select None");
	

	selectWindow(original);
	roiManager("deselect");
	run("Rotate... ", "angle=" + -angle+line_angle +" grid=1 interpolation=Bilinear fill enlarge stack");
	rename("Rotated");
	run("To ROI Manager");	//add to manager the rotated roi
	roiManager("select", 0);
	roiManager("rename", "middle-line");
	roiManager("deselect");


	//preprocess and segmentation
	selectWindow("Rotated");
	run("Select None");
	run("Duplicate...", "duplicate");
	rename("copy");
	
	        
	run("Split Channels");
	
	selectWindow("C2-copy");
	//C2 = getTitle();
	saveAs("Tiff", output + File.separator + title + "_mpeg.tiff");
	close();
	
	selectWindow("C3-copy");
	//C2 = getTitle();
	saveAs("Tiff", output + File.separator + title + "_PAMAM.tiff");
	close();
	
	selectWindow("C1-copy");
	//C1 = getTitle();
	saveAs("Tiff", output + File.separator + title + "_BF.tiff");
		
		
	//Draw animal ROI
	waitForUser("Draw animal ROI and press ok.");
	roiManager("add"); //add to manager
	roiManager("select", 1);
	roiManager("rename", "animal");
	roiManager("deselect");
	
	
	roiManager("Select", newArray(0,1));
	roiManager("XOR");
	roiManager("Add");
	roiManager("select", roiManager("count")-1);
	roiManager("Split");	
		

	//select rostral side and save
	selectWindow("Rotated");
	run("Duplicate...", "title=duplicate duplicate channels=1");
	roiManager("select", 5);
	run("Clear Outside");	
	saveAs("Tiff", output + File.separator + title + "_BF_rostral.tif");

	//select caudal side and save
	selectWindow("Rotated");
	run("Duplicate...", "title=duplicate duplicate channels=1");
	roiManager("select", 4);
	run("Clear Outside", "stack");
	saveAs("Tiff", output + File.separator + title + "_BF_caudal.tif");
	
	//select animal and save
	selectWindow("Rotated");
	run("Duplicate...", "title=duplicate duplicate channels=1");
	roiManager("select", 1);
	run("Clear Outside", "stack");
	saveAs("Tiff", output + File.separator + title + "_BF_animal.tif");

	//save Rois for Quality control
	roiManager("Save", output + File.separator + title + "_RoiSet.zip");
	run("Close All");
}


function deleteRois() { 
	c = roiManager("count");
	for (i = c; i > 2; i--) {			
		roiManager("select", i-1);
		a = getValue("Area");
		if (a<20000){
			roiManager("delete");
			c = roiManager("count");
		}
		else{
			c = c -1;
		}		
}}



