classdef Patch < object.Graphics3DObj
% Constructor
methods
    function obj = Patch(varargin)
        p = inputParser;
        p.addOptional('vtx', [], @(x) isempty(x) || size(x, 2) == 3);
        p.addOptional('faces', [], @(x) isempty(x) || (iscell(x) && isvector(x)));
        p.parse(varargin{:});

        obj.vtx = p.Results.vtx;
        if isempty(p.Results.faces)
            obj.faces = 1:size(obj.vtx, 1);
        else
            face_len = cellfun(@length, p.Results.faces);
            faces = nan(length(face_len), max(face_len));
            for i = 1:size(faces, 1)
                faces(i, 1:face_len(i)) = p.Results.faces{i};
            end
            obj.faces = faces;
        end
    end
end

% Public methods
methods
    % ========== Override methods ==========
    function draw(obj, varargin)
        next_plot = get(gca, 'NextPlot');
        hold on;

        vtx = obj.getWorldVtx();
        args = cat(1, obj.draw_args(:), varargin(:));

        % Draw faces
        face_args = object.Graphics3DObj.filterArgs(args, {}, {'^Line', '^Edge'});
        patch('Faces', obj.faces, 'Vertices', vtx, 'EdgeColor', 'none', face_args{:});
        
        % Draw lines
        line_args = object.Graphics3DObj.keepArgs(args, {}, {'^Line', '^Edge'});
        for i = 1:length(line_args)
            if strcmpi(line_args{i}, 'EdgeColor')
                line_args{i} = 'Color';
            end
        end
        face_num = size(obj.faces, 1);
        vtx_num = size(obj.vtx, 1);
        edge_finish = false(vtx_num, vtx_num);
        for i = 1:face_num
            m = sum(~isnan(obj.faces(i, :)));
            for j = 1:m
                i1 = obj.faces(i, j);
                i2 = obj.faces(i, mod(j, m) + 1);
                if edge_finish(i1, i2)
                    continue;
                end
                v1 = vtx(i1, :);
                v2 = vtx(i2, :);
                plot3([v1(1), v2(1)], [v1(2), v2(2)], [v1(3), v2(3)], line_args{:});
                edge_finish(i1, i2) = true;
                edge_finish(i2, i1) = true;
            end
        end
        
        set(gca, 'NextPlot', next_plot);
    end
    
    function new_obj = makeCopy(obj)
        new_obj = object.Patch;
        new_obj.copyFrom(obj);
    end
    
    % ========== Other public methods ==========
    function n = getFaceNormal(obj, idx)
        face = obj.faces(idx, :);
        v1 = obj.vtx(face(2), :) - obj.vtx(face(1), :);
        v2 = obj.vtx(face(3), :) - obj.vtx(face(2), :);
        n = cross(v1, v2);
        n = n / norm(n);
    end
    
    function vtx = getFaceVertices(obj, idx)
        face = obj.faces(idx, :);
        vtx = obj.vtx(face(~isnan(face)), :);
    end

    function p = getPatch(obj, idx)
        p = object.Patch(obj.getFaceVertices(idx));
    end
end

% Protected methods
methods (Access = protected)
    % ========== Override methods ==========
    function copyFrom(obj, from_obj)
        obj.copyFrom@object.Graphics3DObj(from_obj);
        obj.faces = from_obj.faces;
    end
    
    % ========== Other protected methods ==========
end

properties
    faces = [];
end
end