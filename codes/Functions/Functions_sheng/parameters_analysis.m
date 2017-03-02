% parameters_analysis;

if clusterflag
    param.brainstorm_db = ['/om/user/shengqin' ProjectName '/brainstorm_db/data'];
else
    param.brainstorm_db = ['/dataslow/haoli/brainstorm_db/' ProjectName '/data'];
end

param.data_type = 'MEG';
param.ProjectName = ProjectName;
param.f_lowpass = 30;
param.latency = 0.026; % video latency 
param.trial_number = 9999; % initializa a number and then will be changed.
param.baseline = 0.400; % the length of the baseline.
param.inter = 0.800; % the decision time, or the interstimulus time.