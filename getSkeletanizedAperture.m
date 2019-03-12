function [ eccentricity, area] = getSkeletanizedAperture( imageROI, inc)
% COPYRIGHT: Hiranya Jayakody. APril 2017.
%GETSKELETANIZEDAPERTURE function calculates the eccentricity and area of
%the aperture through skeletanization (thinning) methods.

% Inputs :
% imageROI - RGB image which has a stomate
% inc - image identification number

% Outputs :
% eccentricity - eccentricity of the aperture opening
% area - area of the aperture opening in pixels.

% Notes :
% This function uses a modified version of the fit_ellipse() function by
% Ohad Gul, to generate ellipses from line segments.

outputPathSkel = 'Path\to\save\individual\stomata\with\aperture\marked\using\skelatanization\'; %output directory to save skelatanized data

boundaryThres = 8; %reduces the ellipse's major and minor axis lengths by this amount

% Skeleton curve length range (an image based variable)
lengthMin = 75;
lengthMax = 2000;

% ellipse area range (an image based variable)
ellipseAreaMin = 200;
ellipseAreaMax = 5500;

% centeroid of the ROI goes here
imcenterx = round(size(imageROI,2)/2);
imcentery = round(size(imageROI,1)/2);

%structure to save ellipse information
ellipse_t = struct('a',[],'b',[],'phi',[],'X0',[],'Y0',[],'X0_in',[],'Y0_in',[],'long_axis',[],'short_axis',[],'status',[]);


% sharpen image
imSharp = imsharpen(imageROI,'Radius',15,'Amount',1.2,'Threshold',0);
imGraySharp = rgb2gray(imSharp);
imAdjSharp = imadjust(imGraySharp);%adjust levels of grayscale image


imBWSharp = im2bw(imAdjSharp,0.65);%convert to binary image
imBWSkel = bwmorph(~imBWSharp,'thin',inf); % create the skeleton

% extract regions (in this case line segments, due to skeletanization) of
% interest
stats = regionprops(imBWSkel,'Area','Centroid','Eccentricity','ConvexImage','ConvexHull');

% filter the regions within the predefined length range
fidx = ((cat(1,stats.Area) > lengthMin) & (cat(1,stats.Area) < lengthMax));
fstats = stats(fidx);

% for each line segment, generate a fitting ellipse
for j=1:size(fstats,1)
    convexHull = fstats(j).ConvexHull;
    ellipse_t(j) = fit_ellipse(convexHull(:,1),convexHull(:,2));%fit_ellipse function
end

% calculate the centroids and areas of the ellipses generated
centroid = [cat(1,ellipse_t.X0_in) cat(1,ellipse_t.Y0_in)];
area = cat(1,ellipse_t.long_axis).*cat(1,ellipse_t.short_axis)*pi/4;% area=a.b.pi

% filter ellipses within area range and of which the centroids are closer
% to the center of imageROI

if (size(centroid,1) > 0)% if there are any ellipses detected
    ffidx = (centroid(:,1) > (imcenterx-(imcenterx/3))) & (centroid(:,1) < (imcenterx+(imcenterx/3)) ) & (centroid(:,2) > (imcentery-(imcentery/3))) & (centroid(:,2) < (imcentery+(imcentery/3))) & (area > ellipseAreaMin ) & ( area < ellipseAreaMax) ;
    fellipse_t = ellipse_t(ffidx);
    ffstats = fstats(ffidx);
else
    fellipse_t = ellipse_t;
    ffstats = fstats;
end

%centroids of the filtered ellipses
centroid = [cat(1,fellipse_t.X0_in) cat(1,fellipse_t.Y0_in)];

dis2center =[]; % a vector to store distance between centroid of the image and centroid of each ellipse

% calculate area and eccentricity
if (size(centroid,1)>0) % if there any ellipses,
    %for each ellipse calculate the distance to the center of the image
    for q=1:size(fellipse_t,2)
        dis2center(q) = ((imcenterx - centroid(q,1))^2) + ((imcentery - centroid(q,2))^2); % check the distance between the centroid of the ellipse and centroid of the ROI
    end

    % get the distance value and corresponding index for the minimum
    % distance
    [M,fffidx] = min(dis2center);
    
