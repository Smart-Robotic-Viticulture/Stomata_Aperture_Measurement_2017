function [eccentricity,Area] = getStomataOpening(imageROI,inc)
% COPYRIGHT: Hiranya Jayakody. April 2017.
%GETSTOMATAOPENING detects the stomate opening (aperture) in a given ROI,
%and returns the  eccentricity of the detected elliptical aperture.
%inputs :
%   imageROI - the cropped ROI image (RGB)
%   inc - id number to save the stomata image

%outputs :
%   eccentricity - eccentricity of the aperture
%   convexhull - convexhull vertices of the aperture

outputPath = 'Path\to\save\individual\stomata\images\with\aperture\marked\with\segmentation\'; %saves stomata opening

% centeroid of the ROI
imcenterx = round(size(imageROI,2)/2);
imcentery = round(size(imageROI,1)/2);

%Area range (an image based variable)
areaMinSeg = 200;
areaMaxSeg = 5500;%size(imageROI,1)*size(imageROI,2)/8;


imSharp =imsharpen(imageROI,'Radius',15,'Amount',1.2,'Threshold',0);% Setting may change subjected to source images
imGraySharp = rgb2gray(imSharp);
imAdjSharp = imadjust(imGraySharp);

imBWSharp = im2bw(imAdjSharp,0.65);

s = strel('disk',1);
imDilated = imdilate(imBWSharp,s); %changed to imBWSharp

stats = regionprops(imDilated,'Area','Centroid','Eccentricity','ConvexImage','ConvexHull');

% derive closed regions within the given area Range
fidx = ((cat(1,stats.Area) > areaMinSeg) & (cat(1,stats.Area) < areaMaxSeg)); % only areas between 200 and 10000
fstats = stats(fidx);

centroidSeg = cat(1,fstats.Centroid);

% check whether the regions are close to the center of the ROI
if (size(centroidSeg,1) > 0)
	ffidx = (centroidSeg(:,1) > (imcenterx-(imcenterx/3))) & (centroidSeg(:,1) < (imcenterx+(imcenterx/3)) ) & (centroidSeg(:,2) > (imcentery-(imcentery/3))) & (centroidSeg(:,2) < (imcentery+(imcentery/3))) ;
	ffstats = fstats(ffidx);
else
	ffstats = fstats;
end

%filter out the regions closer to the center of the ROI, for the next stage.
centroidSeg = cat(1,ffstats.Centroid);

% Find the region closest to the center of the image (since stomata lies in
% the middle of the image)
dis2center =[];

for j=1:size(ffstats,1)
    dis2center(j) = ((imcenterx - centroidSeg(j,1))^2) + ((imcentery - centroidSeg(j,2))^2); % check the distance between the centroid of the ellipse and centroid of the ROI
end
[M,fffidx] = min(dis2center); % return the minimum distance value and index

% Update eccentricity and Area values depending on whether we have an ellipse
if (size(ffstats,1)>0)
    eccentricity = ffstats(fffidx).Eccentricity;
    Area = ffstats(fffidx).Area;
else
    eccentricity = NaN;
    Area = NaN;
end

% Display and save the result
figure(1)
imshow(imageROI);
hold on;
if (eccentricity > 0.1)
   plot( ffstats(fffidx).ConvexHull(:,1), ffstats(fffidx).ConvexHull(:,2),'g','LineWidth',2);
   print('-djpeg','-r600',strcat(outputPath,num2str(inc)));
end

end

