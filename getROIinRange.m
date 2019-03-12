function [ROIinRange,numROIinRange] = getROIinRange(bbox,areaMax,areaMin)
	% COPYRIGHT: Hiranya Jayakody. April 2017.
    % GETROIINRANGE Reject ROIs which are too large or too small and returns ROIs within a
    % specific size range
    
    % inputs
    %   bbox - a vector including information on rectangular ROIs
    %   areaMax - maximum allowable area of an ROI
    %   areaMin - minimum allowable area of and ROI
    
    % outputs
    %   ROIinRange - a vector including information on ROIs within range
    %   numROIinRange - number of ROIs in range

    if (bbox > 0)
        Areas = bbox(:,3).*bbox(:,4); % Get area of an identified ROI
        filteredAreas = (Areas > areaMin) & (Areas < areaMax); % limit the size of the ROI based on the limits set depending on zoom level
        ROIinRange = bbox(filteredAreas,:);
        numROIinRange = size(ROIinRange,1); % save
    else
        ROIinRange = bbox;
        numROIinRange = 0; % save
    end
end

