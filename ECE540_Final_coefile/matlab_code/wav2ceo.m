%Reference: https://github.com/gajjanag/6111_Project/tree/master/assets/audio_convert
input = audioread('C:\Users\58390\Desktop\test_audio\BOMB.wav');     %Loads the given wave file
sound(input);                    %Plays the given wave file
plot(input);                     %Draws the given wave file

data = input(1:14000);

bits = 8;
scaled_data = data*(2^(bits-1))-1;  %scale the floats appropriately (it's two's complement)
rounded_data = round(scaled_data);  %rounds them down

%make the data 2's complement
for i = 1:length(rounded_data)
    if(rounded_data(i)>=0)
        data(i) = rounded_data(i);
    else
        data(i) = ((2^bits)-abs(rounded_data(i)));  %2's compliment
    end
end

%convert to binary
data = dec2bin(data,bits);

%open a file
output_name = 'BOMB.coe';
file = fopen(output_name,'w');

%write the header info
fprintf(file,'memory_initialization_radix=2;\n');
fprintf(file,'memory_initialization_vector=\n');
fclose(file);

%put commas in the data
rowxcolumn = size(data);
rows = rowxcolumn(1);
columns = rowxcolumn(2);
output = data;
for i = 1:(rows-1)
    output(i,(columns+1)) = ',';
end
output(rows,(columns+1)) = ';';

%append the numeric values to the file
dlmwrite(output_name,output,'-append','delimiter','', 'newline', 'pc');

%You're done!