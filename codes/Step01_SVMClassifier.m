function Step01_SVMClassifier()

clear; clc;
addpath(genpath('Functions')); % add path of functions
addpath(genpath('/home/haoli/libsvm-3.22'));

%% parameters
iitt = 'ii';
ProjectName = 'grating';  
permutations = 'p100';  
clusterflag = '0'; 
i_subject = 1;
SubjectName = ['grating_' num2str(i_subject, '%.2d')];

param.trial_bin_size = 6;  % SVM parameter, group size
param.nperm = 100;
param.kfold = 10;
param.tgflag =0;
param.baselineTime =[-0.2 0];
param.normalizemean = 1;
param.normalizestd = 1; 
param.equalobservations =0; 

parameters_classifer;
parameters_analysis;

condname = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18];
%% load data at once
disp('start loading data...');

condB = '';

for cond = 1:length(condname)
    
    [Data{condname(cond)}, Time] = load_trials(param.brainstorm_db,SubjectName,{num2str(condname(cond))},{condB}, param);
    disp(['loading condition' num2str(condname(cond)) 'done']);
end
param.Time =Time;
disp('loading data done!');
%% run SVM
disp('start running svm');
if(strcmp(iitt,'ii'))
    [Accuracy] = pairwise_classification_svm(Data,param);
end

%% save results
save('/home/haoli/data/grating_data/01/result/result_01');