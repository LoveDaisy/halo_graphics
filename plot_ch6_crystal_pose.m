clear; close all; clc;

%%
figure_size = [1080, 1080] * 0.4;
size_factor = 1.5;

% Style for crystals
crystal_material = render.Material('FaceColor', 'w', 'FaceAlpha', 0.8, ...
    'LineWidth', 2 * size_factor, 'EdgeColor', 'k', 'NumberColor', [1, 1, 1] * 0.7);

% Style for rays
arrow_scale = 0.15;
point_scale = 0.018;
arrow_color = [252, 93, 83]/255;
arrow_material = render.Material('LineWidth', 4 * size_factor, 'Color', arrow_color, 'ArrowScale', arrow_scale, ...
    'PointScale', point_scale);

% Make crystal
crystal_h = 0.3;

% Set some animation parameters
cam = render.Camera('Position', [0, 0, 1, 1], 'Projection', 'Perspective', ...
    'CameraPosition', [cosd(50), sind(50), 0.4] * 15, 'CameraTarget', [0, 0, 0], ...
    'CameraViewAngle', 11, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1], 'PlotBoxAspectRatio', [3, 4, 4]);


%%
% Start compose figures
c0 = object.CrystalObj(crystal_h, 'FaceNumber', false);
c0.setMaterial(crystal_material);

a = object.ArrowLine([0, 0, crystal_h/2; 0, 0, crystal_h/2+0.5], 'EndArrow', 1.15, 'ArrowSolid', true);
a.setMaterial(arrow_material);

obj = object.ComplexObj(c0, a);
% obj.dynamicTransform(transform.Rotation('from', [0,0,1], 'to', [1,0,0]).chain(transform.Scale(1)));
obj.dynamicTransform(transform.Rotation('from', [0,0,1], 'to', [0.1,0,1]));

clear curr_*

% Final view
canvas_fig = figure(1); clf;
set(canvas_fig, 'Color', 'w', 'Position', [0, 400, figure_size * size_factor]);
hold on;

cam_pose = [50, 0.4, 18];
cam_from = cam_pose(3) * [cosd(cam_pose(1)), sind(cam_pose(1)), cam_pose(2)];
cam_target = [0, 0, 0];
cam.setCamPose([cam_pose, cam_target]);
cam.render(obj);

%%
% Draw grid
radii = 1.5;
tmp_theta = (0:2:360)';
for lat = -90:15:90
    if abs(lat) < 1e-3
        tmp_wid = 1.5;
    else
        tmp_wid = 0.4;
    end
    tmp_data = [radii*cosd(tmp_theta)*cosd(lat), radii*sind(tmp_theta)*cosd(lat), ...
        radii*ones(size(tmp_theta))*sind(lat)];
    valid_idx = tmp_data * (cam_target - cam_from)' < 0;
    tmp_valid_data = tmp_data(valid_idx, :);
    tmp_diff = sqrt(sum(diff(tmp_valid_data).^2, 2));
    tmp_idx = find(tmp_diff > radii * 2 * pi / 180);
    tmp_idx = [[1; tmp_idx+1], [tmp_idx; size(tmp_valid_data, 1)]];
    for j = 1:size(tmp_idx, 1)
        id1 = tmp_idx(j, 1);
        id2 = tmp_idx(j, 2);
        plot3(tmp_valid_data(id1:id2, 1), tmp_valid_data(id1:id2, 2), tmp_valid_data(id1:id2, 3), ...
            'color', [1,1,1]*0.5, 'linewidth', tmp_wid);
    end
    if abs(lat) < 1e-3
        tmp_valid_data = tmp_data(~valid_idx, :);
        tmp_diff = sqrt(sum(diff(tmp_valid_data).^2, 2));
        tmp_idx = find(tmp_diff > radii * 2 * pi / 180);
        tmp_idx = [[1; tmp_idx+1], [tmp_idx; size(tmp_valid_data, 1)]];
        for j = 1:size(tmp_idx, 1)
            id1 = tmp_idx(j, 1);
            id2 = tmp_idx(j, 2);
            plot3(tmp_valid_data(id1:id2, 1), tmp_valid_data(id1:id2, 2), tmp_valid_data(id1:id2, 3), '--', ...
                'color', [1,1,1]*0.5, 'linewidth', tmp_wid);
        end
    end
end

tmp_theta = (-90:2:90)';
for lon = 0:20:359
    tmp_data = [radii*cosd(lon)*cosd(tmp_theta), radii*sind(lon)*cosd(tmp_theta), ...
        radii*sind(tmp_theta)];
    valid_idx = tmp_data * (cam_target - cam_from)' < 0;
    tmp_valid_data = tmp_data(valid_idx, :);
    tmp_diff = sqrt(sum(diff(tmp_valid_data).^2, 2));
    tmp_idx = find(tmp_diff > radii * 2 * pi / 180);
    tmp_idx = [[1; tmp_idx+1], [tmp_idx; size(tmp_valid_data, 1)]];
    for j = 1:size(tmp_idx, 1)
        id1 = tmp_idx(j, 1);
        id2 = tmp_idx(j, 2);
        plot3(tmp_valid_data(id1:id2, 1), tmp_valid_data(id1:id2, 2), tmp_valid_data(id1:id2, 3), ...
            'color', [1,1,1]*0.5, 'linewidth', 0.4);
    end
end
clear tmp_* id1 id2 i j

% Draw samples
num = 5000;
tmp_lat = randn(num, 1) * 5 + 90;
tmp_lat = asind(sind(tmp_lat));
tmp_lon = rand(num, 1) * 360;
tmp_valid_data = radii*[cosd(tmp_lon).*cosd(tmp_lat), sind(tmp_lon).*cosd(tmp_lat), sind(tmp_lat)];
plot3(tmp_valid_data(:, 1), tmp_valid_data(:, 2), tmp_valid_data(:, 3), '.', 'color', [1,1,1]*0.35);


