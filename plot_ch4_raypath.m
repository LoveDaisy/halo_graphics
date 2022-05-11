clear; close all; clc;

%%
% Prepare data
% p, d
pd_data = [0.322372,-0.313878,-0.468567  -0.583209,-0.098741,-0.806298
    -0.433013,-0.051304, 0.624518   0.644612, 0.763102, 0.046379
    0.014890,-0.491404, 0.319074  -0.630516, 0.129003, 0.765381];
mat_data = [ 0.365675,-0.605332, 0.707004
    0.365574,-0.605152,-0.707210
    0.855942, 0.517072, 0.000005
    -0.867208, 0.032286, 0.496899
    -0.496019, 0.031709,-0.867733
    -0.043772,-0.998976,-0.011484
    0.416155,-0.579320, 0.700859
    -0.398588, 0.576552, 0.713243
    -0.817278,-0.576173, 0.009025];
rp_data = {[8],[6,1,4],[8,1,6,4,8,2,6]};

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
crystal = optics.make_prism_crystal(crystal_h);

% Set some animation parameters
cam = render.Camera('Position', [0, 0, 1, 1], 'Projection', 'Perspective', ...
    'CameraPosition', [cosd(50), sind(50), 0.4] * 15, 'CameraTarget', [0, 0, 0], ...
    'CameraViewAngle', 11, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1], 'PlotBoxAspectRatio', [3, 4, 4]);
% cam.setOutputFmt('output/ch4_raypath_%03d.png');

for i = 1:3
    % Trace a ray
    raypath = rp_data{i};
    p0 = pd_data(i,1:3);
    r0 = pd_data(i,4:6);
    ray_trace_res = optics.trace_ray(p0, r0, crystal, raypath);
    raypath_pts = [p0 - r0; ray_trace_res(:, 1:3); ray_trace_res(end, 1:3) + ray_trace_res(end, 4:6)];
    
    %%
    % Start compose figures
    c0 = object.CrystalObj(crystal_h);
    c0.setMaterial(crystal_material);
    
    fig_all = object.ComplexObj(c0);
    
    curr_line = object.ArrowLine(raypath_pts, 'EndArrow', 1.05, 'StartArrow', 0.5);
    curr_line.setMaterial(ray_style);
    fig_all.addObj(curr_line);
    
    clear curr_*
    
    % Make final transformation
    final_rot_mat = mat_data((1:3)+(i-1)*3,:)';
    final_t = transform.Rotation('mat', final_rot_mat);
    fig_all.dynamicTransform(final_t);
    
    % Final view
    canvas_fig = figure(1); clf;
    set(canvas_fig, 'Color', 'w', 'Position', [0, 400, figure_size * size_factor]);
    
    c = final_t.transform(ray_trace_res(end, 1:3));
    cam.setCamPose([-140, 0.3, 15, c]);
    cam.render(fig_all);
end


