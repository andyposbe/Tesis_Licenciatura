// Gel Front Automatic Analysis Macro
// Author: Andres Posbeyikian - IBBEA (CONICET) - UBA - Buenos Aires, Argentina
// October 2020

// Requierements: Hough Circle Transform Plugin, Radial Profile Angle Plugin,

save_Dir=getDirectory("Saving directory");

dir=getDirectory("Folder with images to analyze");
run("Clear Results");

images = getFileList(dir);
first_image = images[0];
run("Image Sequence...", "open=["+dir+ first_image + "] convert sort");
window = getTitle();
run("Gaussian Blur...", "sigma=1.5 stack");
run("Remove Outliers...", "radius=8 threshold=0 which=Bright stack"); // Luego hay que hacer esto interactivo.
run("Find Edges", "stack");

run("Threshold...");
waitForUser("Set Threshold","Configure the threshold for the stack. \nMake sure the gel front is visible, but try to reduce noise,\nthen click OK...");
setTool("oval");
waitForUser("Clear the outsides","Use the oval tool to select the ROI\n(make sure to include the capsule in all stacks),\nThen click OK...");
run("Colors...", "foreground=black background=white selection=orange");
run("Clear Outside", "stack");


//HCT Radii search limits
setTool("line");
waitForUser("Maximum and Minimum radii","Measure the largest and smallest radii in the stack, then click OK...\nhelp: after selection, click CTRL+M to measure");
run("Select None");
radii = newArray(nResults);  // We create thean array with the size of recorded measurements.
for (j = 0; j < nResults(); j++) {
    res_j = getResult('Length', j);
    radii[j] = res_j;
}
Array.sort(radii);
Rmin = radii[0];
Rmax = radii[radii.length-1];
run("Clear Results");


//HCT
selectWindow(window); // window = "Gel Front Data", verificado imprimiendo window.
arg2 = "minRadius="+toString(Rmin,0)+", maxRadius="+toString(Rmax,0)+", inc=1, minCircles=1, maxCircles=1, threshold=0.5, resolution=25, ratio=1.0, bandwidth=10, local_radius=3, reduce local_search show_mask results_table";

// alg3_n3: local_radius =10
// General: "minRadius="+toString(Rmin,0)+", maxRadius="+toString(Rmax,0)+", inc=1, minCircles=1, maxCircles=1, threshold=0.5, resolution=25, ratio=1.0, bandwidth=10, local_radius=3, reduce local_search show_mask results_table";
run("Hough Circle Transform",arg2);
wait(nSlices*100);  //Ver si se puede cambiar por un loop que solo se rompa cuando termino de correr el plugin previo.http://imagej.1557.x6.nabble.com/Check-if-command-is-finished-in-a-macro-td5013045.html
selectWindow("Centroid overlay");
run("Image Sequence... ", "format=TIFF save=["+save_Dir+"Centroid overlay0000.tif]");

slice = newArray(nResults);  // We create arrays that contain the parameters for later use
x_centroid = newArray(nResults);
y_centroid = newArray(nResults);
radius = newArray(nResults);

for (j = 0; j < nResults(); j++) {
    slice_j = getResult('Frame (slice #)', j);
    slice[j] = slice_j;
    x_j = getResult('X (pixels)', j);
    x_centroid[j] = x_j;
    y_j = getResult('Y (pixels)', j);
    y_centroid[j] = y_j;
    radius_j = getResult('Radius (pixels)', j);
    radius[j] = radius_j;
}

IJ.renameResults("Circle Parameters");
saveAs("Results", save_Dir+"circle_params.csv");

// We crop and center the capsules:
selectWindow(window);
//setBatchMode(true);
// We prepare the stack for the Radial Profile, by cropping in limits within 1.1*Rmax, and lining by centroid:

for (i = 1; i <= slice.length; i++) { 
	
   setSlice(i);
   Rmax = radius[i-1];
   run("Duplicate...", "title="+images[i-1]+"_cropped");
   
   x_lim_sup = x_centroid[i-1]-1.1*Rmax;
   y_lim_sup = y_centroid[i-1]-1.1*Rmax;
   
   w = 2*1.1*Rmax; //width = height = 2*1.1*Radius
   makeRectangle(x_lim_sup, y_lim_sup,w ,w );
   run("Crop");
   selectWindow(window);
}


run("Images to Stack", "name=cropped_stack title=_cropped use");
setAutoThreshold("Default dark");
//run("Threshold...");
setOption("BlackBackground", false);
run("Convert to Mask", "method=Default background=Dark calculate");

run("Colors...", "foreground=white background=black selection=orange");
// NOTA: volver a invertir colores para usar el bucket.

//close("*");
//selectWindow(window);
//waitForUser("Determine Angles","Determine the correct Starting Angle and Integration Angle\nMake sure the gel front gets included in all slices\nHelp yourself with the circle params table to set X,Y, and radius in each slice\nWhen you're ready click OK...");

//Dialog.create("Radial Profile Angle Parameters");
//Dialog.addNumber("Starting Angle", 290);
//Dialog.addNumber("Integration Angle", 5);
//Dialog.show();

//We gather input from the user
//StartingAngle=Dialog.getNumber();
//IntegrationAngle=Dialog.getNumber();


//setSlice(1);
//run("Radial Profile Angle", "x_center="+toString(x_centroid[0],0)+" y_center="+toString(y_centroid[0],0)+" radius="+toString(radius[0],0)+" starting_angle="+toString(StartingAngle,0)+" integration_angle="+toString(IntegrationAngle,0));

//run("Radial Profile Angle", "x_center=335.50 y_center=356 radius=45.25 starting_angle=0 integration_angle=180 calculate_radial_profile_on_stack");
//selectWindow("Radial Profile Plot");
