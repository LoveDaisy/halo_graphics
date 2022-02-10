clear; close all; clc;

figure_size = [600, 450] * 0.9;
size_factor = 1.7;

% Style for crystals
crystal_style = {'FaceColor', 'w', 'FaceAlpha', 0.8, 'LineWidth', 2 * size_factor, 'EdgeColor', 'k'};
expand_crystal_style = {'FaceColor', 'w', 'FaceAlpha', 0.6, 'LineStyle', ':', ...
    'LineWidth', 1 * size_factor, 'EdgeColor', [1, 1, 1] * 0.5};
hit_crystal_style = {'FaceColor', 'none', 'LineWidth', 1 * size_factor, 'LineStyle', ':', ...
    'EdgeColor', [1, 1, 1] * 0.5};

% Style for faces
mirror_face_style = {'FaceColor', [1, 1, 1] * 0.1, 'EdgeColor', 'none'};
hit_face_style = {'FaceColor', [255, 252, 180]/255, 'FaceAlpha', 0.75, 'LineStyle', '-', ...
    'LineWidth', 1.2 * size_factor, 'EdgeColor', 'k'};

% Style for rays
arrow_scale = 0.2;
point_scale = 0.018;
ray_color = [252, 93, 83]/255;
expand_ray_color = 'b';
ray_style = {'LineWidth', 2 * size_factor, 'Color', ray_color, 'ArrowScale', arrow_scale, ...
    'PointScale', point_scale};
expand_ray_style = {'LineWidth', 1.5 * size_factor, 'LineStyle', ':', 'Color', expand_ray_color, ...
    'ArrowScale', arrow_scale, 'PointScale', point_scale};

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
c0.setDrawArgs(crystal_style{:});

fig_all = object.ComplexObj(c0);

curr_line = object.ArrowLine(raypath_pts, 'EndArrow', 1.05, 'StartArrow', 0.5);
curr_line.setDrawArgs(ray_style{:});
fig_all.addObj(curr_line);

clear curr_*

%%
% Make final transformation
final_t = transform.Rotation('from', [0, 0, -1], 'to', [1, 0, 0]);
fig_all.dynamicTransform(final_t);

fig_args = {'Color', 'w', 'Position', [0, 400, figure_size * size_factor]};
axes_args = {'Position', [0, 0, 1, 1], 'Projection', 'Perspective', ...
    'CameraPosition', [cosd(50), sind(50), 0.2] * 15 + [-1, 0.38, -0.65], 'CameraTarget', [0, 0, 0], ...
    'CameraViewAngle', 15, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1], 'PlotBoxAspectRatio', [3, 4, 4]};

%%
dt = 0.05;
anim = animate.SimpleSmoothAnimate;
% Move
figure(1); clf;
set(gcf, fig_args{:});
for t = 0:dt:1
    fig_all.draw();
    axes_args{6} = [cosd(50 + 40 * t), sind(50 + 40 * t), 0.2] * 15 + [-1*t, 0, 0];
    axes_args{8} = [-1*t, 0, 0];
    set(gca, axes_args{:});
    drawnow;
end

%%
% Reflect
curr_c = c0;
i=2;
curr_fid = raypath(i);
refl_t = transform.MirrorReflection(curr_c.getFaceNormal(curr_fid), ...
    mean(curr_c.getFaceVertices(curr_fid)));

curr_c.setDrawArgs(expand_crystal_style{:});

curr_line = object.ArrowLine(expand_raypath_pts(3:end, :), 'EndArrow', 1.05);
curr_line.setDrawArgs(expand_ray_style{:});

refl_obj = object.ComplexObj(curr_c, curr_line);
fig_all.addObj(refl_obj);

anim.reset();
anim.setTickStep(dt);
anim.addAction(@(t) fig_all.objects{end}.dynamicTransform(t), transform.Translation, refl_t);
while ~anim.finished()
    anim.tick();
    figure(1); clf;
    fig_all.draw();
    set(gca, axes_args{:});
    drawnow;
end

curr_c.applyTransform(refl_t);
curr_line.applyTransform(refl_t);
expand_raypath_pts(i+1:end, :) = refl_t.transform(expand_raypath_pts(i+1:end, :));

fig_all.objects = fig_all.objects(1:end-1);
fig_all.addObj(curr_c);
fig_all.addObj(curr_line);

