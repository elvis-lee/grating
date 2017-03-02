function [accuracy_matrix] = decode_all(num_condition,training_label_vector, training_instance_matrix,testing_label_vector, testing_instance_matrix)
%author: Hao Li 
%please arrange instances in ascending order of their label number![important] 

%%load time length
ntimes =  size(training_instance_matrix,3);

%% initialization
num_sensors = size(testing_instance_matrix,2);
num_classifier = num_condition*(num_condition-1)/2;
decision_values = zeros(num_condition,num_classifier,ntimes);
accuracy_matrix = zeros(num_condition,num_condition,ntimes);
%model = [];


%%train & predict
for time = 1:ntimes
    model_temp = svmtrain(training_label_vector,training_instance_matrix(:,:,time),'-s 0 -t 0 -q');
    [~, ~, decision_values_temp] = svmpredict(testing_label_vector,testing_instance_matrix(:,:,time), model_temp,'-q');
    decision_values(:,:,time) = decision_values_temp;
    %model = [model; model_temp];
end

clear model_temp;


%%create index table
index_table = zeros(num_classifier,2);
k = 0;
for i = 1:(num_condition-1)
    for j = (i+1):num_condition
        k = k+1;
        index_table(k, :) = [i j];
    end
end

clear i;
clear j;
clear k;


%%transfer decision values to decoding matrix
for time = 1:ntimes
        for col = 1:num_classifier
            num_correct = 0;
            index = index_table(col,:);
            if decision_values(index(1),col,time)>0
                num_correct = num_correct +100;
            end
            if decision_values(index(2),col,time)<0
                num_correct = num_correct +100;
            end
            accuracy_matrix(index(2),index(1),time) = num_correct/2;
        end
end






