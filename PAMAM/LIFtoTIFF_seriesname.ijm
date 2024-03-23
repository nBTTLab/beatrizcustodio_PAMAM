// Authors: Beatriz Custódio and Mafalda Sousa
// Macro "Break up a lif into individual TIFF"
// Open the file manager to select a lif file to break it into TIFFs
// In this case, only the metadata specific to a series will be written. Name of each series into the lif file will be added to the TIFF file.
// Adapted from a macro provided by: Mafalda Sousa, ALM platform, i3S
// 2023

#@ File (label = "Input directory", style = "file") path
#@ File (label = "Output directory", style = "directory") out_path
print(out_path);

run("Bio-Formats Macro Extensions");
Ext.setId(path);
Ext.getCurrentFile(file);
Ext.getSeriesCount(seriesCount);

setBatchMode(true);
   
for (s=1; s<=seriesCount; s++) {

	run("Bio-Formats Importer", "open=&path autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_"+s);
	original = getTitle();
	dotIndex = lastIndexOf(original, ".");
	hifenIndex = dotIndex + 7;
    title = substring(original, 0, dotIndex); 
    well = substring(original, hifenIndex);
    
	
	selectWindow(original);
	saveAs("Tiff", out_path + "/" + title + "_" + well + ".tiff");
	close();

	
    }

setBatchMode(false);



