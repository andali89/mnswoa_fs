% Copyright (c) 2022, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% The Implementation of NSGAII-DMS algorithm.
% Author: An-Da Li 
% Email: andali1989@163.com

function [trainset, testset] = divData(data, trainN, testN)
allfolds = trainN + testN;
data.stratify(allfolds);

testset = data.testCV(allfolds, 0);
for i = 1 : testN - 1
    testset.addAll(data.testCV(allfolds, i));    
end

trainset = data.testCV(allfolds, testN);
for i = 1 : trainN -1
   trainset.addAll(data.testCV(allfolds, i + testN));   
end

indexes = trainset.attributeToDoubleArray(trainset.numAttributes() - 1); 

% Number of classes
classNums = max(indexes) + 1;
% weight of instances in each class
classWeight = zeros(classNums, 1);
% numver of instances in the training set
InsNums = trainset.numInstances();
for i = 1 : classNums
   classWeight(i, 1) = InsNums / sum(indexes == (i - 1)) ;    
end
classWeight

% for each instances set weight
for i = 1: InsNums
   weight = classWeight(indexes(i) + 1);
   trainset.get(i - 1).setWeight(weight); 
   
end



end