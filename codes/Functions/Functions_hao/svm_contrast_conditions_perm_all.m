function [Accuracy_MEG,Time,decision_values] = svm_contrast_conditions_perm_all(subject,param)
% function [Accuracy,Weight,param_out] = svm_contrast_conditions_perm(subject,conditionsA,conditionsB,param)
%
% Apply SVM classifier on MEG trials with supervised learning. Uses trial subaverages and permutations
%
% % Example:
%   clear; clc;
%   subject = 'rsvp_01';
%   conditionsA = {'Face_1'};
%   conditionsB = {'Non-face_1'};
%   param.brainstorm_db = '/dataslow/sheng/rsvp/brainstorm_db/rsvp/data';
%   param.data_type = 'MEG';
%   param.num_permutations = 100;
%   param.trial_bin_size = 25;
%   param.f_lowpass = 30;
%   param.iitt = 'ii';
%   param.trial_number = 300;
%
%   Author: Dimitrios Pantazis & Mingtong Fang & Sheng Qin

% initialize
num_permutations = param.num_permutations;
brainstorm_db = param.brainstorm_db;
trial_bin_size = param.trial_bin_size;
%% load data (force equal number of trials per condition) (single float)
% Please load data in ascending order of their labels(conditions)

if (param.speed == 1) 
    trial_raw=[];
    [trial_raw_temp,Time] = load_trials(brainstorm_db,subject,{'101'},{'102'},param);
    trial_raw = [trial_raw, trial_raw_temp];
    [trial_raw_temp,] = load_trials(brainstorm_db,subject,{'103'},{'104'},param);
    trial_raw = [trial_raw, trial_raw_temp];
    [trial_raw_temp,] = load_trials(brainstorm_db,subject,{'105'},{'106'},param);
    trial_raw = [trial_raw, trial_raw_temp];
    [trial_raw_temp,] = load_trials(brainstorm_db,subject,{'107'},{'108'},param);
    trial_raw = [trial_raw, trial_raw_temp];
    [trial_raw_temp,] = load_trials(brainstorm_db,subject,{'109'},{'110'},param);
    trial_raw = [trial_raw, trial_raw_temp];
    [trial_raw_temp,] = load_trials(brainstorm_db,subject,{'111'},{'112'},param);
    trial_raw = [trial_raw, trial_raw_temp];
    [trial_raw_temp,] = load_trials(brainstorm_db,subject,{'113'},{'114'},param);
    trial_raw = [trial_raw, trial_raw_temp];
    [trial_raw_temp,] = load_trials(brainstorm_db,subject,{'115'},{'116'},param);
    trial_raw = [trial_raw, trial_raw_temp];
    [trial_raw_temp,] = load_trials(brainstorm_db,subject,{'117'},{'118'},param);
    trial_raw = [trial_raw, trial_raw_temp];
    [trial_raw_temp,] = load_trials(brainstorm_db,subject,{'119'},{'120'},param);
    trial_raw = [trial_raw, trial_raw_temp];
    [trial_raw_temp,] = load_trials(brainstorm_db,subject,{'121'},{'122'},param);
    trial_raw = [trial_raw, trial_raw_temp];
    [trial_raw_temp,] = load_trials(brainstorm_db,subject,{'123'},{'124'},param);
    trial_raw = [trial_raw, trial_raw_temp];
else 
    trial_raw=[];
    [trial_raw_temp,Time] = load_trials(brainstorm_db,subject,{'201'},{'202'},param);
    trial_raw = [trial_raw, trial_raw_temp];
    [trial_raw_temp,] = load_trials(brainstorm_db,subject,{'203'},{'204'},param);
    trial_raw = [trial_raw, trial_raw_temp];
    [trial_raw_temp,] = load_trials(brainstorm_db,subject,{'205'},{'206'},param);
    trial_raw = [trial_raw, trial_raw_temp];
    [trial_raw_temp,] = load_trials(brainstorm_db,subject,{'207'},{'208'},param);
    trial_raw = [trial_raw, trial_raw_temp];
    [trial_raw_temp,] = load_trials(brainstorm_db,subject,{'209'},{'210'},param);
    trial_raw = [trial_raw, trial_raw_temp];
    [trial_raw_temp,] = load_trials(brainstorm_db,subject,{'211'},{'212'},param);
    trial_raw = [trial_raw, trial_raw_temp];
    [trial_raw_temp,] = load_trials(brainstorm_db,subject,{'213'},{'214'},param);
    trial_raw = [trial_raw, trial_raw_temp];
    [trial_raw_temp,] = load_trials(brainstorm_db,subject,{'215'},{'216'},param);
    trial_raw = [trial_raw, trial_raw_temp];
    [trial_raw_temp,] = load_trials(brainstorm_db,subject,{'217'},{'218'},param);
    trial_raw = [trial_raw, trial_raw_temp];
    [trial_raw_temp,] = load_trials(brainstorm_db,subject,{'219'},{'220'},param);
    trial_raw = [trial_raw, trial_raw_temp];
    [trial_raw_temp,] = load_trials(brainstorm_db,subject,{'221'},{'222'},param);
    trial_raw = [trial_raw, trial_raw_temp];
    [trial_raw_temp,] = load_trials(brainstorm_db,subject,{'223'},{'224'},param);
    trial_raw = [trial_raw, trial_raw_temp];
