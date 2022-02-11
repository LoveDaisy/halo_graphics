classdef Surface < object.Graphics3DObj
% Constructor
methods
    function obj = Surface(varargin)
        p = inputParser;
        p.addOptional('xx', [], @(x) isempty(x) || length(size(x)) == 2);
        p.addOptional('yy', [], @(x) isempty(x) || length(size(x)) == 2);
        p.addOptional('zz', [], @(x) isempty(x) || length(size(x)) == 2);
        p.parse(varargin{:});
        
        obj.vtx = [p.Results.xx(:), p.Results.yy(:), p.Results.zz(:)];
        obj.data_size = size(p.Results.zz);
    end
end

% Public methods
methods
    % ========== Override methods ==========
    function draw(obj, varargin)
        if isempty(obj.vtx)
            return;
        end

        vtx = obj.getWorldVtx();
        xx = reshape(vtx(:, 1), obj.data_size);
        yy = reshape(vtx(:, 2), obj.data_size);
        zz = reshape(vtx(:, 3), obj.data_size);
        
        args = cat(2, obj.material.getDrawArgs(), varargin);
        args = object.Graphics3DObj.filterArgs(args, {'Color'});
        surf(xx, yy, zz, args{:});
    end
    
    function new_obj = makeCopy(obj)
        new_obj = object.Surface;
        new_obj.copyFrom(obj);
    end
    
    % ========== Other public methods ==========
end

% Protected methods
methods (Access = protected)
    % ========== Override methods ==========
    function copyFrom(obj, from_obj)
        obj.copyFrom@object.Graphics3DObj(from_obj);
        obj.data_size = from_obj.data_size;
    end
    
    % ========== Other protected methods ==========
end

properties
    data_size = [];
end
end