function temp = window(data, samples)
%apply a window across a vector of data
%return a matrix of windowed data

clmns = 2*samples +1; 
temp = zeros(clmns, length(data));  %zeros matrix

for i = 1:clmns
    temp(i, :) = circshift(data, -i);
end 
 temp = round([real(temp); imag(temp)], 5); %round to 5 decimal places 
end 
