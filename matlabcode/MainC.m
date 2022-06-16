% Copyright (c) 2022, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% The Implementation of NSGAII-DMS algorithm.
% Author: An-Da Li 
% Email: andali1989@163.com

%

%% The main procedure of the MNSWOA

% multi-objective approach


%%

clc;
%clear all

close;
%% Add weka path

addwekapath;

discription = 'MWOA';
disp('mutation way new')
filename = control.filename;
%% 设置种子
switch filename
    case  'Normbalancesecom'
        seed=38;        
        infold=5;
    case 'Norm2classTL_New'
        seed=40;       
        infold=5;
    case {'SPIRA','spira'}
        seed=30;        
        infold=5;
    case {'PAPER_Balance','paper','PAPER'}
        seed=33;        
        infold=5;
    case 'OXY'
        seed=33;        
        infold=5;
     case 'LATEX'
        seed=29;        
        infold=5;
     case 'ADPN'
        seed=46;        
        infold=5;
     case 'GRANU'
        seed=40;        
        infold=5;
end
    
       
       %% 分类器参数
classifyname='bayes';

if strcmp(classifyname, 'bayes')
    classifier=weka.classifiers.bayes.NaiveBayes();
    classifier.setUseKernelEstimator(1);    
elseif strcmp(classifyname, 'knn')
     knnop={'-K',num2str(knnnum)}; 
    classifier=weka.classifiers.lazy.IBk();
    classifier.setOptions(knnop);  
elseif strcmp(classifyname, 'svm')
    classifier=weka.classifiers.functions.LibSVM();
    [bestacc,bestc,bestg] = SVMcgForClass(trainset); %得到svm参数
    SVMOptions={'-S','0','-K','2','-C',num2str(bestc),'-G',num2str(bestg),'-M','200'};
   classifier.setOptions(SVMOptions);
else
    fprintf('classifier error');
    return;
end

%seed  = control.dataseed;
randseed= control.runseed;
segnum = 10;

