close all;
clc;

image = imread('slice102.bmp');
image=im2double(image);
%%-------declarations--------------%%%
[rows cols]=size(image);
%%------Canny Edge image------------%%%
canny_image=edge(image,'canny',0.075);
figure('Name','Canny edges in Image ');
imshow(canny_image);
%%------Edge preserving smoothing----%%%
Gx = [1 0 -1; 2 0 -2; 1 0 -1];
Gy = [1 2 1; 0 0 0; -1 -2 -1];

%%for a=1:2 %%iterations
    
Gx = imfilter(image, Gx);
Gy = imfilter(image, Gy);
% figure('Name','Gradient in x direction');
% imshow(Gx);
% figure('Name','Gradient in y direction');
% imshow(Gy);
for x = 1:rows 
  for y = 1:cols 
    G_magnitude (x,y) = (Gx(x,y).^2 + Gy(x,y).^2);       %%Gradient_mag calculated
  end
end  
 figure('Name','Gradient magnitude is : ');   
 imshow(G_magnitude);
Gaussian_filter = zeros(rows, cols);
k = 0.74; %Threshold for smoothing
for x = 1:rows 
  for y = 1:cols 
    Gaussian_filter (x,y) = exp(-(abs(G_magnitude(x,y))/(2*k.^2)));    %%Gaussian filtr calculated
  end
end
figure('Name','Gaussian filter is : ');
imshow(Gaussian_filter);
modified_image = zeros(rows, cols);
for x = 2:rows-1 
  for y = 2:cols-1
    normalized_value = 0; 
      for i = -1:1
          for j=-1:1
            normalized_value = normalized_value + Gaussian_filter (x + i, y + j);
            modified_image(x, y)= modified_image(x, y)+(image(x + i, y + j).*Gaussian_filter (x + i, y + j));
          end
      end
      modified_image(x, y)= (1/normalized_value)*modified_image(x, y);
  end
end 
figure('Name','modified img new : ');
imshow(modified_image);
%%end
imwrite(modified_image, 'gaussian.bmp');
modified_image=imread('gaussian.bmp');
[rows cols]=size(modified_image);

%%------------------Region growing--------------------%%
labelled_image = zeros (rows,cols);
label_region = 1;
for x = 1:rows
    for y = 1:cols
        if (labelled_image(x,y) == 0)
            labelled_image = grow(modified_image,x,y,label_region,labelled_image);
            label_region = label_region + 1;
        end
    end
end

log_mask = [0 1 0; 1 -4 1; 0 1 0];
image_grow = imfilter(labelled_image, log_mask);
figure('Name','Result of Image growing ');
imshow(image_grow);

%%------------------Region merging--------------------%%

merged_image = merge(image_grow, labelled_image, label_region);
log_mask = [0 1 0; 1 -4 1; 0 1 0];
image_merge = imfilter(merged_image, log_mask);
figure('Name','Result of Image merging ');
imshow(image_merge);

%%---------------Boundary Elimination-----------------%%

bound_elim_image = boundary_elimination(image_merge, merged_image);
log_mask = [0 1 0; 1 -4 1; 0 1 0];
final_image = imfilter(bound_elim_image, log_mask);
figure('Name','Result of Boundary Elimination ');
imshow(final_image);