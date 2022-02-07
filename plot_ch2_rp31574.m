clear all; close all; clc;

crystal_h = 2;
raypath = [3, 1, 5, 7, 4];
crystal = optics.make_prism_crystal(crystal_h);

p0 = [.35, .15, .15, .35] * crystal.vtx(crystal.face{raypath(1)}, :);
r0 = optics.normalize_vector([-0.87, 1, 2]);
ray_trace_res = optics.trace_ray(p0, r0, crystal, raypath);
raypath_pts = [p0 - r0; ray_trace_res(:, 1:3); ray_trace_res(end, 1:3) + ray_trace_res(end, 4:6)];

c0 = object.makePrismCrystal(crystal_h);
c0.setDrawArgs('FaceColor', 'w', 'FaceAlpha', 0.5, 'LineWidth', 2, 'EdgeColor', 'k');

cmp = object.ComplexObj(c0);
curr_c = c0;
for i = 2:length(raypath)-1
    curr_t = transform.MirrorReflection(curr_c.getFaceNormal(raypath(i)), ...
        mean(curr_c.getFaceVertices(raypath(i))));
    curr_c.applyTransform(curr_t);
    curr_c.setDrawArgs('FaceColor', 'w', 'FaceAlpha', 0.5, 'LineStyle', ':', 'LineWidth', 1, 'EdgeColor', 'k');
    cmp.addObj(curr_c);
end
clear c0 curr_c curr_t;

line = object.ArrowLine(raypath_pts, 'EndArrow', 0.8, 'StartArrow', 0.5);
line.setDrawArgs('LineWidth', 2, 'Color', 'r');
cmp.addObj(line);

cmp.applyTransform(transform.Rotation('from', [0, 0, 1], 'to', [1, 0, 0]));

figure(1); clf;
hold on;
cmp.draw();
set(gca, 'Projection', 'Perspective');
axis equal;