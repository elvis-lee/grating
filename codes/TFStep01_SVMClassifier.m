function TFStep01_SVMClassifier()

clear; clc;
addpath(genpath('Functions')); % add path of functions
addpath(genpath('/dataslow/haoli/libsvm-3.22'));

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
param.baselineTime =[-0.400 -0.001];
param.normalizemean = 1;
param.normalizestd = 1; 
param.equalobservations =0; 

parameters_classifer;
parameters_analysis;

condname = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18];

nconditions = size(condname,2); %improve later
ntrials = 119; %improve later
%% load data at once
disp('start loading data...');

condB = '';

for cond = 1:length(condname)
    
    [Data{condname(cond)}, Time] = load_trials(param.brainstorm_db,SubjectName,{num2str(condname(cond))},{condB}, param);
    disp(['loading condition' num2str(condname(cond)) 'done']);
end
param.Time =Time;
disp('loading data done!');


    

%% process 1: remove the mean trial (evoked response) from each condition (stimulus) separately
% 
% for i = 1:nconditions
%     trial_sum = 0;
%     for j = 1:ntrials
%         trial_sum =  trial_sum + Data{i}{j};
%     end
%     trial_avg = trial_sum / ntrials;
%     for j = 1:ntrials
%         Data_induced{i}{j} = Data{i}{j} - trial_avg;
%     end
%     disp(['process 1: condition ' num2str(i) ' done']);
% end


for F = [10:2:80]
    disp(['======Freq = ' num2str(F) 'is done!======' ]);
%% process 2: convert sensor time series to time frequency components
%convert: morlet alpha power
fc = 1; %central frequency, never change this
FWHM_tc = 3; %temporal resolution at central frequency
%F = 55; %frequencies in Hz

%test = morlet_transform(Data_induced{1}{1},Time,F,fc,FWHM_tc,'y');
parfor i = 1:nconditions
    for j = 1:ntrials %for all trials
         %temp = reshape(morlet_transform(Data_induced{i}{j},Time,F,fc,FWHM_tc,'y'),[306,1401]);
         temp = reshape(morlet_transform(Data{i}{j},Time,F,fc,FWHM_tc,'y'),[306,1401]);
         Data_freq{i}{j} = temp(:,201:1200);
    end
    disp(['process 2: condition ' num2str(i) ' done']);
end

%% process 3 : decode 
disp('process 3: start running svm...');
param.baselineTime =[-0.1 0];%change baseline range after cutting!
[Accuracy] = pairwise_classification_svm(Data_freq,param);
disp('process 3: svm done!');

%% save results
save(['/home/haoli/data/grating_data/01/result/result_freq=' num2str(F)],'Accuracy');

end