clear

num_condition = 24;
num_trail_per_condition = 5;
training_label_vector = [];


for m = 1:num_condition
    for n = 1:num_trail_per_condition
        training_label_vector = [training_label_vector; m];
    end
end
clear m n;

training_instance_matrix = rand(num_condition*num_trail_per_condition,306,1000);

tic
for k = 1:1000
    model = svmtrain(training_label_vector,training_instance_matrix(:,:,k),'-s 0 -t 0 -q');
end
toc

tic   
model = svmtrain(training_label_vector,training_instance_matrix(:,:,k),'-s 0 -t 0 -q');
toc