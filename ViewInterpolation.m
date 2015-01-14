% parameters
interp = 0.5;   % interpolation factor of 0.5 should give a virtual view exactly at the center of line connecting both the cameras. can vary from 0 (left view) to 1 (right view)

% read in images and disparity maps
i1 = imread('Data/view1.png');           % left view
i2 = imread('Data/view5.png');           % right view
d1 = double(imread('Data/disp1.png'));   % left disparity map, 0-255
d2 = double(imread('Data/disp5.png'));   % right disparity map, 0-255
view3 = imread('Data/view3.png');

% tag bad depth values with NaNs
d1(d1==0) = NaN;
d2(d2==0) = NaN;
shift_x = 0;
change_at_x = 0;


[image_height, image_width] = size(d1);
ImageMid = uint8(zeros(size(i2)));

for base_pixel_y = 1 : image_height
  for base_pixel_x = 1 : image_width
    shift = ceil(d2(base_pixel_y, base_pixel_x) * interp);
    change_at_x = base_pixel_x + shift;
    if change_at_x <= image_width
      if ImageMid(base_pixel_y, change_at_x) == 0
        ImageMid(base_pixel_y, change_at_x, :) = i2(base_pixel_y, base_pixel_x, :);
      end
    end
  end
end

for base_pixel_y = 1 : image_height
  for base_pixel_x = 1 : image_width
    shift = ceil(d1(base_pixel_y, base_pixel_x) * interp);
    change_at_x = base_pixel_x - shift;
    if change_at_x >= 1
      if ImageMid(base_pixel_y, change_at_x) == 0
        ImageMid(base_pixel_y, change_at_x, :) = i1(base_pixel_y, base_pixel_x, :);
      end
    end
  end
end

 for base_pixel_y = 1: image_height
  for base_pixel_x = 1: image_width
    mean_squared_error = mean_squared_error + double((ImageMid(base_pixel_y, base_pixel_x, :) - view3(base_pixel_y, base_pixel_x, :)).^2);
  end
end

mean_squared_error = mean_squared_error/(image_width*image_height);

ImageMid(ImageMid==0) = NaN;

mean_squared_error

imshow(ImageMid);
imwrite(ImageMid, 'ViewInterpolationResult.png');