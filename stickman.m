left = imread('left_source.jpg');
right = imread('right_source.jpg');
top = imread('top_source.jpg');
bottom = imread('bottom_source.jpg');
% Max composite 
max_horizontal = max(top, bottom);
max_vertical = max(left, right);
maximg = max(max_horizontal, max_vertical);
% Normalize by computing ratio images
r1 = left./ maximg;		r2 = top ./ maximg;
r3 = right ./ maximg;	r4 = bottom ./ maximg;
% Compute confidence map
v = fspecial( 'sobel' ); h = v';
d1 = imfilter( r1, v ); d3 = imfilter( r3, v );  % vertical sobel
d2 = imfilter( r2, h ); d4 = imfilter( r4, h ); % horizontal sobel
%Keep only negative transitions 
silhouette1  = double(d1) .* double((d1>0));      
silhouette2 = abs( double(d2) .* double((d2<0)) );
silhouette3 = abs( double(d3) .* double((d3<0)) );
silhouette4  = double(d4) .* double((d4>0));
%Pick max confidence in each
max_oneTwo = max(silhouette1, silhouette2);
max_threeFour = max(silhouette3, silhouette4);
confidence = max(max_oneTwo, max_threeFour);
imwrite( confidence, 'confidence.bmp');
imshow(confidence);