%%
% Move
figure(1); clf;
set(gcf, fig_args{:});
for t = 0:dt:1
    fig_all.draw();
    axes_args{6} = [cosd(90 + 90 * t), sind(90 + 90 * t), 0.2 - 0.2 * t] * 15 + ...
        [-1, 3/8*t, -sqrt(3)/8*t];
    axes_args{8} = [-1, 3/8*t, -sqrt(3)/8*t];
    set(gca, axes_args{:});
    drawnow;
end

%%
% Reflet
fig_all.objects = fig_all.objects(1:end-1);
curr_line = object.ArrowLine(expand_raypath_pts(3:4, :));
curr_line.setDrawArgs(expand_ray_style{:});
fig_all.addObj(curr_line);

i = 3;
curr_fid = raypath(i);
refl_t = transform.MirrorReflection(curr_c.getFaceNormal(curr_fid), ...
    mean(curr_c.getFaceVertices(curr_fid)));

curr_c.setDrawArgs(expand_crystal_style{:});

curr_line = object.ArrowLine(expand_raypath_pts(4:end, :), 'EndArrow', 1.05);
curr_line.setDrawArgs(expand_ray_style{:});

refl_obj = object.ComplexObj(curr_c, curr_line);
fig_all.addObj(refl_obj);

anim.reset();
anim.setTickStep(dt);
anim.addAction(@(t) fig_all.objects{end}.dynamicTransform(t), transform.Translation, refl_t);
while ~anim.finished()
    anim.tick();
    figure(1); clf;
    fig_all.draw();
    set(gca, axes_args{:});
    drawnow;
end

curr_c.applyTransform(refl_t);
curr_line.applyTransform(refl_t);
expand_raypath_pts(i+1:end, :) = refl_t.transform(expand_raypath_pts(i+1:end, :));

fig_all.objects = fig_all.objects(1:end-1);
fig_all.addObj(curr_c);
fig_all.addObj(curr_line);

%%
% Move
figure(1); clf;
set(gcf, fig_args{:});
for t = 0:dt:1
    fig_all.draw();
    axes_args{6} = [cosd(180), sind(180), 0] * 15 + [-1, 3/8+(-3/8+3/4)*t, -sqrt(3)/8+(sqrt(3)/8-sqrt(3)/2)*t];
    axes_args{8} = [-1, 3/8+(-3/8+3/4)*t, -sqrt(3)/8+(sqrt(3)/8-sqrt(3)/2)*t];
    set(gca, axes_args{:});
    drawnow;
end

%%
% Reflet
fig_all.objects = fig_all.objects(1:end-1);
curr_line = object.ArrowLine(expand_raypath_pts(4:5, :));
curr_line.setDrawArgs(expand_ray_style{:});
fig_all.addObj(curr_line);

i = 4;
curr_fid = raypath(i);
refl_t = transform.MirrorReflection(curr_c.getFaceNormal(curr_fid), ...
    mean(curr_c.getFaceVertices(curr_fid)));

curr_c.setDrawArgs(expand_crystal_style{:});

curr_line = object.ArrowLine(expand_raypath_pts(5:end, :), 'EndArrow', 1.05);
curr_line.setDrawArgs(expand_ray_style{:});

refl_obj = object.ComplexObj(curr_c, curr_line);
fig_all.addObj(refl_obj);

anim.reset();
anim.setTickStep(dt);
anim.addAction(@(t) fig_all.objects{end}.dynamicTransform(t), transform.Translation, refl_t);
while ~anim.finished()
    anim.tick();
    figure(1); clf;
    fig_all.draw();
    set(gca, axes_args{:});
    drawnow;
end

curr_c.applyTransform(refl_t);
expand_raypath_pts(i+1:end, :) = refl_t.transform(expand_raypath_pts(i+1:end, :));
curr_line = object.ArrowLine(expand_raypath_pts(3:end, :), 'EndArrow', 1.05);
curr_line.setDrawArgs(expand_ray_style{:});

fig_all.objects = fig_all.objects(1:end-2);
fig_all.addObj(curr_c);
fig_all.addObj(curr_line);

%%
% Move
figure(1); clf;
set(gcf, fig_args{:});
for t = 0:dt:1
    fig_all.draw();
    axes_args{6} = [cosd(180-130*t), sind(180-130*t), 0.2*t] * 15 + ...
        [-1, 3/4+(-3/4+0.4)*t, -sqrt(3)/2+(sqrt(3)/2-0.7)*t];
    axes_args{8} = [-1, 3/4+(-3/4+0.4)*t, -sqrt(3)/2+(sqrt(3)/2-0.7)*t];
    set(gca, axes_args{:});
    drawnow;
end
