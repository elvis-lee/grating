function [accuracy_matrix] = decode_pairwise(num_condition,training_label_vector, training_instance_matrix,testing_label_vector, testing_instance_matrix)
%author: Hao Li 
%please arrange instances in ascending order of their label number![important] 

%%load length
ntimes =  size(training_instance_matrix,3);
num_training_trail = size(training_label_vector,1);
num_trail_each_condition = num_training_trail / num_condition;

%% initialization
accuracy_matrix = zeros(num_condition,num_condition,ntimes);

for t = 1:ntimes 
    for m = 1:(num_condition - 1)
        for n = (m+1):num_condition
            training_label = [training_label_vector((m-1)*num_trail_each_condition+1:m*num_trail_each_condition);training_label_vector((n-1)*num_trail_each_condition+1:n*num_trail_each_condition)];
            training_instance = [training_instance_matrix((m-1)*num_trail_each_condition+1:m*num_trail_each_condition,:,t);training_instance_matrix((n-1)*num_trail_each_condition+1:n*num_trail_each_condition,:,t)];
            testing_label = [testing_label_vector(m);testing_label_vector(n)];
            testing_instance = [testing_instance_matrix(m,:,t);testing_instance_matrix(n,:,t)];
            model_temp = svmtrain(training_label,training_instance,'-s 0 -t 0 -q');
            [predicted_label, accuracy_temp, decision_values_temp] = svmpredict(testing_label,testing_instance, model_temp,'-q');
            accuracy_matrix(n,m,t) = accuracy_temp(1);
        end
    end
end

