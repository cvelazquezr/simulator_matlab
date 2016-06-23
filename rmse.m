function [ error ] = rmse( data1, data2 )
% It is mandatory that the two data has the same size

error = sqrt(sum((data1 - data2).^2) / length(data1));

end

