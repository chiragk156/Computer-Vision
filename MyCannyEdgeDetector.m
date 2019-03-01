function output = MyCannyEdgeDetector(image,threshold)
%This is a function to detect edges in an image using Canny Edge algorithm.
%   Image can be rgb or grayscale. Method use two thresholds. MyCannyEdgeDetector disregards all edges with edge strength below the lower threshold, and preserves all edges with edge strength above the higher threshold. You can specify threshold as a 2-element vector of the form [low high] with low and high values in the range [0 1]. You can also specify threshold as a numeric scalar, which MyCannyEdgeDetector assigns to the higher threshold. In this case, MyCannyEdgeDetector uses threshold*0.4 as the lower threshold. 

% Checking if image is rgb or grayscale
if (ndims(image)==3)
    image = double(rgb2gray(image));
else
    image = double(image);
end

[m,n] = size(image);
% Default sigma = sqrt(2) for Gaussian filter
image = imgaussfilt(image,sqrt(2));
% Sobel Filter
sobel_x = [1 2 1; 0 0 0; -1 -2 -1];
sobel_y = sobel_x';

% Checking if threshold contains both or single threshold
if(size(threshold,2)==2)
    low_t = threshold(1);
    high_t = threshold(2);
else
    high_t = threshold;
    low_t = 0.4*high_t;
end

grad_x = conv2(image,sobel_x,'same');
grad_y = conv2(image,sobel_y,'same');


grad_magnitude = sqrt(grad_x.^2 + grad_y.^2);

low_t = low_t*max(max(grad_magnitude));
high_t = high_t*max(max(grad_magnitude));

grad_direction = atan2(grad_y,grad_x) * 180/pi;

for i=1:m
    for j=1:n
%         Checking if direction is -ve. Both -ve and 180 + (-ve direction)
%         are equivalent.
        if(grad_direction(i,j) < 0)
            grad_direction(i,j) = grad_direction(i,j) + 180;
        end
    end
end

for i=1:m
    for j=1:n
        if(grad_direction(i,j) <= 22.5)
            grad_direction(i,j) = 0;
        elseif(grad_direction(i,j) <= 67.5)
            grad_direction(i,j) = 45;
        elseif(grad_direction(i,j) <= 112.5)
            grad_direction(i,j) = 90;
        elseif(grad_direction(i,j) <= 157.5)
            grad_direction(i,j) = 135;
        else
            grad_direction(i,j) = 0;
        end
    end
end

edge_points = NMS(grad_direction,grad_magnitude);

output = Hysterysis(edge_points,grad_magnitude,low_t,high_t);

end