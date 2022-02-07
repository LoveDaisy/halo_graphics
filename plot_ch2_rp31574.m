clear all; close all; clc;

raypath = [3, 1, 5, 7, 4];

crystal0 = object.makePrismCrystal(2);
crystal0.setDrawArgs('FaceColor', 'w', 'FaceAlpha', 0.85, 'LineWidth', 2, 'EdgeColor', 'k');

cmp = object.ComplexObj(crystal0);
curr_crystal = crystal0;
for i = 2:length(raypath)-1
    curr_transform = transform.MirrorReflection(curr_crystal.getFaceNormal(raypath(i)), ...
        mean(curr_crystal.getFaceVertices(raypath(i))));
    curr_crystal.applyTransform(curr_transform);
    curr_crystal.setDrawArgs('FaceColor', 'w', 'FaceAlpha', 0.85, 'LineStyle', ':', 'LineWidth', 1, 'EdgeColor', 'k');
    cmp.addObj(curr_crystal);
end

line = object.ArrowLine([0, 0, 0; 1, 0, 0; 0.7, 1, 0], 'EndArrow', 1.02, 'StartArrow', 0.2);

cmp.applyTransform(transform.Rotation('from', [0, 0, 1], 'to', [1, 0, 0]));

figure(1); clf;
hold on;
cmp.draw();
line.draw('LineWidth', 2, 'Color', 'r');
set(gca, 'Projection', 'Perspective');
axis equal;