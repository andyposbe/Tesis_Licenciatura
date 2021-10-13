// Syneresis Automatic Analysis Macro
// Author: Andres Posbeyikian - IBBEA (CONICET) - UBA - Buenos Aires, Argentina
// October 2020

save_Dir=getDirectory("Saving directory");
outlines_directory = save_Dir + "\\outlines\\";
File.makeDirectory(outlines_directory); 

dir=getDirectory("Folder with sub-folders to analyze");
Assays=getFileList(dir);

for(i=0;i<Assays.length;i++){
	showProgress(i+1, Assays.length);
	current_assay_dir = dir + Assays[i] ;
	images = getFileList(current_assay_dir);
	first_image = images[0];
	waitForUser("Set Scale", "Click OK to set scale for assay " + Assays[i]);
	run("Image Sequence...", "open=["+current_assay_dir+ first_image + "] convert sort");
	window = getTitle();
	run("Set Scale...");
	run("Gaussian Blur...", "sigma=1 stack");
	run("Threshold...");
	waitForUser("Set Threshold","Configure the threshold for the stack and then click OK...");
	setTool("oval");
	run("Set Measurements...", "area redirect=None decimal=5");
	run("Clear Results");
	waitForUser("Particle Size Intervals","Measure the largest and smallest areas in the stack, then click OK...\nhelp: after selection, click CTRL+M to measure");
    areas = newArray(nResults);  // We the measured areas from the results window into an array
    for (j = 0; j < nResults(); j++) {
    	res_j = getResult('Area', j);
    	areas[j] = res_j;
	}
	Array.sort(areas);
	min = areas[0];
	max = areas[areas.length-1];
	run("Clear Results");
	run("Set Measurements...", "area shape feret's display redirect=None decimal=5");
	selectWindow(window);
	run("Select None");
	run("Analyze Particles...", "size="+toString(min-min*0.2)+"-"+toString(max+max*0.2)+" circularity=0.70-1.00 show=Outlines display exclude clear include summarize stack");
	for (k = 0; k < nResults(); k++) {  //Volume calculator
    	area_k = getResult('Area', k);
    	volume_k = (4/3)*PI*Math.pow(area_k/PI,3/2);
    	setResult('Volume', k, volume_k);
	}
	updateResults();
	saveAs("Results", save_Dir+ window + ".csv");
	window_outlines = "Drawing of " + window;
	selectWindow(window_outlines);
	assay_outline_directory = outlines_directory + "\\" + window + "\\";
	File.makeDirectory(assay_outline_directory);
	run("Image Sequence... ", "format=TIFF use save=["+assay_outline_directory+window_outlines+".tif]");
	wait(3000);
}

waitForUser("All done!");
run("Close All");
close
