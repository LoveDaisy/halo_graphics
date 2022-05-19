clear; close all; clc;

%%
figure_size = [1920, 1080] * 0.4;
size_factor = 1.5;

% Style for crystals
crystal_material = render.Material('FaceColor', 'w', 'FaceAlpha', 0.8, ...
    'LineWidth', 2 * size_factor, 'EdgeColor', 'k', 'NumberColor', [1, 1, 1] * 0.7);
expand_crystal_material = render.Material('FaceColor', 'w', 'FaceAlpha', 0.6, 'LineStyle', ':', ...
    'LineWidth', 1 * size_factor, 'EdgeColor', [1, 1, 1] * 0.5);

% Style for faces
mirror_face_material = render.Material('FaceColor', [1, 1, 1] * 0.1, 'EdgeColor', 'none');

% Style for rays
arrow_scale = 0.2;
point_scale = 0.018;
ray_color = [252, 93, 83]/255;
expand_ray_color = 'b';
ray_style = render.Material('LineWidth', 2 * size_factor, 'Color', ray_color, 'ArrowScale', arrow_scale, ...
    'PointScale', point_scale);
expand_ray_style = render.Material('LineWidth', 1.5 * size_factor, 'LineStyle', ':', 'Color', expand_ray_color, ...
    'ArrowScale', arrow_scale, 'PointScale', point_scale);

% Make crystal
crystal_h = 1.3;

% Set some animation parameters
cam = render.Camera('Position', [0, 0, 1, 1], 'Projection', 'Perspective', ...
    'CameraPosition', [cosd(50), sind(50), 0.4] * 15, 'CameraTarget', [0, 0, 0], ...
    'CameraViewAngle', 11, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1], 'PlotBoxAspectRatio', [3, 4, 4]);
% cam.setOutputFmt('output/ch4_raypath_%03d.png');


%%
% Start compose figures
c0 = object.CrystalObj(crystal_h, 'FaceNumber', true);
c0.setMaterial(crystal_material);

fig_all_mat = object.ComplexObj(c0);
fig_all_llr = object.ComplexObj(c0);
fig_all_slerp = object.ComplexObj(c0);

clear curr_*

llr0 = [-20, -60, 0];
llr1 = [220, 80, 40];
xyz0 = [cosd(llr0(2)) * cosd(llr0(1)), cosd(llr0(2)) * sind(llr0(1)), sind(llr0(2))];
xyz1 = [cosd(llr1(2)) * cosd(llr1(1)), cosd(llr1(2)) * sind(llr1(1)), sind(llr1(2))];
quat0 = quatmultiply(quatmultiply([cosd(llr0(3) / 2), -sind(llr0(3) / 2) * [0, 0, 1]], ...
    [cosd(45 - llr0(2) / 2), -sind(45 - llr0(2) / 2) * [0, 1, 0]]), ...
    [cosd(llr0(1) / 2), -sind(llr0(1) / 2) * [0, 0, 1]]);
quat1 = quatmultiply(quatmultiply([cosd(llr1(3) / 2), -sind(llr1(3) / 2) * [0, 0, 1]], ...
    [cosd(45 - llr1(2) / 2), -sind(45 - llr1(2) / 2) * [0, 1, 0]]), ...
    [cosd(llr1(1) / 2), -sind(llr1(1) / 2) * [0, 0, 1]]);
omega = acos(dot(quat0, quat1));
so = sin(omega);
r0_matt = transform.Rotation('axis', [0, 0, 1], 'theta', llr0(3)).matt * ...
    transform.Rotation('axis', [0, 1, 0], 'theta', 90-llr0(2)).matt * ...
    transform.Rotation('axis', [0, 0, 1], 'theta', llr0(1)).matt;
r1_matt = transform.Rotation('axis', [0, 0, 1], 'theta', llr1(3)).matt * ...
    transform.Rotation('axis', [0, 1, 0], 'theta', 90-llr1(2)).matt * ...
    transform.Rotation('axis', [0, 0, 1], 'theta', llr1(1)).matt;

% Final view
output = true;
canvas_fig = figure(1); clf;
set(canvas_fig, 'Color', 'w', 'Position', [0, 400, figure_size * size_factor]);

cam.setCamPose([0, 0.3, 15, 0, 0, 0]);
pos_offset = 1.8;

if output
    cam.setOutputFmt('output/tmp/ch5_interp_%03d.png');
end
anim = animate.LinearAnimate;
anim.reset();
anim.setTickStep(1/60);
anim.setDuration(1);
anim.addAction(@(m)fig_all_mat.dynamicTransform(transform.Rotation('mat', m).chain(...
    transform.Translation([0, -pos_offset, 0]))), r0_matt', r1_matt');
anim.addAction(@(llr)fig_all_llr.dynamicTransform(transform.Rotation('axis', [0, 0, 1], 'theta', llr(3)).chain(...
    transform.Rotation('axis', [0, 1, 0], 'theta', 90-llr(2))).chain(...
    transform.Rotation('axis', [0, 0, 1], 'theta', llr(1)))), llr0, llr1);
anim.addAction(@(t)fig_all_slerp.dynamicTransform(...
    transform.Rotation('mat', quatrotate(sin((1-t)*omega)/so*quat0 + sin(t*omega)/so*quat1, eye(3))').chain(...
    transform.Translation([0, pos_offset, 0]))), 0, 1);
anim.addPostActions(@clf, canvas_fig);
anim.addPostActions(@text, 0, -pos_offset, 1.3, 'Interpolation on rotation matrix', ...
    'horizontalalignment', 'center', 'fontsize', 18, 'fontweight', 'bold');
anim.addPostActions(@text, 0, 0, 1.3, 'Interpolation on Euler angle', ...
    'horizontalalignment', 'center', 'fontsize', 18, 'fontweight', 'bold');
anim.addPostActions(@text, 0, pos_offset, 1.3, 'SLERP on unit quaternion', ...
    'horizontalalignment', 'center', 'fontsize', 18, 'fontweight', 'bold');
anim.addPostActions(@cam.render, fig_all_mat, fig_all_llr, fig_all_slerp);
anim.play();

