# Image Processing using assembley 
In this project, we implement 2 kernels on an image using assembley language.

## MATLAB code 
In the MATLAB script we have different sections to manipulate the image:

### Part a) 
Magnifying the image and showing it in the `Original Picture` plot window.

### Part b) 
Converting the image to bytes.

### Part c) 
Creating a noisy image using `gaussian random noise` and showcasing it next to the original photo.

### Part d) 
Adding `padding` to the image edges so we can apply the kernels to all the data extracted from the image.

### Part e) 
Applying the specified `edge detection` filter on the desired image.

### Part e) 
Applying the specified `gaussian` kernel on the desired image.

## Assembley code 
In this code we read the data created by the MATLAB script and load them in the designated memory spots. We do the same for the kernels.
Using assembly instructions we apply the `gaussian` filter and the `edge detection` filter to the loaded data and save them in memory.

