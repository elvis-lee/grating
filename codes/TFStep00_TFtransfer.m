function TFStep00_TFtransfer()

clear; clc;
addpath(genpath('Functions')); % add path of functions
addpath(genpath('/dataslow/haoli/libsvm-3.22'));
results_location = ['../results/Fig0_Timefreq'];


%% step 0: set parameters
ProjectName = 'grating';  
i_subject = 1;
SubjectName = ['grating_' num2str(i_subject, '%.2d')];
F = 1:1:100;
HZ = [num2str(min(F)) '-' num2str(max(F))  'Hz'];
filename_tf = ['Timefreq_' SubjectName '_' HZ ];
condname = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18];

param.data_type = 'MEG';
param.ProjectName = ProjectName;
param.f_lowpass = 30;
param.latency = 0.026; % video latency 
param.trial_number = 9999; % initializa a number and then will be changed.
param.baseline = 0.4; % the length of the baseline.
param.inter = 0.8; % the decision time, or the interstimulus time.
param.brainstorm_db = ['/dataslow/haoli/brainstorm_db/' ProjectName '/data'];

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

%% step 3: wavelet transformation
disp('step 3: start time-frequency transformation...');

fc = 1;
FWHM_tc = 3;

for cond = 1:length(condname)
    %compute evoked response
    evoked_sum = zeros(size(Data{cond}{1}));
    for i_trial = 1:n_trials
        evoked_sum = evoked_sum + Data{cond}{i_trial};
    end
    trial_avg = evoked_sum / n_trials;
    %remove mean before morlet transformation
    trial_avg = trial_avg - repmat( mean(trial_avg,2), 1, size(trial_avg,2));
    %compute morlet transformation
    Timefreq.evoked{cond} = morlet_transform(trial_avg,Time,F,fc,FWHM_tc,'y');
       
end
disp('time-frequency transformation done.');


%% step 4: save results
display('step 4: saving Timefreq data');
save( [results_location '/mat/' filename_tf ],'Timefreq','Time','param');