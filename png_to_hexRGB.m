%%%% 10/27/2021
%%%% Kirsten Olsen
%%%% Turns picture into MIF file

stickman = imread('plain_white.png');

% turn image into 32x32 and extract RGB channels
stickman32 = imresize(stickman, [32, 32]);
redChannel = stickman32(:, :, 1);
greenChannel = stickman32(:, :, 2);
blueChannel = stickman32(:, :, 3);

%%% View image
% subplot(2, 2, 2);
% imshow(redChannel, []);
% title('Red Channel Image');
% subplot(2, 2, 3);
% imshow(greenChannel, []);
% title('Green Channel Image');
% subplot(2, 2, 4);
% imshow(blueChannel, []);
% title('Blue Channel Image');


% Transpose matrices into column vectors
columnRed = reshape(redChannel',[],1);
columnGreen = reshape(greenChannel',[],1);
columnBlue = reshape(blueChannel',[],1);

%Convert decimal to hex
hexRed = dec2hex(columnRed);
hexGreen = dec2hex(columnGreen);
hexBlue = dec2hex(columnBlue);

%%%USE THIS FOR uP RAM writing
%concatenate into single rgb string column
rgbmatrix = char(zeros(1024,6));
for i = 1:1024
    rgbmatrix(i,:) = strcat(hexRed(i,:),hexGreen(i,:),hexBlue(i,:));
end 
 

%%%USE THIS FOR MIF FILES
% concatenate upper and lower rgb 
mif_matrix = char(zeros(512,12));
mif_matrix(:,[1:6]) = rgbmatrix([1:512],:);
mif_matrix(:,[7:12]) = rgbmatrix([513:1024],:);

%add the numbers, spaces and colon from mif file
mif_numbers = zeros(512,1);
    for i = 1:512
        mif_numbers(i,:) = i-1;
    end 
mif_char_numbers = char(zeros(512,3));
    for i = 1:10
        mif_char_numbers(i,3) = int2str(mif_numbers(i,:));
        mif_char_numbers(i,[1:2]) = '  ';
    end
    for i = 11:100
        mif_char_numbers(i,[2:3]) = int2str(mif_numbers(i,:));
        mif_char_numbers(i,1) = ' ';
    end 
    for i = 101:512
        mif_char_numbers(i,:) = int2str(mif_numbers(i,:));
    end 
    mif_colon = char(zeros(512,20));
    for i = 1:512
        mif_colon(i,:) = '  :                 ';
    end 
mif_semicolon = char(zeros(512,1));
    for i = 1:512
        mif_semicolon(i,:) = ';';
    end 

%concatenate all together for final mif
mif_final = char(zeros(512,36));
for i = 1:512
    mif_final(i,:) = [mif_char_numbers(i,:) mif_colon(i,:) mif_matrix(i,:) mif_semicolon(i,:)];
end

writematrix(mif_final, 'plain_white');


