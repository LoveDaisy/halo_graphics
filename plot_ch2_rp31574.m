clear; close all; clc;

figure_size = [1920, 1080] * 0.4;
size_factor = 1.5;

% Style for crystals
crystal_material = render.Material('FaceColor', 'w', 'FaceAlpha', 0.8, ...
    'LineWidth', 2 * size_factor, 'EdgeColor', 'k');
expand_crystal_material = render.Material('FaceColor', 'w', 'FaceAlpha', 0.6, 'LineStyle', ':', ...
    'LineWidth', 1 * size_factor, 'EdgeColor', [1, 1, 1] * 0.5);

% Style for faces
mirror_face_style = render.Material('FaceColor', [1, 1, 1] * 0.1, 'EdgeColor', 'none');
hit_face_style = render.Material('FaceColor', [255, 252, 180]/255, 'FaceAlpha', 0.75, 'LineStyle', '-', ...
    'LineWidth', 1.2 * size_factor, 'EdgeColor', 'k');

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
crystal_h = 2;
crystal = optics.make_prism_crystal(crystal_h);

% Trace a ray
raypath = [3, 1, 5, 7, 4];
p0 = [.3, .00, .20, .5] * crystal.vtx(crystal.face{raypath(1)}, :);
r0 = optics.normalize_vector([-0.85, 0.65, 1.6]);
ray_trace_res = optics.trace_ray(p0, r0, crystal, raypath);
raypath_pts = [p0 - r0; ray_trace_res(:, 1:3); ray_trace_res(end, 1:3) + ray_trace_res(end, 4:6)];
expand_raypath_pts = raypath_pts;

%%
% Start compose figures
c0 = object.Patch(crystal.vtx, crystal.face);
c0.setMaterial(crystal_material);

fig_all = object.ComplexObj(c0);

curr_line = object.ArrowLine(raypath_pts, 'EndArrow', 1.05, 'StartArrow', 0.5);
curr_line.setMaterial(ray_style);
fig_all.addObj(curr_line);

clear curr_*

%%
% Make final transformation
final_t = transform.Rotation('from', [0, 0, -1], 'to', [1, 0, 0]);
fig_all.dynamicTransform(final_t);

%%
dt = 1/10;
anim = animate.SimpleSmoothAnimate;
cam = render.Camera('Position', [0, 0, 1, 1], 'Projection', 'Perspective', ...
    'CameraPosition', [cosd(50), sind(50), 0.2] * 15, 'CameraTarget', [0, 0, 0], ...
    'CameraViewAngle', 15, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1], 'PlotBoxAspectRatio', [3, 4, 4]);
% cam.setOutputFmt('output/%04d.png');

% Move
canvas_fig = figure(1); clf;
set(canvas_fig, 'Color', 'w', 'Position', [0, 400, figure_size * size_factor]);
cam.render(fig_all);

anim.reset();
anim.setTickStep(dt);
anim.setDuration(0.8);
anim.addAction(@cam.setCamPose, [50, 0.2, 15, 0, 0, 0], [90, 0.2, 15, -1, 0, 0]);
anim.addPostActions(@cam.update);
anim.play();

%%
% Reflect
curr_c = c0;
i=2;
curr_fid = raypath(i);
refl_t = transform.MirrorReflection(curr_c.getFaceNormal(curr_fid), ...
    mean(curr_c.getFaceVertices(curr_fid)));

curr_c.setMaterial(expand_crystal_material);

curr_line = object.ArrowLine(expand_raypath_pts(3:end, :), 'EndArrow', 1.05);
curr_line.setMaterial(expand_ray_style);

refl_obj = object.ComplexObj(curr_c, curr_line);
fig_all.addObj(refl_obj);

anim.reset();
anim.setTickStep(dt);
anim.setDuration(2.1);
anim.addAction(@(t) fig_all.objects{end}.dynamicTransform(t), transform.Translation, refl_t);
anim.addPostActions(@clf, canvas_fig);
anim.addPostActions(@cam.render, fig_all);
anim.play();

curr_c.applyTransform(refl_t);
curr_line.applyTransform(refl_t);
expand_raypath_pts(i+1:end, :) = refl_t.transform(expand_raypath_pts(i+1:end, :));

