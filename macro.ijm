// Author: Sebastian Gilbert (University of Birmingham)
//
// Overview: The macro will pre-process, segment and post-process nuclei images, all to be exported to BIAFLOWS.
// Use a similar command line to this,
// java -Xmx6000m -cp jars/ij.jar ij.ImageJ -headless --console -macro IJSegmentClusteredNuclei.ijm "input=/media/baecker/donnees/mri/projects/2017/liege/in, output=/media/baecker/donnees/mri/projects/2017/liege/out, radius=5, threshold=-0.5"


// Version: 0.9
// Date: 30/11/2020


setBatchMode(true);

// Path to input image and output image (label mask)
inputDir = "/dockershare/666/in/";
outputDir = "/dockershare/666/out/";
//inputDir = getDirectory("Choose a Directory");
//outputDir = getDirectory("Choose a Directory");

// Functional parameters (in pixels)
BallSize = 50;

arg = getArgument();
parts = split(arg, ",");

for(i=0; i<parts.length; i++) {
	nameAndValue = split(parts[i], "=");
	if (indexOf(nameAndValue[0], "input")>-1) inputDir=nameAndValue[1];
	if (indexOf(nameAndValue[0], "output")>-1) outputDir=nameAndValue[1];
	if (indexOf(nameAndValue[0], "radius")>-1) BallSize=nameAndValue[1];
}

images = getFileList(inputDir);

for(i=0; i<images.length; i++) {
	image = images[i];
	if (endsWith(image, ".tif")) {
		// Open image
		open(inputDir + "/" + image);
		wait(100);
		// Pre-processing
			// Subtract background: Rolling ball algorithm
			run("Subtract Background...", "rolling=" + BallSize);

		// Segment
			// Threshold: ?Default IsoData algorithm?
			setOption("BlackBackground", true);
			run("Convert to Mask");

		// Post-processings
			run("Despeckle"); // Denoise any single pixel elements
			run("Fill Holes"); // Fill holes
			run("Watershed"); // Watershed

		// Analyze
		run("Analyze Particles...", "show=[Count Masks] clear include in_situ");
		
		// Export results
		save(outputDir + "/" + image);
		
		// Cleanup
		run("Close All");
	}
}
run("Quit");
