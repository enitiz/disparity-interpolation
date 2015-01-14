pkg load image
%Write a script that processes stereo image pair to generate disparity map
%using dynamic programming
% Functions

% Load images
Image1 = rgb2gray(imread('Data/view5.png'));
Image2 = rgb2gray(imread('Data/view1.png'));
ImageGT1 = double(imread('Data/disp1.png'));
ImageGT5 = double(imread('Data/disp5.png'));

% Image width and height
[image_height, image_width] = size(Image1);

A = zeros(image_width, image_width);
DisparityMapL = zeros(image_height, image_width);
DisparityMapLN = zeros(image_height, image_width);
DisparityMapR = zeros(image_height, image_width);
DisparityMapRN = zeros(image_height, image_width);

mean_squared_errorL = 0;
mean_squared_errorR = 0;

for y = 2: image_height
  for i = 2:image_width
    for j = 2:image_width
      % Calculate Matrix
      % Write
      a5 = Image1(y, j) - Image2(y, i);
      % DP matrix read
      b1 = double(A(i-1, j));
      b2 = double(A(i, j-1));
      b3 = double(A(i-1, j-1));
      % Minimum
      b4 = min([b1, b2, b3]);
      % Reusing Path
      % Write
      A(i, j) = a5 + b4;      
    end  
  end
  i = image_width-1;
  j = image_width-1;
  while and(i >= 2, j >= 2)
   % Step 2: Find Path
   c1 = A(i-1, j);
   c2 = A(i, j-1);
   c3 = A(i-1, j-1);
   % Minimum
   c4 = min([c1, c2, c3]);
   % Weighted path direction
   % Choose new position
   if c4 == c1
     j = j-1;
     i = i-1;
   elseif c4 == c2
     j = j-1;
   elseif c4 == c3
     i = i-1;
   end
   % Remember Paths
   A(i, j) = 255;
   % Write
   DisparityMapL(y, i) = abs(j-i);
   DisparityMapR(y, j) = abs(i-j); 
  end
end

for base_pixel_y = 1: image_height
  for base_pixel_x = 1: image_width
    mean_squared_errorL = mean_squared_errorL + (ImageGT5(base_pixel_y, base_pixel_x) - DisparityMapL(base_pixel_y, base_pixel_x)).^2;
    DisparityMapLN(base_pixel_y, base_pixel_x) = uint8(255 * (DisparityMapL(base_pixel_y, base_pixel_x)-0) / (500 - 0));
  end
end
mean_squared_errorL = mean_squared_errorL/(image_height*image_width);

for base_pixel_y = 1: image_height
  for base_pixel_x = 1: image_width
    mean_squared_errorR = mean_squared_errorR + (ImageGT1(base_pixel_y, base_pixel_x) - DisparityMapL(base_pixel_y, base_pixel_x)).^2;
    DisparityMapRN(base_pixel_y, base_pixel_x) = uint8(255 * (DisparityMapR(base_pixel_y, base_pixel_x)-0) / (500 - 0));
  end
end
mean_squared_errorR = mean_squared_errorR/(image_height*image_width);

mean_squared_errorL
mean_squared_errorR

%newmap = colormap(gray(70));
imwrite(uint8(DisparityMapL), 'DP_DisparityMapLN.png');
imwrite(uint8(DisparityMapR), 'DP_DisparityMapRN.png');

































%imshow(Disparity,[]), axis image, colormap('jet'), colorbar;
%caxis([0 disparityRange]);
%imwrite('DisparityDyn.png', Disparity);