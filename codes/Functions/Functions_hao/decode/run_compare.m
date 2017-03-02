clear

num_condition = 24;
num_trail_per_condition = 5;
testing_label_vector = [];
training_label_vector = [];


for m = 1:num_condition
    testing_label_vector = [testing_label_vector; m];
    for n = 1:num_trail_per_condition
        training_label_vector = [training_label_vector; m];
    end
end
clear m n;

testing_instance_matrix = rand(num_condition,306,1000);
training_instance_matrix = rand(num_condition*num_trail_per_condition,306,1000);





%%decode_all
tic
accuracy_matrix_all = decode_all(num_condition,training_label_vector, training_instance_matrix,testing_label_vector, testing_instance_matrix);
toc

%%decode_pairwise
tic
accuracy_matrix_pairwise = decode_pairwise(num_condition,training_label_vector, training_instance_matrix,testing_label_vector, testing_instance_matrix);
toc

isequal(accuracy_matrix_all,accuracy_matrix_pairwise)
