macro "DoubleStainedMeasurements" 
{
/*	Batch analysis of cells to see if double stained or not
*	Select the folder where the images are stored
*	the macro will loop through all the files.
*/

	//--------------------------------------------------
	//INTENSITY THRESHOLD TO SET BY THE USER
	//--------------------------------------------------

	ThresholdIntensity = 300;




	//--------------------------------------------------
	//CLOSE ALL IMAGES AND RESET EVERYTHING
	//--------------------------------------------------

	setBatchMode(true);
	run("Close All");
	print("\\Clear");
	roiManager("Reset");
	run("Clear Results");
	print("-----------------------------------");
	print("LiveDeadAnalysis Auto macro started");




	//-------------------------------------------------
	//INITIAL SETTINGS
	//-------------------------------------------------

	//Get folder from the user
	setOption("JFileChooser",true);
	Folder = getDirectory("Choose the folder where your images are located");
	setOption("JFileChooser",false);

	//Get the names of all the files in the folder
	Files = getFileList(Folder);
	Array.sort(Files);
	NrOfFiles = Files.length;
	NrOfImages = 0;
	TextFileExist = 0;
	BlueFile = "";
	GreenFile = "";
	FileExist = 0;


	//Number for the loop
	MaxNumber = getNumber("How many couple of images are there in the folder ?",0);



	//Loop through all the files
	print("Looping through all the files");
	for (i = 1 ; i <= MaxNumber ; i ++)
	{
		for(j = 0 ; j < Files.length ; j++)
		{
			//print(Files[j]);
			//print(endsWith(Files[j],"_DAPI_P"+i+".tif"));
			//Open DAPI image
			if(endsWith(Files[j],"_DAPI_P"+i+".tif"))
			{
				//print(Files[j]);
				open(Files[j]);
				BlueFile = File.name;
				FileExist++;
			}

			//Open FITC image
			if(endsWith(Files[j],"_FITC_P"+i+".tif"))
			{
				//print(Files[j]);
				open(Files[j]);
				GreenFile = File.name;
				FileExist++;
			}

			//Check if result file already exist
			if(TextFileExist == 0 && FileExist == 2 )
			{
				//Name of the result text file
				subString = "_DAPI_P"+i;
				TextFileName = substring(BlueFile,0,indexOf(BlueFile,"_DAPI_P"+i))+"_Results.txt";
				TextFileExist = 1;
				File.saveString("Name of the experiment\tNumber of Cells\tNumber of double stained\n",Folder + File.separator + TextFileName);

			}
		}

		FileExist = 0;

		//---------------------------------
		// PLACE WHERE TO PUT THE MACRO CODE
		//---------------------------------

		//Put back ROI manager to 0
		roiManager("reset");

		//Easier to select
		BCBlueFile = "C3-" + BlueFile;
		GCGreenFile = "C2-" + GreenFile;
		
		selectWindow(BlueFile);
		run("Split Channels");
		selectWindow("C2-" + BlueFile);
		close();
		selectWindow("C1-" + BlueFile);
		close();
		selectWindow(GreenFile);
		run("Split Channels");
		selectWindow("C3-" + GreenFile);
		close();
		selectWindow("C1-" + GreenFile);
		close();
		selectWindow(BCBlueFile);
		run("Subtract Background...", "rolling=10");
		//selectWindow(BCBlueFile);

		//Select threshold for blue channel
		setAutoThreshold("Huang dark");
		//run("Threshold...");
		//setThreshold(212, 2040);
		setOption("BlackBackground", true);
		run("Convert to Mask");
		//waitForUser("here");
		//run("Close");

		//Put minimal size of the object and circularity for blue channel
		run("Analyze Particles...", "clear include add");
		blueStainedCount = roiManager("count");
		roiManager("reset");
		selectWindow(GCGreenFile);

		//Select treshold for green channel
		setAutoThreshold("Huang dark");
		//run("Threshold...");
		//setThreshold(212, 2040);
		run("Convert to Mask");
		//run("Close");
		selectWindow(BCBlueFile);
		run("Create Selection");
		selectWindow(GCGreenFile);
		run("Restore Selection");

		
		run("Analyze Particles...", "clear include add");
		doubleStainedCount = roiManager("count");
		
		close(BlueFile);
		close(GreenFile);

		File.append("\n"+BlueFile+"\t"+blueStainedCount+"\t"+doubleStainedCount,Folder + File.separator + TextFileName);
	}
}
