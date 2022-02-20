clear; close all; clc;

figure_size = [1920, 1080] * 0.4;
size_factor = 1.5;

% Style for crystals
crystal_material = render.Material('FaceColor', 'w', 'FaceAlpha', 0., 'LineStyle', ':', ...
    'LineWidth', 1 * size_factor, 'EdgeColor', [1, 1, 1] * 0.5, 'NumberColor', [1, 1, 1] * 0.7, 'NumberScale', 1);
expand_crystal_material = render.Material('FaceColor', 'w', 'FaceAlpha', 0., 'LineStyle', ':', ...
    'LineWidth', 1 * size_factor, 'EdgeColor', [1, 1, 1] * 0.5, ...
    'NumberColor', [1, 1, 1] * 0.82, 'NumberScale', 1);

% Style for faces
mirror_face_material = render.Material('FaceColor', [246, 224, 75]/255, ...
    'EdgeColor', 'none', 'FaceAlpha', 0.8);

% Style for rays
arrow_scale = 0.14;
point_scale = 0.014;
ray_color = [252, 93, 83]/255;
expand_ray_color = [51, 122, 202]/255;
ray_style = render.Material('LineWidth', 1.5 * size_factor, 'Color', ray_color, 'LineStyle', ':', ...
    'ArrowScale', arrow_scale, ...
    'PointScale', point_scale);
expand_ray_style = render.Material('LineWidth', 2 * size_factor, 'LineStyle', '-', 'Color', expand_ray_color, ...
    'ArrowScale', arrow_scale, 'PointScale', point_scale);

% Make crystal
crystal_h = 0.4;
crystal = optics.make_prism_crystal(crystal_h);

% Trace a ray
raypath = [1, 3, 2];
p0 = [.4, .4, 0, .1, .1, 0] * crystal.vtx(crystal.face{raypath(1)}, :);
r0 = optics.normalize_vector([0.7, 0.1, -0.5]);
ray_trace_res = optics.trace_ray(p0, r0, crystal, raypath);
raypath_pts = [p0 - r0; ray_trace_res(:, 1:3); ray_trace_res(end, 1:3) + ray_trace_res(end, 4:6)];
expand_raypath_pts = raypath_pts;
for i = 2:length(raypath)-1
    curr_mirror = crystal.vtx(crystal.face{raypath(i)}, :);
    curr_normal = crystal.face_norm(raypath(i), :);
    curr_t = transform.MirrorReflection('normal', curr_normal, 'p0', mean(curr_mirror));
    expand_raypath_pts(i+2:end, :) = curr_t.transform(expand_raypath_pts(i+2:end, :));
end
raypath_pts = raypath_pts(3:end, :);

geo_center_pts = [0, 0, crystal_h/2; sqrt(3)/4, 0, 0; sqrt(3)/2, 0, -crystal_h/2];
geo_optim_pts = [sqrt(3)/4-0.0127, 0, crystal_h/2; sqrt(3)/4, 0, 0; sqrt(3)/4+0.0127, 0, -crystal_h/2];

%%
% Start compose figures
enable_crystal_number = false;
c0 = object.CrystalObj(crystal_h);
c0.setMaterial(crystal_material);
c0.enableFaceNumber(enable_crystal_number);
fig_all = object.ComplexObj(c0);
fig_optim = object.ComplexObj(c0);

curr_line = object.ArrowLine(raypath_pts, 'EndArrow', 1.1);
curr_line.setMaterial(ray_style);
fig_all.addObj(curr_line);

curr_patch = c0.getPatch(raypath(1));
curr_patch.setMaterial(mirror_face_material);
fig_mirror = object.ComplexObj(curr_patch);

c0.setMaterial(expand_crystal_material);
for i = 2:length(raypath)-1
    curr_mirror = crystal.vtx(crystal.face{raypath(i)}, :);
    curr_normal = crystal.face_norm(raypath(i), :);
    curr_t = transform.MirrorReflection('normal', curr_normal, 'p0', mean(curr_mirror));
    
    curr_patch = c0.getPatch(raypath(i));
    curr_patch.setMaterial(mirror_face_material);
    fig_mirror.addObj(curr_patch);
    
    c0.dynamicTransform(curr_t);
    fig_all.addObj(c0);
    fig_optim.addObj(c0);
end
curr_patch = c0.getPatch(raypath(end));
curr_patch.setMaterial(mirror_face_material);
fig_mirror.addObj(curr_patch);

curr_line = object.ArrowLine(expand_raypath_pts, 'EndArrow', 1.1, 'StartArrow', 0.5);
curr_line.setMaterial(expand_ray_style);
fig_all.addObj(curr_line);

fig_all.addObj(fig_mirror);
fig_optim.addObj(fig_mirror);

curr_line = object.ArrowLine(geo_center_pts);
curr_line.setMaterial(expand_ray_style);
fig_optim.addObj(curr_line);

clear curr_*

%%
% Set some animation parameters
cam = render.Camera('Position', [0, 0, 1, 1], 'Projection', 'Perspective', ...
    'CameraPosition', [cosd(50), sind(50), 0.4] * 15, 'CameraTarget', [0, 0, 0], ...
    'CameraViewAngle', 8, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1], 'PlotBoxAspectRatio', [3, 4, 4]);
if enable_crystal_number
    cam.setOutputFmt('output/ch2_img/light_corridor_rp132_fn_%02d.png');
else
    cam.setOutputFmt('output/ch2_img/light_corridor_rp132_%02d.png');
end

% Normal view
canvas_fig = figure(1); clf;
set(canvas_fig, 'Color', 'w', 'Position', [0, 400, figure_size * size_factor]);
cam.setCamPose([-80, .4, 15, .433, 0, 0]);
cam.render(fig_all);

clf(canvas_fig);
cam.render(fig_optim);

clf(canvas_fig);
fig_input_rays = object.ComplexObj;
for dh = [-1, 0.1, 0.3, 0.5, 0.7, 0.9]
    geo_tf_pts = [[0, 0, crystal_h/2] + 2*[-sqrt(3)/4, 0, crystal_h/2 * dh]; 0, 0, crystal_h/2];
    curr_line = object.ArrowLine(geo_tf_pts, 'StartArrow', 0.5);
    curr_line.setMaterial(ray_style);
    fig_input_rays.addObj(curr_line);
end
fig_optim.addObj(fig_input_rays);
cam.render(fig_optim);

%%
fig_optim.objects = fig_optim.objects(1:end-2);

geo_optim_pts = [[-sind(6), 0, cosd(6)]*0.5 + geo_optim_pts(1, :);
    geo_optim_pts;
    [sind(6), 0, -cosd(6)]*0.5 + geo_optim_pts(end, :)];

curr_line = object.ArrowLine(geo_optim_pts, 'StartArrow', 0.5, 'EndArrow', 1.1);
curr_line.setMaterial(expand_ray_style);
fig_optim.addObj(curr_line);
clf(canvas_fig);
cam.render(fig_optim);


