clear; clc;

%% parameters
ProjectName = 'grating';  % 'grating03 to grating 16'
condNum = 18;
i_subject = 1;
file_location = ['/dataslow/haoli/workspace/project_grating/results/' ProjectName '_' num2str(i_subject, '%.2d') '/Fig1_Accuracy/mat/'];
addpath(genpath('Functions')); % add path of functions
frequency_range = 10:2:80;
disp_prob_range = [50 70];
row_index = 0;
save_fig_location = ['/dataslow/haoli/workspace/project_grating/results/' ProjectName '_' num2str(i_subject, '%.2d') '/Fig1_Accuracy/fig/'];
save_map_location = ['/dataslow/haoli/workspace/project_grating/results/' ProjectName '_' num2str(i_subject, '%.2d') '/Fig1_Accuracy/mat/map/'];
onset_time = 200;
end_time = 700;


for F = frequency_range
    row_index = row_index + 1;
    %% load result_01
    load([file_location '/Induced_Accuracy_freq=' num2str(F)], 'Accuracy');
    time_length = size(Accuracy,2);
    
    %% average all data at one time point
    Accuracy1 = sum(Accuracy)/(condNum*(condNum-1)/2);
    % figure();
    % plot(Accuracy1(1,:));
    TimeFreq_Map1(row_index,:) = Accuracy1(1,:);
    
    %% average within data at one time point
    Accuracy_unwrapped = fl_unwrap_conditions(Accuracy);
    
    Accuracy_group1 = Accuracy_unwrapped(1:condNum/3, 1:condNum/3, :);
    Accuracy_group2 = Accuracy_unwrapped(condNum/3+1:condNum*2/3, condNum/3+1:condNum*2/3,:);
    Accuracy_group3 = Accuracy_unwrapped(condNum*2/3+1:condNum, condNum*2/3+1:condNum, :);
    
    Accuracy_group1_average = sum(reshape(Accuracy_group1,(condNum/3)^2,time_length))/((condNum/3)*((condNum/3)-1));
    %figure();
    %plot(Accuracy_group1_average(1,:));
    TimeFreq_Map2(row_index,:) = Accuracy_group1_average(1,:);
    
    Accuracy_group2_average = sum(reshape(Accuracy_group2,(condNum/3)^2,time_length))/((condNum/3)*((condNum/3)-1));
    %figure();
    %plot(Accuracy_group2_average(1,:));
    TimeFreq_Map3(row_index,:) = Accuracy_group2_average(1,:);
    
    Accuracy_group3_average = sum(reshape(Accuracy_group3,(condNum/3)^2,time_length))/((condNum/3)*((condNum/3)-1));
    %figure();
    %plot(Accuracy_group3_average(1,:));
    TimeFreq_Map4(row_index,:) = Accuracy_group3_average(1,:);
    
    Accuracy_group3_average_strong = zeros(1,time_length);
    for t = 1:time_length
        asum = 0;
        for m = 1:(condNum/3)
            for n = 1:(condNum/3)
                if (( m ==2 )&&( n == 1 ))||(( m == 4 )&&( n == 3 ))||(( m == 6 )&&( n == 5 ));
                    asum = asum + Accuracy_group3(m,n,t);
                end
            end
        end
        Accuracy_group3_average_strong(1,t) = asum/3;
    end
    
    %figure();
    %plot(Accuracy_group3_average_strong(1,:));
    TimeFreq_Map5(row_index,:) = Accuracy_group3_average_strong(1,:);
end

%% show figures
figure(1);imagesc(TimeFreq_Map1);set(gca,'YDir','normal');set(gca,'ytick',1:length(frequency_range),'yticklabel',frequency_range);colorbar;colormap jet;caxis(disp_prob_range);title('Induced Response-All Groups');
hold on; plot([onset_time onset_time],[0 length(frequency_range)+1],'r','Linewidth',3);
hold on; plot([end_time end_time],[0 length(frequency_range)+1],'r','Linewidth',3);
figure(2);imagesc(TimeFreq_Map2);set(gca,'YDir','normal');set(gca,'ytick',1:length(frequency_range),'yticklabel',frequency_range);colorbar;colormap jet;caxis(disp_prob_range);title('Induced Response-Group 1(B/W)');
hold on; plot([onset_time onset_time],[0 length(frequency_range)+1],'r','Linewidth',3);
hold on; plot([end_time end_time],[0 length(frequency_range)+1],'r','Linewidth',3);
figure(3);imagesc(TimeFreq_Map3);set(gca,'YDir','normal');set(gca,'ytick',1:length(frequency_range),'yticklabel',frequency_range);colorbar;colormap jet;caxis(disp_prob_range);title('Induced Response-Group 2(R/G)');
hold on; plot([onset_time onset_time],[0 length(frequency_range)+1],'r','Linewidth',3);
hold on; plot([end_time end_time],[0 length(frequency_range)+1],'r','Linewidth',3);
figure(4);imagesc(TimeFreq_Map4);set(gca,'YDir','normal');set(gca,'ytick',1:length(frequency_range),'yticklabel',frequency_range);colorbar;colormap jet;caxis(disp_prob_range);title('Induced Response-Group 3(Swapped)-All');
hold on; plot([onset_time onset_time],[0 length(frequency_range)+1],'r','Linewidth',3);
hold on; plot([end_time end_time],[0 length(frequency_range)+1],'r','Linewidth',3);
figure(5);imagesc(TimeFreq_Map5);set(gca,'YDir','normal');set(gca,'ytick',1:length(frequency_range),'yticklabel',frequency_range);colorbar;colormap jet;caxis(disp_prob_range);title('Induced Response-Group 3(Swapped)-Strong');
hold on; plot([onset_time onset_time],[0 length(frequency_range)+1],'r','Linewidth',3);
hold on; plot([end_time end_time],[0 length(frequency_range)+1],'r','Linewidth',3);

%% save figures
saveas(1,[save_fig_location 'induced_response_all_groups.bmp']);
saveas(2,[save_fig_location 'induced_response_group_1_bw.bmp']);
saveas(3,[save_fig_location 'induced_response_group_2_gr.bmp']);
saveas(4,[save_fig_location 'induced_response_group_3_all.bmp']);
saveas(5,[save_fig_location 'induced_response_group_3_strong.bmp']);

%% save mat data
save([save_map_location 'induced_time_freq_decoding_map'],'TimeFreq_Map1','TimeFreq_Map2','TimeFreq_Map3','TimeFreq_Map4','TimeFreq_Map5');