%     % Plot the ellipse on the image (For display purposes only) 
%     % ---------------------------------------------------------------------
%     hF = figure(); %figure handle
%     hAx = axes('Parent', hF); %axis handle
%     ellipse_temp= fit_ellipse_wIm(ffstats(fffidx).ConvexHull(:,1),ffstats(fffidx).ConvexHull(:,2),hAx,imageROI,n);
%     % ---------------------------------------------------------------------
    
    % Identify the region under the ellipse
    [X, Y] = meshgrid(1:size(imageROI,2), 1:size(imageROI,1)); %create meshgrid
    
    A = (fellipse_t(fffidx).a-boundaryThres);% semi-major axis (minus threshold)
    B = (fellipse_t(fffidx).b-boundaryThres);% semi-minor axis (minus threshold)
    h = fellipse_t(fffidx).X0_in; % centroid x
    k = fellipse_t(fffidx).Y0_in; % centroid y
    Phi = -fellipse_t(fffidx).phi;% angle 

    A2 = A*A;
    B2 = B*B;
    A2B2 = A2*B2;
    
    inellipse = (B2*((X-h)*cos(Phi)+(Y-k)*sin(Phi)).^2 + A2*((X-h)*sin(Phi)-(Y-k)*cos(Phi)).^2) <= A2B2; % indexes inside the ellipse

    %create the mask
    maskedimage = imGraySharp;
    maskedimage(~(inellipse)) = 0; %change area outside the ellipse to black

%     % Save cropped image (For display purposes only)
%     %----------------------------------------------------------------------
%     colneeded = any(inellipse,1);
%     rowneeded = any(inellipse,2);
%     croppedimage = maskedimage(rowneeded', colneeded);
%     
%     outputFileName = strcat('D:\Project_Vineyard\Task06_StomateDetection\TestResults\results\Skeleton\cropped\', num2str(n),'.jpeg');
%     imwrite(croppedimage,outputFileName);
%     %----------------------------------------------------------------------
        
    % Now use masked image to get the stomatal opening
    maskedBW = im2bw(maskedimage,0.65);% convert to binary image
    
%     % Display binary segmented masked image
%     %----------------------------------------------------------------------
%     %imshow(maskedBW);
%     %pause(2);
%     %----------------------------------------------------------------------
       
    % extract regions from the masked image
    maskedStats = regionprops((maskedBW),'Area','Centroid','Eccentricity','ConvexImage','ConvexHull');
    
    if (size(maskedStats,1) > 0)% if there are any ellipses detected
        mfidx = (cat(1,maskedStats.Area) > ellipseAreaMin) & ( cat(1,maskedStats.Area) < ellipseAreaMax) ;
        fmaskedStats = maskedStats(mfidx);
        
        mcentroid = cat(1,fmaskedStats.Centroid);
        dis2center_2 = [];
        
        if(size(mcentroid,1)>0)
            for q=1:size(mcentroid,1)
                dis2center_2(q) = ((imcenterx - mcentroid(q,1))^2) + ((imcentery - mcentroid(q,2))^2); % check the distance between the centroid of the ellipse and centroid of the ROI
            end
            
            
            % get the distance value and corresponding index for the minimum
            % distance
            [M,mffidx] = max(cat(1,fmaskedStats.Area));%min(dis2center_2);
            
            %[M,maskedfidx] = max(cat(1,maskedStats.Area)); % get the largest area
            ffmaskedStats = fmaskedStats(mffidx); % get the region with min distance to center
            
            %return eccentricity and area from the function
            eccentricity = ffmaskedStats.Eccentricity;
            area = ffmaskedStats.Area;
            
            % For Display purposes
            %----------------------------------------------------------------------
            figure()
            imshow(imageROI);
            hold on;
            plot(ffmaskedStats.ConvexHull(:,1), ffmaskedStats.ConvexHull(:,2),'g','LineWidth',2);
            print('-djpeg','-r600',strcat(outputPathSkel,num2str(inc)));
            %----------------------------------------------------------------------
            close all;
            

            
        else
            
            eccentricity = NaN;
            area = NaN;
            
        end
    else
       eccentricity = NaN;
       area = NaN; 
    end
else
    eccentricity = NaN;
    area = NaN;
end




end

