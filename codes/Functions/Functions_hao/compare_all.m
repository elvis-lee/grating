dif_index = [];
compare_result = [];


for t=1:1288
   accuracy_hao = AccuracyMEG1_hao(:,:,t);
   accuracy = AccuracyMEG1(:,:,t);
   equal_matrix = (accuracy_hao == accuracy);
   [row, col] = find(~equal_matrix);
   
   if ~isempty(row) 
       l = length(row);
       for k = 1:l
           dif_index = [dif_index;[row(k),col(k),t]]; %dif_index : n*3
           a1 = AccuracyMEG1(row(k),col(k),t);
           a1_hao = AccuracyMEG1_hao(row(k),col(k),t);
           indice = 0;
           for i = 1:(col(k)-1)
               for j = (i+1):24
                   indice = indice +1;
               end
           end
           indice = indice + (row(k) - col(k));
           decisionvalue1 = decision_values1_hao(col(k),indice,t);
           decisionvalue2 = decision_values1_hao(row(k),indice,t);
           compare_result = [compare_result; [a1,a1_hao,decisionvalue1,decisionvalue2]];
       end
   end
end
save('C:\Workspace\RSVP-master\Results\rsvp_11\mat\compare\compare', 'compare_result','AccuracyMEG1_hao','AccuracyMEG1','decision_values1_hao');
   
   