%% 读取并归一数据
datapath=['..\mydata\',filename,'.arff'];
clear data;
data=readArffData(datapath);
data=dataNorm(data); %归一化数据
fprintf('attribute num is %d\nnum of instances is %d\n',data.numAttributes()-1,data.numInstances());
numAttri=data.numAttributes()-1;
%随机化并分割数据
data.randomize(java.util.Random(seed));
data.stratify(segnum);
%% parameters for GADMS part I
setupSetting;

%%
Start=tic;
Startcpu=cputime;




for segfold=0:segnum-1
%for segfold=8:8
RandStream.setGlobalStream(RandStream('mt19937ar','seed',randseed + segfold));

disp(['Running fold ',num2str(segfold)]);

%datat.randomize(java.util.Random(seedtest));
trainset=data.trainCV(segnum,segfold);
%trainset.randomize(java.util.Random(seedinfold));
testset=data.testCV(segnum,segfold);

% if control.setw 
%    trainset = setWeights(trainset); 
% end
%% parameters for GADMS part II

%% run  feature selection method
Startin=tic;
Startincpu=cputime;
                                    
[Solution,Trainfunc, iter_result]= WOA(classifier,trainset,setup);
Timein=toc(Startin);
Timeincpu=cputime-Startincpu;
%% get the prediction accuracy for each solution in the final solution set
%classifier.setUseKernelEstimator(1);
numsolution=size(Solution,1);
Conf_matrix=cell(numsolution,1);
pAcc=zeros(numsolution,1);
Sensitivity=zeros(numsolution,1);
Specificity=zeros(numsolution,1);
f1=zeros(numsolution,1);

for i=1:numsolution   
    trainsetr=FeatureSelect(trainset,Solution(i,:));
    testsetr=FeatureSelect(testset,Solution(i,:));
    [~,pAcc(i),Conf_matrix{i,1}]=trainclassify(classifier,trainsetr,testsetr);
     Sensitivity(i)=Conf_matrix{i,1}(1,1)/sum(Conf_matrix{i,1}(1,:));
    Specificity(i)=Conf_matrix{i,1}(2,2)/sum(Conf_matrix{i,1}(2,:));
    preci = Conf_matrix{i,1}(1,1)/sum(Conf_matrix{i,1}(:, 1));
    if (preci + Sensitivity(i)) ==0 || isnan(preci)
        f1(i) = 0;
    else
        f1(i) = ( 2* preci * Sensitivity(i))/ (preci + Sensitivity(i));
        if isnan(f1(i))
           preci
           Sensitivity(i)
           pause
        end
    end
  % train_meanQC(i) = mean(find(Solution(i, :) == 1));   
end
%Trainfunc = [Trainfunc, train_meanQC];
Performance=[Sensitivity,Specificity,pAcc, f1];
%classifier.setUseKernelEstimator(0); 
%% get the perfect point and output the final result
Perfectpoint=perfectpoint(Solution,Trainfunc,Performance,[1 1]);
%Perfectpoint2=perfectpoint(Solution,Trainfunc,Performance,[1 1 0.5]);


disp(['time in fold ',num2str(segfold),' is ',num2str(Timein)]);
%%
 eval(['ARe',num2str(segfold),'.Solution=Solution;']);
 eval(['ARe',num2str(segfold),'.Performance=Performance;']);
 eval(['ARe',num2str(segfold),'.Trainfunc=Trainfunc;']);
 eval(['ARe',num2str(segfold),'.Conf_matrix=Conf_matrix;']);
 eval(['ARe',num2str(segfold),'.Perfectpoint=Perfectpoint;']);
% eval(['ARe',num2str(segfold),'.Perfectpoint2=Perfectpoint2;']);
 eval(['ARe',num2str(segfold),'.Timecost=Timein;']);
 eval(['ARe',num2str(segfold),'.Timecostcpu=Timeincpu;']); 
 eval(['ARe',num2str(segfold),'.iter_result=iter_result;']);
 eval(['ARe',num2str(segfold),'.runseed=randseed;']);
 %保存当前折变量ARe
 save (['TEMP',filename,'.',classifyname,'.','S',num2str(seed),'.','F',num2str(segfold),'.',num2str(year(now)),...
     '.',num2str(month(now)),'.',num2str(day(now)),'.',num2str(hour(now)),'.',num2str(minute(now)),'.mat'],['ARe',num2str(segfold)]);

end

%% summarize
ASum.Performance=zeros(segnum,4);
ASum.Num=zeros(segnum,1);
for i=0:segnum - 1
    
    eval(['ASum.Performance(i+1,:)=mean(ARe',num2str(i),'.Perfectpoint.Performance,1);']);
    eval(['ASum.Num(i+1)=mean(sum(ARe',num2str(i),'.Perfectpoint.Solution,2));']);
    eval(['ASum.maxQC(i+1)=mean(ARe',num2str(i),'.Perfectpoint.maxQC);']);
    eval(['ASum.meanQC(i+1)=mean(ARe',num2str(i),'.Perfectpoint.meanQC);']);
      
end
ASum.MPerformance=mean(ASum.Performance);
ASum.SPerformance=std(ASum.Performance);
ASum.MNum=mean(ASum.Num);
ASum.SNum=std(ASum.Num);
ASum.MmaxQC=mean(ASum.maxQC);
ASum.SmaxQC=std(ASum.maxQC);
ASum.MmeanQC=mean(ASum.meanQC);
ASum.SmeanQC=std(ASum.meanQC);
%%
Timeall=toc(Start);
Timeallcpu=cputime-Startcpu;
disp(['time in  all ',num2str(segnum),' folds is ',num2str(Timeall)]);
[~,hostname] = system('hostname');
hn = cellstr(hostname);
hn = hn{1};
if strcmp(hn,'DESKTOP-9SECPAC')
    hn = 'home';
else 
    hn = 'office';
end
save ([filename,'.',classifyname,'S',num2str(seed),'.',num2str(year(now)),...
    '.',num2str(month(now)),'.',num2str(day(now)),'.',num2str(hour(now)),'.',num2str(minute(now)),'.',discription,'.mat']);

path = dir(['TEMP*.mat']);
for i = 1: length(path)
   delete(path(i).name); 
end
