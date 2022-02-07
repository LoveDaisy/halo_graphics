function obj = makePrismCrystal(varargin)
p = inputParser;
p.addOptional('h', 1, @(x) validateattributes(x, {'numeric'}, {'positive'}));
p.parse(varargin{:});

obj = object.Patch;
crystal = optics.make_prism_crystal(p.Results.h);
face_len = cellfun(@length, crystal.face);
faces = nan(length(face_len), max(face_len));
for i = 1:length(face_len)
    faces(i, 1:face_len(i)) = crystal.face{i};
end
obj.vtx = crystal.vtx;
obj.faces = faces;
end