clear; close all; clc;

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
crystal_h = 1;
crystal = optics.make_prism_crystal(crystal_h);

% Trace a ray
raypath = [3, 1, 5, 7, 4];
p0 = [.5, .0, .1, .4] * crystal.vtx(crystal.face{raypath(1)}, :);
r0 = optics.normalize_vector([-0.85, 0.55, 0.6]);
ray_trace_res = optics.trace_ray(p0, r0, crystal, raypath);
raypath_pts = [p0 - r0; ray_trace_res(:, 1:3); ray_trace_res(end, 1:3) + ray_trace_res(end, 4:6)];
expand_raypath_pts = raypath_pts;

%%
% Start compose figures
enable_crystal_number = false;
c0 = object.CrystalObj(crystal_h);
c0.setMaterial(crystal_material);
c0.enableFaceNumber(enable_crystal_number);

fig_all = object.ComplexObj(c0);

curr_line = object.ArrowLine(raypath_pts, 'EndArrow', 1.05, 'StartArrow', 0.5);
curr_line.setMaterial(ray_style);
fig_all.addObj(curr_line);

clear curr_*

%%
% Make final transformation
final_t = transform.Rotation('from', [0, 0, -1], 'to', [1, 0, 0]);
fig_all.dynamicTransform(final_t);

% Set some animation parameters
cam = render.Camera('Position', [0, 0, 1, 1], 'Projection', 'Perspective', ...
    'CameraPosition', [cosd(50), sind(50), 0.4] * 15, 'CameraTarget', [0, 0, 0], ...
    'CameraViewAngle', 11, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1], 'PlotBoxAspectRatio', [3, 4, 4]);
if enable_crystal_number
    cam.setOutputFmt('output/ch2_img/rp31574_fn_%02d.png');
else
    cam.setOutputFmt('output/ch2_img/rp31574_%02d.png');
end

% Normal view
canvas_fig = figure(1); clf;
set(canvas_fig, 'Color', 'w', 'Position', [0, 400, figure_size * size_factor]);
cam.render(fig_all);

% Side view
cam.setCamProjection('orthographic');
cam.setCamPose([0, 0, 15, 0, 0, 0]);
cam.render(fig_all);

cam.setCamPose([90, 0, 15, 0, 0, 0]);
cam.render(fig_all);


