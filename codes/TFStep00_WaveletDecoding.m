%function TFStep00_TFtransfer()

clear; clc;
addpath(genpath('Functions')); % add path of functions
addpath(genpath('/dataslow/haoli/libsvm-3.22'));
results_location = ['../results/sheng_08'];%change


%% step 0: set parameters
ProjectName = 'sheng';  %change
i_subject = 8; %change
SubjectName = ['grating' num2str(i_subject, '%.2d')];%change
Freq_range = 10:2:80;
%HZ = [num2str(min(F)) '-' num2str(max(F))  'Hz'];
%filename_tf = ['Timefreq_induced_' SubjectName '_' HZ ];%change
condname = [1 2 3 4 5 6];%change

param.data_type = 'MEG';
param.ProjectName = ProjectName;
param.f_lowpass = 200;
%param.latency = 0.026; % video latency 
%param.trial_number = 9999; % initializa a number and then will be changed.
%param.baseline = 0.4; % the length of the baseline.
%param.inter = 0.8; % the decision time, or the interstimulus time.
param.brainstorm_db = ['/dataslow/sheng/Project of Sheng/brainstorm_db/' ProjectName '/data'];

% cluster parameters
%iitt = 'ii';
%permutations = 'p100';  
%clusterflag = '0'; 
%param.trial_bin_size = 6;  % SVM parameter, group size
param.nperm = 100;
param.kfold = 10;
param.tgflag =0;
param.normalizemean = 1;
param.normalizestd = 1; 
param.equalobservations =0;
%clusterflag = str2num(clusterflag);
%param.num_permutations = str2num(permutations([2:end]));
%param.iitt = iitt;
%param.clusterflag = clusterflag;
%param.trial_number = 9999; % this number will be changed when loading trials

disp('step 0: parameters set.');

%% step 1: load data at once
disp('step 1: start loading data...');

condB = '';

for cond = 1:length(condname)
    [Data{condname(cond)}, Time] = load_trials(param.brainstorm_db,SubjectName,{num2str(condname(cond))},{condB}, param);
    disp(['loading condition ' num2str(condname(cond)) 'done']);
end
param.Time =Time;

%find the mininum n_trials for all conditions
n_trials = length(Data{condname(1)});
for cond = 2:length(condname)
    n_trials_temp = length(Data{condname(cond)});
    if n_trials > n_trials_temp
        n_trials = n_trials_temp;
    end
end

disp('step 1: loading data done.');

%% step 2: baseline standard deviation correction
disp('step 2: start baseline standard deviation correction...');

baseline_range = Time<0;
for cond = 1:length(condname)
    for i_trial = 1:n_trials
        Data{cond}{i_trial} =  Data{cond}{i_trial} ./ repmat( std( Data{cond}{i_trial}(:,baseline_range)')',1,size(Time,2) );
    end
end

disp('baseline standard deviation correction done.');

%% step 3: compute induced response
disp('step 3: computing induced response...');

%initialize Data_induced
Data_induced = cell(size(Data));
for cond = 1:length(condname)
    Data_induced{cond} = cell(1,n_trials);
    for i_trial = 1:n_trials
        Data_induced{cond}{i_trial} = zeros(size(Data{1}{1}));
    end 
end

for cond = 1:length(condname)
    %compute evoked response
    evoked_sum = zeros(size(Data{cond}{1}));
    for i_trial = 1:n_trials
        evoked_sum = evoked_sum + Data{cond}{i_trial};
    end
    trial_avg = evoked_sum / n_trials;
    %compute induced response
    for i_trial = 1:n_trials
        Data_induced{cond}{i_trial} = Data{cond}{i_trial} - trial_avg;
    end
end

clear Data; %save memory!
disp('induced response computation done.');

for F = Freq_range
%% step 4: wavelet transformation
disp('step 4: start time-frequency transformation...');

fc = 1;
FWHM_tc = 3;

%initialize Timefreq_induced
% Timefreq_induced = cell(1,length(condname));
% for cond = 1:length(condname)
%     Timefreq_induced{cond} = cell(1,n_trials);
%     for i_trial = 1:n_trials
%         Timefreq_induced{cond}{i_trial} = zeros(size(Data{1}{1}));
%     end
% end

for cond = 1:length(condname) %change to parfor later
    for i_trial = 1:n_trials
        temp = squeeze(morlet_transform(Data_induced{cond}{i_trial},Time,F,fc,FWHM_tc,'y'));
        Timefreq_induced{cond}{i_trial} = temp(:,101:1800);
        disp(['condition ' num2str(cond) ' trial ' num2str(i_trial) ' done']);
    end
    disp(['time-frequency transforamtion condition ' num2str(cond) 'done']);
end
disp('time-frequency transformation done.');

%% step 5: SVM decoding
display('step 5: SVM decoding...');

param.baselineTime =[-0.200 -0.001];%change baseline range after cutting!
[Accuracy] = pairwise_classification_svm(Timefreq_induced,param);

display('step 5: SVM decoding done.');
%% step 6: save results
display('step 6: saving Timefreq data');
%save( [results_location '/Fig0_Timefreq/mat/Timefreq_freq=' num2str(F)],'Timefreq_induced','Time','param');
save( [results_location '/Fig1_Accuracy/mat/Accuracy_freq=' num2str(F)],'Accuracy');

disp(['======Freq = ' num2str(F) ' is done!======' ]);
end