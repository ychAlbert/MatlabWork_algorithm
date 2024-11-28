%% 清空环境
clc;
clear;

%% 数据初始化
load HeightData HeightData; % 加载地形数据

% 网格划分
LevelGrid = 10;
PortGrid = 21;

% 起点和终点网格点
starty = 10; starth = 1;
endy = 8; endh = 21;

% 算法参数
MaxIterations = 100; % 最大迭代次数
StepSize = 1; % 单步移动步长
GoalThreshold = 1; % 判断是否到达目标的阈值
Radius = 2; % 搜索邻域半径（RTT* 特有参数）

%% 初始化起点和终点
startNode = [starth, starty];
endNode = [endh, endy];

% 存储RTT*树节点、父节点和路径成本
nodes = startNode;
parent = 0; % 父节点索引
cost = 0;  % 节点成本

% 标志是否找到路径
foundPath = false;

%% RTT*主循环
for iter = 1:MaxIterations
    % 随机采样新节点
    randNode = [randi([1, PortGrid]), randi([1, LevelGrid])];

    % 找到最近的已存在节点
    distances = sqrt(sum((nodes - randNode).^2, 2));
    [~, nearestIdx] = min(distances);
    nearestNode = nodes(nearestIdx, :);

    % 生成新节点，确保不超过StepSize
    direction = (randNode - nearestNode) / norm(randNode - nearestNode);
    newNode = round(nearestNode + StepSize * direction);

    % 检查新节点是否可达
    if newNode(1) < 1 || newNode(1) > PortGrid || newNode(2) < 1 || newNode(2) > LevelGrid
        continue;
    end

    % 检查与最近节点的连线是否可行（此处可加入障碍检测）
    % 简化假设：地形中无障碍

    % 添加新节点到树中
    nodes = [nodes; newNode];
    parent = [parent; nearestIdx];
    newCost = cost(nearestIdx) + norm(newNode - nearestNode);
    cost = [cost; newCost];

    % RTT*优化：重新连接邻域节点
    neighborIdx = find(distances <= Radius);
    for idx = neighborIdx'
        potentialCost = cost(idx) + norm(nodes(idx, :) - newNode);
        if potentialCost < cost(end)
            parent(end) = idx;
            cost(end) = potentialCost;
        end
    end

    % 检查是否到达目标
    if norm(newNode - endNode) <= GoalThreshold
        foundPath = true;
        break;
    end
end

%% 提取路径
if foundPath
    path = [endNode];
    currentIdx = size(nodes, 1);
    while currentIdx ~= 0
        path = [nodes(currentIdx, :); path];
        currentIdx = parent(currentIdx);
    end
else
    error('未找到路径');
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
scatter3(startNode(1), startNode(2), HeightData(startNode(2), startNode(1)), 100, 'g', 'filled');
text(startNode(1), startNode(2), HeightData(startNode(2), startNode(1)) + 100, 'S', 'FontSize', 12, 'FontWeight', 'bold');

scatter3(endNode(1), endNode(2), HeightData(endNode(2), endNode(1)), 100, 'r', 'filled');
text(endNode(1), endNode(2), HeightData(endNode(2), endNode(1)) + 100, 'T', 'FontSize', 12, 'FontWeight', 'bold');

% 绘制路径
for i = 1:size(path, 1)-1
    plot3([path(i, 1), path(i+1, 1)], [path(i, 2), path(i+1, 2)], ...
          [HeightData(path(i, 2), path(i, 1)), HeightData(path(i+1, 2), path(i+1, 1))], ...
          '-o', 'LineWidth', 2, 'MarkerSize', 6, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'cyan');
end

% 坐标轴和标题设置
xlabel('X (km)', 'FontSize', 12);
ylabel('Y (km)', 'FontSize', 12);
zlabel('Z (m)', 'FontSize', 12);
title('基于RTT*算法的三维路径规划', 'FontSize', 14);
axis tight;
grid on;