fig_all.objects = fig_all.objects(1:end-1);
fig_all.addObj(curr_c);
fig_all.addObj(curr_line);

%%
% Move
clf(canvas_fig);
cam.render(fig_all);

anim.reset();
anim.setTickStep(dt);
anim.setDuration(0.8);
anim.addAction(@cam.setCamPose, [90, 0.2, 15, -1, 0, 0], [180, 0, 15, -1, 3/8, -sqrt(3)/8]);
anim.addPostActions(@cam.update);
anim.play();

%%
% Reflet
fig_all.objects = fig_all.objects(1:end-1);
curr_line = object.ArrowLine(expand_raypath_pts(3:4, :));
curr_line.setMaterial(expand_ray_style);
fig_all.addObj(curr_line);

i = 3;
curr_fid = raypath(i);
refl_t = transform.MirrorReflection(curr_c.getFaceNormal(curr_fid), ...
    mean(curr_c.getFaceVertices(curr_fid)));

curr_c.setMaterial(expand_crystal_material);

curr_line = object.ArrowLine(expand_raypath_pts(4:end, :), 'EndArrow', 1.05);
curr_line.setMaterial(expand_ray_style);

refl_obj = object.ComplexObj(curr_c, curr_line);
fig_all.addObj(refl_obj);

anim.reset();
anim.setTickStep(dt);
anim.setDuration(1.6);
anim.addAction(@(t) fig_all.objects{end}.dynamicTransform(t), transform.Translation, refl_t);
anim.addPostActions(@clf, canvas_fig);
anim.addPostActions(@cam.render, fig_all);
anim.play();

curr_c.applyTransform(refl_t);
curr_line.applyTransform(refl_t);
expand_raypath_pts(i+1:end, :) = refl_t.transform(expand_raypath_pts(i+1:end, :));

fig_all.objects = fig_all.objects(1:end-1);
fig_all.addObj(curr_c);
fig_all.addObj(curr_line);

%%
% Move
clf(canvas_fig);
cam.render(fig_all);

anim.reset();
anim.setTickStep(dt);
anim.setDuration(0.8);
anim.addAction(@cam.setCamPose, [180, 0, 15, -1, 3/8, -sqrt(3)/8], [180, 0, 15, -1, 3/4, -sqrt(3)/2]);
anim.addPostActions(@cam.update);
anim.play();

%%
% Reflet
fig_all.objects = fig_all.objects(1:end-1);
curr_line = object.ArrowLine(expand_raypath_pts(4:5, :));
curr_line.setMaterial(expand_ray_style);
fig_all.addObj(curr_line);

i = 4;
curr_fid = raypath(i);
refl_t = transform.MirrorReflection(curr_c.getFaceNormal(curr_fid), ...
    mean(curr_c.getFaceVertices(curr_fid)));

curr_c.setMaterial(expand_crystal_material);

curr_line = object.ArrowLine(expand_raypath_pts(5:end, :), 'EndArrow', 1.05);
curr_line.setMaterial(expand_ray_style);

refl_obj = object.ComplexObj(curr_c, curr_line);
fig_all.addObj(refl_obj);

anim.reset();
anim.setTickStep(dt);
anim.setDuration(1.6);
anim.addAction(@(t) fig_all.objects{end}.dynamicTransform(t), transform.Translation, refl_t);
anim.addPostActions(@clf, canvas_fig)
anim.addPostActions(@cam.render, fig_all);
anim.play();

curr_c.applyTransform(refl_t);
expand_raypath_pts(i+1:end, :) = refl_t.transform(expand_raypath_pts(i+1:end, :));
curr_line = object.ArrowLine(expand_raypath_pts(3:end, :), 'EndArrow', 1.05);
curr_line.setMaterial(expand_ray_style);

fig_all.objects = fig_all.objects(1:end-2);
fig_all.addObj(curr_c);
fig_all.addObj(curr_line);

%%
% Move
clf(canvas_fig);
cam.render(fig_all);

anim.reset();
anim.setTickStep(dt);
anim.setDuration(0.8);
anim.addAction(@cam.setCamPose, [180, 0, 15, -1, 3/4, -sqrt(3)/2], [50, 0.2, 15, -1, 0.4, -0.7]);
anim.addPostActions(@cam.update);
anim.play();
