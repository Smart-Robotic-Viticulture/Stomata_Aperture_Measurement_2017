% MANUAL TRAINING DATA COLLECTOR
%================================

% Author : Hiranya Jayakody. Feb 2017.
% email : hiranyajayakody@gmail.com for more info.

% This code is used to collect samples from a larger image, so the sample
% can be later used as training data for machine learning.

% HOW TO USE THE CODE
%=====================

% 1. Set Source folder, Destination Folder, and the cropped image width and
%    height.
% 2. Run the code.
% 3. Use left mouse button to select objects of interest. When
%    left-clicked, an 350x350 (this can be varied by changing the 'height' and 'width' variables) pixel image would be cropped out (where the center of the image is
%    the mouse click position) and saved in the destination folder.
% 4. Right-click to go to the next source image.
% 5. Close the image window to exit the program.

% Select the directory where the source image(s) reside (Please edit)
sourceFolder = 'G:\VYEP Datasets\FT3_3_C_40A\BunchPhotos\';

% Select the folder where cropped images should be saved to (Please edit)
destFolder= 'D:\Project_Vineyard\Task11_PeaSizedBunchReconstruction\Data\Training Data in Vivo\Temp\';

% Select width and height of the cropped image.(Can be edited)
height = 220;
width = 220;

% Extract all image info from the folder
imsetTest = imageSet(sourceFolder);

counter = struct('imageID',[],'numStomata',[],'vector',[]); %struct to hold counter values
j = 551; % increases once per iteration until the program closes/the id of the image saved.

for n = 1:imsetTest.Count
    
    imTest = read(imsetTest,n); % read current image
    
    %image resize step for Laga's method (this line is a temporary
    %addition)
    % imTest = imresize(imTest,0.25);
    
    m = 2; % changes on mouse click type
    count = 0;i = 1;vec = [];
    
    % Maximum dimansions of the original image    
    widthMax = size(imTest,2);
    heightMax = size(imTest,1);
    
    % Show image
    figure(1);
    imshow(imTest);
    hold on;
    
    while m > 1
        [x,y,button] = ginput(1);
        
        if (button == 3) % mouse right-click
            m = 0;
            counter(n).vector = vec;
        else
            plot(x, y, '+g','MarkerSize',10,'LineWidth',1.5);
            hold on;
            count = count + 1; % increases on number of mouse clicks
            vec(i,2) = x;
            vec(i,1) = y;
            i = i + 1;
            
            % Crop the image based on the mouse click
            
            %determine the corner points of the cropped image
            x_ul = round(x) - (width/2);
            y_ul = round(y) - (height/2);
            
            if (x_ul < 1)
                x_ul = 1;
            end
            
            if (y_ul < 1)
                y_ul = 1;
            end
              
            x_ur = x_ul + width;
            y_ll = y_ul + height;
            
            % check whether the cropped image lies within the original image dimensions. 
            if (x_ur > widthMax)
                x_ur = widthMax;
            elseif(x_ul < 0)
                x_ur = 0;
            else
            end
            
            if ( y_ll > heightMax)
                y_ll = heightMax;
            elseif(y_ul < 0)
                y_ll = 0;
            end
            
            croppedIm = imTest(y_ul:y_ll,x_ul:x_ur,:);
            %handles.H = figure(2);
            %imshow(croppedIm);
            
            %Save the cropped image to a folder of preference (Can be
            %changed)
            imwrite(croppedIm,strcat(destFolder,num2str(j),'.jpg'));
            %close(handles.H);
            
            j = j+1;
        end
    end
    
    counter(n).imageID = n; % Save image ID
    counter(n).numStomata = count; % Save the number of samples collected from a particular image
    
    
end