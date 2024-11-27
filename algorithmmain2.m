%% 清空环境
clc;
clear;

%% 数据初始化
load HeightData HeightData; % 加载地形数据

% 网格划分
LevelGrid = 10;
PortGrid = 21;

% 起点和终点网格点
starty = 10; starth = 4;
endy = 8; endh = 5;
m = 1;

% 算法参数
PopNumber = 10; % 种群个数
BestFitness = []; % 最佳个体记录

% 初始信息素
pheromone = ones(21, 21, 21);

%% 初始搜索路径
[path, pheromone] = searchpath(PopNumber, LevelGrid, PortGrid, pheromone, ...
    HeightData, starty, starth, endy, endh);
fitness = CacuFit(path); % 适应度计算
[bestfitness, bestindex] = min(fitness); % 最佳适应度
bestpath = path(bestindex, :); % 最佳路径
BestFitness = [BestFitness; bestfitness]; % 记录适应度

%% 信息素更新
rou = 0.2;
cfit = 100 / bestfitness;
for i = 2:PortGrid-1
    pheromone(i, bestpath(i*2-1), bestpath(i*2)) = ...
        (1-rou) * pheromone(i, bestpath(i*2-1), bestpath(i*2)) + rou * cfit;
end

%% 循环寻找最优路径
for kk = 1:100
    %% 路径搜索
    [path, pheromone] = searchpath(PopNumber, LevelGrid, PortGrid, ...
        pheromone, HeightData, starty, starth, endy, endh);

    %% 适应度值计算更新
    fitness = CacuFit(path);
    [newbestfitness, newbestindex] = min(fitness);
    if newbestfitness < bestfitness
        bestfitness = newbestfitness;
        bestpath = path(newbestindex, :);
    end
    BestFitness = [BestFitness; bestfitness];

    %% 更新信息素
    cfit = 100 / bestfitness;
    for i = 2:PortGrid-1
        pheromone(i, bestpath(i*2-1), bestpath(i*2)) = (1-rou) * ...
            pheromone(i, bestpath(i*2-1), bestpath(i*2)) + rou * cfit;
    end
end

%% 提取最佳路径
for i = 1:21
    a(i, 1) = bestpath(i*2-1);
    a(i, 2) = bestpath(i*2);
end

%% 绘制三维地形图和路径
figure(1);
[x, y] = meshgrid(1:21, 1:21);
z = HeightData;

% 绘制地形表面
surf(x, y, z, 'EdgeColor', 'none', 'FaceAlpha', 0.9);
colormap('parula'); % 地形配色
hold on;

% 添加光源和阴影效果
light('Position', [-1, -1, 1], 'Style', 'infinite');
lighting gouraud;
shading interp;

% 绘制起点和终点
scatter3(1, a(1, 1), a(1, 2)*200, 100, 'g', 'filled'); % 起点
text(1, a(1, 1), a(1, 2)*200 + 100, 'S', 'FontSize', 12, 'FontWeight', 'bold');

scatter3(21, a(21, 1), a(21, 2)*200, 100, 'r', 'filled'); % 终点
text(21, a(21, 1), a(21, 2)*200 + 100, 'T', 'FontSize', 12, 'FontWeight', 'bold');

% 绘制路径
plot3(1:21, a(:, 1)', a(:, 2)'*200, '-o', 'LineWidth', 2, ...
    'MarkerSize', 6, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'cyan');

% 坐标轴和标题设置
xlabel('X (km)', 'FontSize', 12);
ylabel('Y (km)', 'FontSize', 12);
zlabel('Z (m)', 'FontSize', 12);
title('基于蚁群算法的三维路径规划', 'FontSize', 14);
axis tight;
grid on;

%% 绘制适应度变化曲线
figure(2);
plot(BestFitness, 'LineWidth', 2);
grid on;
title('最佳适应度变化趋势', 'FontSize', 14);
xlabel('迭代次数', 'FontSize', 12);
ylabel('适应度值', 'FontSize', 12);
