function [Accuracy] = pairwise_classification_svm(data,param)

%temporary code, undocumented; do not distribute
%input must be data{condition}{trial} = [channels x time];

% Author: Dimitrios Pantazis 

%add features?
%leave one out
%train single- test average
%normalize per attributes
%class decoding?
%unequal trials decoding trick

%parse inputs
nperm = param.nperm;
kfold = param.kfold;
Time = param.Time; 
tgflag = param.tgflag; %temporal generalization, 0: regular, 1:Time-Time
baselineTime = param.baselineTime; %e.g. [-0.3 0]
normalizemean = param.normalizemean; %flag 0 or 1
normalizestd = param.normalizestd; %flag 0 or 1
equalobservations = param.equalobservations; %flag 0 or 1
%Time = -0.3:0.001:1.6;

%initialize variables
ncond = length(data);
[nvar ntimes] = size(data{1}{1});
nobs = cellfun(@length,data); %number of observations
bin = floor(nobs/(kfold)); %bin size for each fold
if equalobservations %if request equal observations per condition
    bin(:) = min(bin);
end


%check if libsvm software exists and preceeds in path
try 
    svmtrain([0 1],[0 1],'-s 0 -t 0 -q'); %this should not produce errors in libsvm is installed
catch
    disp(['This function uses the LIBSVM software. It calls the svmtrain function',char(10),...
        'which has the same name as the Matlab''s builtin function. To use, adjust the',char(10),...
        'Matlab path so that SIBSVM''s svmtrain precede the one from Matlab']);
    return;
end

%remove baseline mean
tndx = find( Time>baselineTime(1) & Time<baselineTime(2));
if normalizemean 
    for c = 1:ncond
        for i = 1:nobs(c)
            m = mean(data{c}{i}(:,tndx),2);
            data{c}{i} = bsxfun(@minus,data{c}{i},m);
        end
    end
end

%divide by baseline s.d.
if normalizestd
    for c = 1:ncond
        for i = 1:nobs(c)
            sd = std(data{c}{i}(:,tndx),[],2);
            data{c}{i} = bsxfun(@rdivide,data{c}{i},sd);
        end
    end
end

%define labels for pattern vectors
trainlabel = ones(kfold-1,1)*(1:ncond);
trainlabel = trainlabel(:);
testlabel = (1:ncond)';
if tgflag == 1 %for temporal generalization
    testlabel = repmat(testlabel,ntimes,1); %repeat labels for all times
end

%indices for 'decision_values' (output matrix from svmpredict)
%hack: perform pairwise comparisons using a direct multiclass call
decval_ndx = zeros(ncond,ncond*(ncond-1)/2,'single');
for c = ncond-1:-1:1
    rows = ncond-c:ncond;
    cols = sum(c+1:ncond-1)+1:sum(c+1:ncond-1)+c;
    decval_ndx(rows,cols) = [ones(1,c);-eye(c)];
end
if tgflag == 0
decval_plus = find(decval_ndx>0);
decval_minus = find(decval_ndx<0);
else
    decval_ndx = repmat(decval_ndx,ntimes,1);
    [I,J] = find(decval_ndx>0);
    I = reshape(I,ntimes,ncond*(ncond-1)/2)';
    J = reshape(J,ntimes,ncond*(ncond-1)/2)';
    decval_plus = sub2ind(size(decval_ndx),I(:),J(:));
    [I,J] = find(decval_ndx<0);
    I = reshape(I,ntimes,ncond*(ncond-1)/2)';
    J = reshape(J,ntimes,ncond*(ncond-1)/2)';
    decval_minus = sub2ind(size(decval_ndx),I(:),J(:));
end




%initialize decoding accuracy matrices
if tgflag == 0
    Accuracy = zeros(ncond*(ncond-1)/2,ntimes,'single');
    accuracy = zeros(ncond*(ncond-1)/2,ntimes,'single');
else
    Accuracy = zeros(ncond*(ncond-1)/2*ntimes,ntimes,'single');
    accuracy = zeros(ncond*(ncond-1)/2*ntimes,ntimes,'single');
end    

%perform pairwise decoding
for p = 1:nperm
    if ~rem(p,1)
        disp(['Permutation: ' num2str(p) ' out of ' num2str(nperm)]);
    end
    
    %perform subavaraging within each fold
    for c = 1:ncond %for all conditions
        permndx = randperm(nobs(c)); %randomize index
        trainndx = reshape(permndx(1:(kfold-1)*bin(c)),kfold-1,bin(c)); %index for train trials
        testndx = permndx((kfold-1)*bin(c)+1:kfold*bin(c)); %index for test trials
        for k = 1:kfold-1
            traincell{c}{k} = fl_cell_mean(data{c}(trainndx(k,:))); %subaverage train trials
        end
        testcell{c} = fl_cell_mean(data{c}(testndx)); %subaverage test trials
    end
    traindata = cat(1,traincell{:})'; %rearrange train trials
    traindata = fl_cell2mat(traindata(:)); %concatenate cells into a matrix
    testdata = fl_cell2mat(testcell);
    
    %if single time decoding
    if tgflag == 0
        parfor t = 1:ntimes
            model = svmtrain(trainlabel,double(traindata(:,:,t)),'-s 0 -t 0 -q');
            [~, ~, decision_values] = svmpredict(testlabel, double(testdata(:,:,t)), model,'-q');
            accuracy(:,t) = single(decision_values(decval_plus)>0) + single(decision_values(decval_minus)<0);
        end
    end
    
    %if temporal generalization
    if tgflag == 1 %if temporal generalization
        testdata = permute(testdata,[1 3 2]);
        testdata = double(reshape(testdata,[ncond*ntimes nvar]));
        parfor t = 1:ntimes
            model = svmtrain(trainlabel,double(traindata(:,:,t)),'-s 0 -t 0 -q');
            [~, ~, decision_values] = svmpredict(testlabel, testdata, model,'-q');
            accuracy(:,t) = single(decision_values(decval_plus)>0) + single(decision_values(decval_minus)<0);
        end
    end
    
    %accumulate permutation results
    Accuracy = Accuracy + accuracy; % condition*(condition-1)/2, time, time

end


Accuracy = Accuracy*100/2 / nperm; %normalize to 0-100%

if tgflag
    Accuracy = reshape(Accuracy,ncond*(ncond-1)/2,ntimes,ntimes);
end








