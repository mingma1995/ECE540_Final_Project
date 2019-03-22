numrows = 256;  % Changed part for different resolution ratio
numcols = 512;  % Changed part for different resolution ratio

img = imread('Initial_final_1.jpg'); % Reading the picture file

imgresized = imresize(img, [numrows numcols]); % Get the size of the picture

[rows, cols, rgb] = size(imgresized); % three-dimensional array

imgscaled = imgresized/16 - 1; %Hex
imshow(imgscaled*16); % show the  RGB picture

fid = fopen('Initial_final_1_512_256.coe','wt'); % changing part creat a file 

fprintf(fid,'memory_initialization_radix=16;\n'); % wirte into file radix
fprintf(fid,'memory_initialization_vector=\n'); % wirte into file the vector

  % transfor function and write into the file 
count = 0;  
for r = 1:rows
    for c = 1:cols
        red = uint16(imgscaled(r,c,1)); %  16-bit unsign integer number  
        green = uint16(imgscaled(r,c,2));
        blue = uint16(imgscaled(r,c,3));
        color = red*(256) + green*16 + blue; 
       fprintf(fid,'%3X\n', color); % 3-bit base 16
        count = count + 1;
    end
end
fclose(fid); % close the file 