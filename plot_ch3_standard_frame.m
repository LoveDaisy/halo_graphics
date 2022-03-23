clear; close all; clc;

figure_size = [1920, 1080] * 0.4;
size_factor = 1.5;

% Style for crystals
crystal_material = render.Material('FaceColor', 'w', 'FaceAlpha', 0.9, ...
    'LineWidth', 2 * size_factor, 'EdgeColor', 'k', 'NumberColor', [1, 1, 1] * 0.7);
expand_crystal_material = render.Material('FaceColor', 'w', 'FaceAlpha', 0.6, 'LineStyle', ':', ...
    'LineWidth', 1 * size_factor, 'EdgeColor', [1, 1, 1] * 0.5);

% Style for faces
mirror_face_material = render.Material('FaceColor', [1, 1, 1] * 0.1, 'EdgeColor', 'none');

% Style for rays
arrow_scale = 0.06;
point_scale = 0.0;
axis_color = [252, 93, 83]/255;
axis_style = render.Material('LineWidth', 1 * size_factor, 'Color', axis_color, ...
    'ArrowScale', arrow_scale, ...
    'PointScale', point_scale);

% Make crystal
crystal_h = 0.4;
crystal = optics.make_prism_crystal(crystal_h);

%%
% Start compose figures
c0 = object.CrystalObj(crystal_h);
c0.setMaterial(crystal_material);
c0.enableFaceNumber(true);
fig_all = object.ComplexObj(c0);

x_axis = object.ArrowLine([-1, 0, 0; 1, 0, 0], 'endarrow', 1.01, 'ArrowSolid', true);
x_axis.setMaterial(axis_style);
fig_all.addObj(x_axis);

y_axis = object.ArrowLine([0, -1, 0; 0, 1, 0], 'endarrow', 1.01, 'ArrowSolid', true);
y_axis.setMaterial(axis_style);
fig_all.addObj(y_axis);

z_axis = object.ArrowLine([0, 0, -1; 0, 0, 1]*0.6, 'endarrow', 1.01, 'ArrowSolid', true);
z_axis.setMaterial(axis_style);
fig_all.addObj(z_axis);

clear curr_*

%%
% Set some animation parameters
cam = render.Camera('Position', [0, 0, 1, 1], 'Projection', 'Perspective', ...
    'CameraPosition', [cosd(50), sind(50), 0.4] * 15, 'CameraTarget', [0, 0, 0], ...
    'CameraViewAngle', 20, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1], 'PlotBoxAspectRatio', [3, 4, 4]);
cam.setOutputFmt('output/ch3_standard_frame_%03d.png');

canvas_fig = figure(1); clf;
set(canvas_fig, 'Color', 'w', 'Position', [0, 400, figure_size * size_factor]);

% Add text
text(1.07, 0, 0, '$x$', 'interpreter', 'latex', 'fontsize', 28);
text(0, 1.07, 0, '$y$', 'interpreter', 'latex', 'fontsize', 28);
text(0, 0, 0.64, '$z$', 'interpreter', 'latex', 'fontsize', 28);

% Side view
cam.setCamPose([70, 0.4, 4, 0, 0, 0]);
cam.render(fig_all);


