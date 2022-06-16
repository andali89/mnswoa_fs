% Copyright (c) 2022, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% The Implementation of NSGAII-DMS algorithm.
% Author: An-Da Li 
% Email: andali1989@163.com

% normalize the data into [-1, 1]
function datao=dataNorm(data,scale,translation)
    if nargin<2
       
       scale=2;
       translation=-1;
    end
    normer=weka.filters.unsupervised.attribute.Normalize();
    normer.setOptions({'-S',num2str(scale),'-T',num2str(translation)});
    normer.setInputFormat(data);
    datao=weka.filters.Filter.useFilter(data,normer);
end

