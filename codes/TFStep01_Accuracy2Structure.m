%function TFStep02_Accuracy2Structure()

clear; clc;
TimeFreq_Map1 = zeros(36,1700);
% TimeFreq_Map2 = zeros(6,1000);
% TimeFreq_Map3 = zeros(6,1000);
% TimeFreq_Map4 = zeros(6,1000);
% TimeFreq_Map5 = zeros(6,1000);
%% parameters
ProjectName = 'sheng';  % 'grating03 to grating 16'
condNum = 6;
i_subject = 8;
file_location = ['/dataslow/haoli/workspace/project_grating/results/' ProjectName '_' num2str(i_subject, '%.2d') '/Fig1_Accuracy/mat/'];
addpath(genpath('Functions')); % add path of functions

for F = [10:2:80]
%% load result_01
load([file_location '/Accuracy_freq=' num2str(F)], 'Accuracy');
time_length = size(Accuracy,2);

%% average all data at one time point
Accuracy1 = sum(Accuracy)/(condNum*(condNum-1)/2);
% figure();
% plot(Accuracy1(1,:));
TimeFreq_Map1(F/2-4,:) = Accuracy1(1,:);
% %% average within data at one time point
% Accuracy_unwrapped = fl_unwrap_conditions(Accuracy);
% 
% Accuracy_group1 = Accuracy_unwrapped(1:condNum/3, 1:condNum/3, :);
% Accuracy_group2 = Accuracy_unwrapped(condNum/3+1:12, condNum/3+1:12, :);
% Accuracy_group3 = Accuracy_unwrapped(condNum*2/3+1:condNum, condNum*2/3+1:condNum, :);
% 
% Accuracy_group1_average = sum(reshape(Accuracy_group1,(condNum/3)^2,time_length))/((condNum/3)*((condNum/3)-1));
% %figure();
% %plot(Accuracy_group1_average(1,:));
% TimeFreq_Map2(F/2-4,:) = Accuracy_group1_average(1,:);
% 
% Accuracy_group2_average = sum(reshape(Accuracy_group2,(condNum/3)^2,time_length))/((condNum/3)*((condNum/3)-1));
% %figure();
% %plot(Accuracy_group2_average(1,:));
% TimeFreq_Map3(F/2-4,:) = Accuracy_group2_average(1,:);
% 
% Accuracy_group3_average = sum(reshape(Accuracy_group3,(condNum/3)^2,time_length))/((condNum/3)*((condNum/3)-1));
% %figure();
% %plot(Accuracy_group3_average(1,:));
% TimeFreq_Map4(F/2-4,:) = Accuracy_group3_average(1,:);
% 
% Accuracy_group3_average_strong = zeros(1,time_length);
% for t = 1:time_length
%     asum = 0;
%     for m = 1:(condNum/3)
%         for n = 1:(condNum/3)
%             if (( m ==2 )&&( n == 1 ))||(( m == 4 )&&( n == 3 ))||(( m == 6 )&&( n == 5 ));
%                 asum = asum + Accuracy_group3(m,n,t);
%             end
%         end
%     end
%     Accuracy_group3_average_strong(1,t) = asum/3;
% end
% 
% %figure();
% %plot(Accuracy_group3_average_strong(1,:));
% TimeFreq_Map5(F/2-4,:) = Accuracy_group3_average_strong(1,:);
end

figure(1);imagesc(TimeFreq_Map1);set(gca,'YDir','normal');set(gca,'ytick',1:36,'yticklabel',[10:2:80]);colorbar;colormap jet;caxis([50 80]);
hold on; plot([200 200],[0 37],'r','Linewidth',3);
hold on; plot([1000 1000],[0 37],'r','Linewidth',3);
% figure(2);imagesc(TimeFreq_Map2);set(gca,'ytick',1:36,'yticklabel',[10:2:80]);colorbar;
% figure(3);imagesc(TimeFreq_Map3);set(gca,'ytick',1:36,'yticklabel',[10:2:80]);colorbar;
% figure(4);imagesc(TimeFreq_Map4);set(gca,'ytick',1:36,'yticklabel',[10:2:80]);colorbar;
% figure(5);imagesc(TimeFreq_Map5);set(gca,'ytick',1:36,'yticklabel',[10:2:80]);colorbar;
