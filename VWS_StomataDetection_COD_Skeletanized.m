% VWS Project : Code for stomata detection.
% Measuring Stomata aperture area and eccentricity using skeletanization
% methods
% Author : Hiranya Jayakody. April 2017.
% email : hiranya.jayakody@unsw.edu.au for more info.

% Using the Cascade Object Detector to identify stomata ROIs and use
% skeletanization methods and segmentation to detect the aperture properties

% Set training parameter
Training = false

% Select image folder
%----------------------
imdirTest = 'Path\To\Test\Data\Folder\';

%Image output Directory
%----------------------
outputDir = 'Path\to\save\microscope\image\';

% Set area range for ROI (subject to change on zoom and image size) :
%-----------------------------------------------------
areaMax = 150000; 
areaMin = 14000;


%Train Cascade Object Detector (last updated : 13.03.2017)
%-----------------------------
if Training == true
    % positive image directory
    imdir = 'path\to\positive\image\data\';
    imset = imageSet(imdir,'recursive');
    %negative image directory
    imdirNeg = 'Path\to\negative\training\data\';

	trainCascadeObjectDetector('outputxmlfile.xml',MATfilewithLabeledData,imdirNeg,'FalseAlarmRate',0.1,'NumCascadeStages',7,'NegativeSamplesFactor',1,'FeatureType','HOG');
	%Example: trainCascadeObjectDetector('stomateDetector_v0.xml',Test,imdirNeg,'FalseAlarmRate',0.1,'NumCascadeStages',8,'NegativeSamplesFactor',2,'FeatureType','HOG');
end

%Get detector model from xml file
%--------------------------------
detector = vision.CascadeObjectDetector('stomateDetector_v0.xml');


% Get all images from the test folder
%-------------------------------------
imsetTest = imageSet(imdirTest);


% Create Structs and Variables
% -----------------------------
stomataLog = struct('image_folder',[],'image',[],'image_id',[],'num_ROI',[],'apertureDetected',[],'avg_ecc',[],'avg_area',[]);

stomataLog.image_folder= imdirTest;
stomataResults = zeros(imsetTest.Count,2);
counter = 1;
inc = 1;
eccentricity = [];
allArea = [];

% Loop through each test image
% ----------------------------

tic

for n = 1:imsetTest.Count
    
    disp(strcat('Processing image ID : ', num2str(n)));
    
    stomataLog(n).image_id = n; % save
    imTest = read(imsetTest,n); % read current image
    
    imTest = imadjust(imTest,[0 0 0;1 1 1],[]); %adjust colors of the original image
    
    
    % Use COD to identify ROIs
    %--------------------------
    bbox = step(detector,imTest); % returns bbox vector which contains rectangular ROIs
    
          
    % Reject ROIs which are too large or too small and get ROIs within a
    % specific size range
    % ----------------------------------------------------
    [bboxNew,stomataLog(n).num_ROI] = getROIinRange(bbox,areaMax,areaMin);
    
    eccentricityPerImage=[];
    
    

	for c= 1:size(bboxNew,1) 

		[ecc,Area] = getStomataOpening(imTest(bboxNew(c,2):(bboxNew(c,2)+bboxNew(c,4)),bboxNew(c,1):(bboxNew(c,1)+bboxNew(c,3)),:),inc);
		%[ecc,Area] = getStomataOpening(imTest,inc);
		eccentricityPerImage(c,1) = ecc;
		averagePerImage(c,1) = Area;
		imageIDPerImage(c,1) = inc;
		   
		if (isnan(eccentricityPerImage(c,1)))
		
			[ecc,Area] =  getSkeletanizedAperture(imTest(bboxNew(c,2):(bboxNew(c,2)+bboxNew(c,4)),bboxNew(c,1):(bboxNew(c,1)+bboxNew(c,3)),:),inc);%fffstat(c).Eccentricity;
			%[ecc,Area] =  getSkeletanizedAperture(imTest,inc);%fffstat(c).Eccentricity;
			eccentricityPerImage(c,1) = ecc;
			averagePerImage(c,1) = Area;
			imageIDPerImage(c,1) = inc;
			
		end
		
		inc = inc + 1; % incrementer for individual stomata image saving
	end

% Remove the NaN entries and save the valid values to a vector
    dd = 1;
    finalEcc = [];
    finalArea = [];
    finalAvg = [];

	for d = 1:size(eccentricityPerImage,1)
		if (isnan(eccentricityPerImage(d,1)))
			% do nothing 
		else
		   
			finalEcc(dd,1) = eccentricityPerImage(d,1);
			finalArea(dd,1) = averagePerImage(d,1);
			StMorph(counter,1).eccentricity = eccentricityPerImage(d,1);
			StMorph(counter,1).allArea= averagePerImage(d,1);
			StMorph(counter,1).imageIDs = imageIDPerImage(d,1);
			
			counter = counter+1;
			dd = dd+1;
		end
	end


	% Save image and information
	%---------------------------

	detectedIm = insertObjectAnnotation(imTest,'rectangle',bboxNew,'stomate','LineWidth',12); % insert boundingbox on the image

	figure();
	imshow(detectedIm);
	imwrite(detectedIm,strcat(outputDir,num2str(n),'.jpeg'))
	%print ('-djpeg','-r600',strcat('outputDir',num2str(n)));

	stomataLog(n).image = strcat(imdirTest,num2str(n),'.jpg'); % save
	stomataLog(n).apertureDetected = size(finalEcc,1);
	stomataLog(n).avg_ecc = sum(finalEcc,1)/size(finalEcc,1);
	stomataLog(n).avg_area = sum(finalArea,1)/size(finalArea,1);

	close all;

end

toc

mean0 = mean(eccentricity);
trimMean25 = trimmean(eccentricity,25);
trimmean50 = trimmean(eccentricity,50);

