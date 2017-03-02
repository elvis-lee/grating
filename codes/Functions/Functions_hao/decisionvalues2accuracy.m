load('C:\Workspace\RSVP-master\Results\rsvp_11\mat\Data\Data_1')
index_table = rand(276,2);
k = 0;
for i = 1:23
    for j = (i+1):24
        k = k+1;
        index_table(k, :) = [i j];
    end
end

Accuracy_MEG = rand(24,24,1288);
for time = 1:1288
    for col = 1:276
        num_correct = 0;
        index = index_table(col,:);
        if decision_values(index(1),col,time)>0
            num_correct = num_correct +1;
        end
        if decision_values(index(2),col,time)<0
            num_correct = num_correct +1;
        end
        Accuracy_MEG(index(1),index(2),time) = num_correct/2;
        Accuracy_MEG(index(2),index(1),time) = num_correct/2;
    end
end

save ('C:\Workspace\RSVP-master\Results\rsvp_11\mat\Data\Accuracy_1','Accuracy_MEG')
        
