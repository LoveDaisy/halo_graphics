classdef CrystalObj < object.Patch
% Constructor
methods
    function obj = CrystalObj(varargin)
        p = inputParser;
        p.addOptional('h', 1, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
        p.addParameter('FaceNumber', false, @(x) validateattributes(x, {'logical'}, {'scalar'}));
        p.parse(varargin{:});

        obj.crystal = optics.make_prism_crystal(p.Results.h);
        obj.enable_face_number = p.Results.FaceNumber;
        obj.vtx = obj.crystal.vtx;
        obj.surf_xyz = {
            [obj.vtx([4, 4, 4, 4, 3, 3, 3, 3, 2, 2, 2, 2], 1), ...
             obj.vtx([2, 2, 1, 1, 3, 2, 1, 6, 2, 2, 1, 1], 2), ...
             obj.vtx([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], 3)], ...
            [obj.vtx([1, 1, 1, 1, 3, 3, 3, 3, 4, 4, 4, 4], 1), ...
             obj.vtx([2, 2, 1, 1, 3, 2, 1, 6, 2, 2, 1, 1], 2), ...
             obj.vtx([7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7], 3)], ...
            [obj.vtx([1, 2, 3, 4, 5, 6, 1; 7, 8, 9, 10, 11, 12, 7], 1), ...
             obj.vtx([1, 2, 3, 4, 5, 6, 1; 7, 8, 9, 10, 11, 12, 7], 2), ...
             obj.vtx([1, 2, 3, 4, 5, 6, 1; 7, 8, 9, 10, 11, 12, 7], 3)]
        };

        face_len = cellfun(@length, obj.crystal.face);
        faces = nan(length(face_len), max(face_len));
        for i = 1:size(faces, 1)
            faces(i, 1:face_len(i)) = obj.crystal.face{i};
        end
        obj.faces = faces;
    end
end

% Public methods
methods
    % ========== Override methods ==========
    function draw(obj, varargin)
        if ~obj.enable_face_number
            obj.draw@object.Patch(varargin{:});
            return;
        end

        next_plot = get(gca, 'NextPlot');
        hold on;

        vtx = obj.getWorldVtx();
        args = cat(2, obj.material.getDrawArgs(), varargin);

        % Draw faces
        obj.drawNumberedFaces(vtx, args);
        
        % Draw lines
        obj.drawEdges(vtx, args);
        
        set(gca, 'NextPlot', next_plot);
    end
    
    function new_obj = makeCopy(obj)
        new_obj = object.CrystalObj;
        new_obj.copyFrom(obj);
    end
    
    % ========== Other public methods ==========
    function enableFaceNumber(obj, s)
        obj.enable_face_number = s;
    end
end

% Protected methods
methods (Access = protected)
    % ========== Override methods ==========
    function copyFrom(obj, from_obj)
        obj.copyFrom@object.Patch(from_obj);
        obj.crystal = from_obj.crystal;
        obj.surf_xyz = from_obj.surf_xyz;
        obj.enable_face_number = from_obj.enable_face_number;
    end
    
    % ========== Other protected methods ==========
    function drawNumberedFaces(obj, ~, args)
        curr_fig = gcf;

        tex_background = 'w';
        tex_color = 'k';
        tex_scale = 0.8;
        for i = 1:2:length(args)
            if strcmpi(args{i}, 'FaceColor')
                tex_background = args{i+1};
            end
            if strcmpi(args{i}, 'NumberColor')
                tex_color = args{i+1};
            end
            if strcmpi(args{i}, 'NumberScale')
                tex_scale = args{i+1};
            end
        end
        
        t0 = obj.getWorldTransform();
        surf_args = object.Graphics3DObj.filterArgs(args, {'Color', 'FaceColor', 'NumberColor', 'NumberScale'}, ...
            {'^Line', '^Edge'});

        % Offscreen render prism faces
        max_tex_h = 300;
        max_tex_w = 1600;
        if obj.crystal.h / max_tex_h < 3 / max_tex_w
            prism_tex_size = floor([3, obj.crystal.h] / 3 * max_tex_w);
        else
            prism_tex_size = floor([3, obj.crystal.h] / obj.crystal.h * max_tex_h);
        end
        tex_digit_size = floor(min(prism_tex_size .* [0.8, 0.6] * tex_scale));
        tex_digit_args = {'FontName', 'Menlo', 'FontSize', tex_digit_size, ...
                'FontUnits', 'pixels', 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
                'Color', tex_color};
        offscreen_fig = figure('color', tex_background, 'visible', 'off', ...
            'position', [0, 0, prism_tex_size]);
        hold on;
        for i = 3:8
            text(i, 0, sprintf('%d', i), tex_digit_args{:});
        end
        set(gca, 'xlim', [2.5, 8.5], 'ylim', [-1, 1] * obj.crystal.h, 'position', [0, 0, 1, 1]);
        axis off;
        frame_data = getframe();
        prism_tex = frame_data.cdata;
        close(offscreen_fig);
        
        % Offscreen render basal faces 1
        basal_tex_size = floor([sqrt(3)/2, 1.5] * prism_tex_size(1) / 3);
        offscreen_fig = figure('color', tex_background, 'visible', 'off', ...
            'position', [0, 0, basal_tex_size]);
        text(0, 0, '1', tex_digit_args{:}, 'Rotation', -90);
        set(gca, 'xlim', [-1, 1] * sqrt(3)/2, 'ylim', [-1, 1], 'position', [0, 0, 1, 1]);
        axis off;
        frame_data = getframe();
        basal1_tex = frame_data.cdata;
        close(offscreen_fig);
        
        % Offscreen render basal faces 2
        offscreen_fig = figure('color', tex_background, 'visible', 'off', ...
            'position', [0, 0, basal_tex_size]);
        text(0, 0, '2', tex_digit_args{:}, 'Rotation', 90);
        set(gca, 'xlim', [-1, 1] * sqrt(3)/2, 'ylim', [-1, 1], 'position', [0, 0, 1, 1]);
        axis off;
        frame_data = getframe();
        basal2_tex = frame_data.cdata;
        close(offscreen_fig);

        figure(curr_fig);
        hold on;
        prism_xyz = reshape(t0.transform(obj.surf_xyz{3}), [2, 7, 3]);
        surf(prism_xyz(:, :, 1), prism_xyz(:, :, 2), prism_xyz(:, :, 3), surf_args{:}, ...
            'CData', prism_tex, 'FaceColor', 'texturemap', 'EdgeColor', 'none');
        
        basal_xyz = reshape(t0.transform(obj.surf_xyz{1}), [4, 3, 3]);
        surf(basal_xyz(:, :, 1), basal_xyz(:, :, 2), basal_xyz(:, :, 3), surf_args{:}, ...
            'CData', basal1_tex, 'FaceColor', 'texturemap', 'EdgeColor', 'none');
        
        basal_xyz = reshape(t0.transform(obj.surf_xyz{2}), [4, 3, 3]);
        surf(basal_xyz(:, :, 1), basal_xyz(:, :, 2), basal_xyz(:, :, 3), surf_args{:}, ...
            'CData', basal2_tex, 'FaceColor', 'texturemap', 'EdgeColor', 'none');
    end
end

properties
    crystal
    surf_xyz
    enable_face_number
end
end