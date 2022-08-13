%% Intro
% Title: CA Project Simulation
% Semester: Fall 1400
% Instructor: Dr. Sanaz Seyedin
% Project Author: Amirhossein Bayat
%%
% Clear all and set random seed
clear
rng('default');
rng(50);
%% Part a) Reading photo
img = imread('Photo.jpg');
figure(1)
imshow(img,'InitialMagnification','fit')
title('Original Picture')
%% Part b) Writing original photo to a txt file
% For matlab version 2019a use function below
% writematrix(img,'Photo.txt','Delimiter',',')
% For previous matlab version use function below
dlmwrite('Photo.txt',img,'delimiter',',')
%% Part c) Make noisy photo and writing it to a txt file
noisy = imnoise(img,'gaussian',0,0.01);
dlmwrite('Noisy.txt',noisy,'delimiter',',')

figure(2)
subplot(1,2,1)
imshow(img)
title('Original Picture')
subplot(1,2,2)
imshow(noisy)
title('Gaussian Noise on Picture')
%% Part d) Padding Images (Symmetric means we use neigbour cell for padding)
kernel_size = 3;
pad_size = (kernel_size-1)/2;
Pd_Img = double(padarray(img, [pad_size, pad_size], 'symmetric'));
Pd_Noisy = double(padarray(noisy, [pad_size, pad_size], 'symmetric'));
dlmwrite('Noisy_Padding.txt',Pd_Noisy,'delimiter',',')
dlmwrite('Photo_Padding.txt',Pd_Img,'delimiter',',')
%% Part e) Edge Detection filtering on original image
edge_Img = zeros(size(img));
edge_kernel = [0 1 0;
              1 -4 1;
              0 1 0];
[m, n] = size(img);
% Calculating every pixel value using for loops
for i=1:m % Loop on Rows
    for j=1:n % % Loop on Columns
        % Select a part of image around the pixel to apply kernel to it
        selected = Pd_Img(i:i+kernel_size-1, j:j+kernel_size-1);
        edge_Img(i,j) = 64 + (sum( sum( edge_kernel .* selected ) ) / 4);
        if edge_Img(i,j) < 0
            print("HI")
        end
    end
end
% Cast to uint8 for imshow
edge_Img = cast(edge_Img,'like',img);

figure(3)
suptitle("Not looking good right?  Let's apply a threshold")
subplot(1,2,1)
imshow(img)
title('Original Picture')
subplot(1,2,2)
imshow(edge_Img)
title('Edge Detection')

% Applying a threshold to detect sharp edges
edge_Img(edge_Img<101) = 0;
edge_Img(edge_Img>100) = 255;

figure(4)
suptitle("That's better")
subplot(1,2,1)
imshow(img)
title('Original Picture')
subplot(1,2,2)
imshow(edge_Img)
dlmwrite('edge_Img_Img.txt',edge_Img,'delimiter',',')
title('Edge Detection with threshold')

%% Part f) Noise filtering on noisy image
denoised_Img = zeros(size(img));
gaussian_kernel = [1 2 1;
                   2 4 2;
                   1 2 1];
[m, n] = size(img);
% Calculating every pixel value using for loops
for i=1:m % Loop on Rows
    for j=1:n % % Loop on Columns
        % Select a part of image around the pixel to apply kernel to it
        selected = Pd_Noisy(i:i+kernel_size-1, j:j+kernel_size-1);
        denoised_Img(i,j) = sum( sum( gaussian_kernel .* selected ) ) / 16;
    end
end
% Cast to uint8 for imshow
denoised_Img = cast(denoised_Img,'like',img);
dlmwrite('denoised_Img.txt',denoised_Img,'delimiter',',')


figure(5)
subplot(1,2,1)
imshow(noisy)
title('Noisy Picture')
subplot(1,2,2)
imshow(denoised_Img)
title('Denoised Picture')