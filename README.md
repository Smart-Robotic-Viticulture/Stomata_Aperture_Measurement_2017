# Stomata_Aperture_Measurement_2017

Author: Hiranya Jayakody. April 2017.
E-mail: hiranya.jayakody@unsw.edu.au

This repository contains code written in Matlab to, 
1. Detect stomata
2. Measure aperture of detected stomata, 
for a given set of microscope images of vine leaves.

This work is published in the Journal of Plant Methods. The paper can be accessed at: https://plantmethods.biomedcentral.com/articles/10.1186/s13007-017-0244-9

The corresponding dataset can be downloaded from:
http://www.robotics.unsw.edu.au/srv/dataset/jayakody2017plantmethods.html

Tested on Matlab 2016b and higher versions.

# File Description

- Main file: VWS_StomataDetection_COD_Skeletanized.m
- Function files: 
  1. getROIinRange.m - extracts regions of interest which contain stomata
  2. getSkeletanizedAperture.m	- applies a skeletanization method to measure the pore opening of the stomata
  3. getStomataOpening.m - applies a segmentation based technique to measure the pore opening of the stomata
  4. fit_ellipse.m	- fit an ellipse to a line segment (Copyright to: Ohad Gul)

- Pre-trained Cascade Object Detector to test the code: stomateDetector_v0.xml (to avoid training, set training=false)
- A sample Matlab labeling Session containing ground truths: Test.mat (to enable training, set training=true)

# Parameter tuning

Several parameters need to be tuned to achieve best possible result for a given dataset.

(Complete description will be published soon)


# Data preparation

ManualDataCollector.m - this code allows you to click on individual stomata in an image and generate a series of small cropped images containing single stoma.

# Acknowledgements
We would like to thank Wine Australia for funding the research, and South Australia Research and Development Institute (SARDI) and Australian Wine Research Institute (AWRI) for leading this research. Our acknowledgements also go to Mickey Wang for his assistance in collecting and capturing data from the field. If you use this code to generate any results, please cite the paper below.

https://plantmethods.biomedcentral.com/articles/10.1186/s13007-017-0244-9

# Disclaimer

This algorithm was developed for the following dataset:
http://www.robotics.unsw.edu.au/srv/dataset/jayakody2017plantmethods.html
The performance may vary for new datasets depending on the quality of the data.