end

clear trial_raw_temp;

ntimes = size(trial_raw{1}{1},2);
ntrials = min([length(trial_raw{1}) length(trial_raw{2}) length(trial_raw{3}) length(trial_raw{4}) length(trial_raw{5}) length(trial_raw{6}) length(trial_raw{7}) length(trial_raw{8}) length(trial_raw{9}) length(trial_raw{10}) length(trial_raw{11}) length(trial_raw{12}) length(trial_raw{13}) length(trial_raw{14}) length(trial_raw{15}) length(trial_raw{16}) length(trial_raw{17}) length(trial_raw{18}) length(trial_raw{19}) length(trial_raw{20}) length(trial_raw{21}) length(trial_raw{22}) length(trial_raw{23}) length(trial_raw{24}) ]);
if ntrials < param.trial_number
    param.trial_number = ntrials;
end

%% correct for baseline std
baseline_range = Time < param.onset_time;
for i = 1:24 %for both groups
    for j = 1:ntrials
        trial_raw{i}{j} = trial_raw{i}{j} ./ repmat( std(trial_raw{i}{j}(:,baseline_range)')',1,ntimes );
    end
end
clear i j;

nchannels = size(trial_raw{1}{1}, 1);

%% get labels for train and test groups
nsamples = floor(ntrials/param.trial_bin_size);
param.trial_cluster_number = nsamples;
samples = reshape([1:nsamples*trial_bin_size],trial_bin_size,nsamples)';
train_label = [];
for i = 1:24
    train_label = [train_label i*ones(1,nsamples-1)];
end
test_label = [];
for i = 1:24
    test_label = [test_label i];
end
if strcmp(param.iitt,'ii') Accuracy_MEG_temp = zeros(24,24,ntimes); Accuracy_MEG = zeros(24,24,ntimes); end
%if strcmp(param.iitt,'iitt') AccuracyIITT_sum = zeros(ntimes,ntimes); end
rng('shuffle'); % seeds the random number generator based on the current time

%% initialize output
decision_values = zeros(24,276,ntimes);
model = [];

%%create index table
index_table = rand(276,2);
k = 0;
for i = 1:23
    for j = (i+1):24
        k = k+1;
        index_table(k, :) = [i j];
    end
end
%% perform decoding
for p = 1:num_permutations
    
  
    
    %randomize samples
    perm_ndxA = randperm(nsamples*trial_bin_size);
    perm_ndxB = randperm(nsamples*trial_bin_size);
    perm_samplesA = perm_ndxA(samples);
    perm_samplesB = perm_ndxB(samples);
    
    %create train samples: 6_train_number * 306_sensors * 1901_Time
    train_trials = [];
    for i = 1:24
        %train_trialsA = average_structure2(trial_raw{i}(perm_samplesA(1:nsamples-1,:)));
        train_trialsA = average_structure2(trial_raw{i}(samples(1:nsamples-1,:))); %to be removed just for testing
        train_trials = [train_trials;train_trialsA];
    end
    
    %create test samples
    test_trials = [];
    for i = 1:24
        %test_trialsA = double(average_structure(trial_raw{i}(perm_samplesA(end,:))));
        test_trialsA = double(average_structure(trial_raw{i}(samples(end,:)))); %to be removed just for testing
        test_trials = [test_trials test_trialsA];
    end    
    test_trials = reshape(test_trials,[nchannels,ntimes,24]);
    test_trials = permute(test_trials,[3 1 2]);
         
    if (p == 1) param.SVM_vector_length = size(train_trials,2); end
    for tndx_train = 1:ntimes
       

            % libsvm-3.18
            model_temp = svmtrain(train_label',train_trials(:,:,tndx_train),'-s 0 -t 0 -q');
            [predicted_label, Accuracy_tmp, decision_values_temp] = svmpredict(test_label', test_trials(:,:,tndx_train), model_temp);
            model = [model model_temp];
            decision_values(:,:,tndx_train) = decision_values_temp;
            %AccuracyMEG_sum(tndx_train) = AccuracyMEG_sum(tndx_train) + Accuracy_tmp(1);
            %calculate Accuracy_MEG_temp
    end
    
    for time = 1:ntimes
        for col = 1:276
            num_correct = 0;
            index = index_table(col,:);
            if decision_values(index(1),col,time)>0
                num_correct = num_correct +100;
            end
            if decision_values(index(2),col,time)<0
                num_correct = num_correct +100;
            end
            %Accuracy_MEG_temp(index(1),index(2),time) = num_correct/2;
            Accuracy_MEG_temp(index(2),index(1),time) = num_correct/2;
        end
    end
    
    Accuracy_MEG = Accuracy_MEG + Accuracy_MEG_temp;
            
end

Accuracy_MEG = Accuracy_MEG / num_permutations;
param_out = param;
