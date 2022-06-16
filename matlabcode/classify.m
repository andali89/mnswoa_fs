% Copyright (c) 2022, An-Da Li
% All rights reserved. Please read the "license" for license terms.
% The Implementation of NSGAII-DMS algorithm.
% Author: An-Da Li 
% Email: andali1989@163.com

function [predictedclass,rate,conf_matrix]=classify(classifier,testData)
        num_c=testData.numClasses();
        class_set=zeros(num_c,1);
        testnum=testData.numInstances();
        classProbs=zeros(testnum,testData.numClasses());
        actual = testData.attributeToDoubleArray(testData.classIndex());   
        for t=0:testnum -1  
            classProbs(t+1,:) = classifier.distributionForInstance(testData.instance(t))';
        end
         [~,predictedclass] = max(classProbs,[],2);
        predictedclass=predictedclass-1;
       
        rate = sum(actual == predictedclass)/testnum; 
        
        if nargout >=3
            act_pre=[actual,predictedclass];
            conf_matrix=zeros(num_c,num_c);
            for i=1:num_c
                ins_now=act_pre(act_pre(:,1)==i-1,:);
                for j=1:num_c
                conf_matrix(i,j)=sum(ins_now(:,2)==j-1);    
                end
            end
                     
        end

      
                     
end