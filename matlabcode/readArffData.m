% Copyright (c) 2022, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% The Implementation of NSGAII-DMS algorithm.
% Author: An-Da Li 
% Email: andali1989@163.com

% Read the Arff data in Weka
function data=readArffData(x)
read=weka.core.converters.ArffLoader;
read.setFile(java.io.File (x));
data=read.getDataSet();
data.setClassIndex(data.numAttributes()-1);
%data=data2
end