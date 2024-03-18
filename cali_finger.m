clear; close all; clc;

% 加载背景数据
load('Background_I.mat');
load('Background_Q.mat');
IB = zeros(542, 512);
QB = zeros(542, 512);

for i = 1:199
    IB = IB + eval(['I_', num2str(i)]);
    QB = QB + eval(['Q_', num2str(i)]);
end
IB = IB / 199;
QB = QB / 199;

save('averaged_background.mat', 'IB', 'QB');


load('640-2_I.mat');
load('640-2_Q.mat');


Is = zeros(542, 512);
Qs = zeros(542, 512);
A = zeros(542, 512, 199);

for i = 1:199
    I = eval(['I_', num2str(i)]) - IB;
    Q = eval(['Q_', num2str(i)]) - QB;
    A(:, :, i) = sqrt(I.^2 + Q.^2);
    Is = Is + eval(['I_', num2str(i)]);
    Qs = Qs + eval(['Q_', num2str(i)]);
end

save('640-3.mat', 'A');

Is = Is / 199 - IB;
Qs = Qs / 199 - QB;

Stand = sqrt(Is.^2 + Qs.^2);



St = Stand;


figure;
heatmap(St);
grid off
clim([0, 100])
title('Standard');
xlabel('xpixel');
ylabel('ypixel');
colormap('jet');
colorbar;

%% 


Region1 = zeros(199);
Region2 = zeros(199);
Region3 = zeros(199);
Region4 = zeros(199);
Background = zeros(199);


for i = 1:199
    
    Background(i) = sum(sum(A(1:21, 1:21, i)));
    Region1(i) = sum(sum(A(370:390, 270:290, i)));
    Region2(i) = sum(sum(A(370:390, 290:310, i)));
    Region3(i) = sum(sum(A(310:330, 260:280, i)));
    Region4(i) = sum(sum(A(370:390, 300:320, i)));
end

A1 = Region1;
A2 = Region2;
A3 = Region3;
A4 = Region4;



% 定义要处理的区域

regions = {A1, A2, A3, A4, Background};

% 选择小波基函数
wavelet = 'sym8';

% 定义要保留的尺度
kept_levels = 5;

window_length = 20;

figure;
for i = 1:length(regions)
    % 选择数据
    data = regions{i}(1:199);
    
    % 进行小波变换
    [c, l] = wavedec(data, 5, wavelet); % 这里选择了进行五层小波分解

    % 去除高频信号
    c(l(1)+sum(l(2:end-kept_levels))+1:end) = 0;

    % 重构信号
    data_filt = waverec(c, l, wavelet);

    baseline_removed = data_filt - movmean(data_filt, window_length);
    filename = ['baseline2', num2str(i), '.mat']; % Constructing the file name dynamically
    save(filename, 'baseline_removed');
    % 显示结果
    subplot(length(regions), 3, 3*i-2);
    plot(data);
    title(['640-3', num2str(i)]);
    subplot(length(regions), 3, 3*i-1);
    plot(data_filt);
    title(['Filtered Data ', num2str(i)]);
    subplot(length(regions), 3, 3*i);
    plot(baseline_removed);
    title(['Baseline Removed Data ', num2str(i)]);
end



