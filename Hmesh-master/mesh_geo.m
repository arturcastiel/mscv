function mesh_geo(image,fname,mref,width,height,subdomain,meshalg)
% MESH_GEO Peforms image-based meshing of a binary medium and creates the
%          .geo file for use in Gmsh.
%
%   Usage:
%   -----------------------------------------------------------------------
%   mesh_geo(image,fname,mref,width,height,subdomain)
%
%   Input Arguments:
%   -----------------------------------------------------------------------
%   image       graphics file of domain    
%   fname       filename to use for .geo file
%   mref        mesh refinement parameter
%   width       width of domain0
%   height      height of domain
%   subdomain   A string specifying which part of the domain to mesh
%                - 'AB' full domain
%                - 'A'  connected subdomain only
%                - 'B'  inclusion subdomain only
%   meshalg     mesh algorithm to use in Gmsh: 'MeshAdapt', 'Delaunay', or
%               'Frontal'
%
%   This code is part of Hmesh.
%   Copyright (c) 2015, Elliot Carr.

switch meshalg
    case 'MeshAdapt'
        ma = 1;
    case 'Delaunay'
        ma = 5;
    case 'Frontal'
        ma = 6;
    otherwise
        error(['Mesh algorithm must be one of either ''MeshAdapt'',' ...
            '''Frontal'' or ''Delaunay''.']);
end

% Convert to a binary image
I = imread(image); BW = im2bw(I,graythresh(I));

% Identify the coordinates of the boundary pixels of the inclusions
B = bwboundaries(BW); 
[m,n] = size(BW); 
p = length(B)-1; % Number of inclusions
x = cell(p,1); 
y = x;
for k = 1:p, 
    x{k} = width*(B{k+1}(:,2))/m; 
    y{k} = height*(n-B{k+1}(:,1))/n; 
end

%--------------------------------------------------------------------------
% Generate gmsh .geo file
fid = fopen([fname,'.geo'], 'w');
fprintf(fid,'Mesh.Algorithm = %g;\n',ma);
fprintf(fid,'Point(1) = {0,0,0,%g};\n',mref);
fprintf(fid,'Point(2) = {%g,0,0,%g};\n',width,mref);
fprintf(fid,'Point(3) = {%g,%g,0,%g};\n',width,height,mref);
fprintf(fid,'Point(4) = {0,%g,0,%g};\n',height,mref);
fprintf(fid,'Line(1)  = {1,2};\n');
fprintf(fid,'Line(2)  = {2,3};\n');
fprintf(fid,'Line(3)  = {3,4};\n');
fprintf(fid,'Line(4)  = {4,1};\n');

pts = 4;
for k = 1:p
    spt = pts+1;
    for i = 1:length(x{k})
        pts=pts+1; 
        fprintf(fid,'Point(%i) = {%g,%g,0,%g};\n',pts,x{k}(i),y{k}(i),mref);
    end
    ept = pts; 
    fprintf(fid,'BSpline(%i) = {',k+4);
    for i = ept:-1:spt
        fprintf(fid,'%i, ',i); 
    end
    fprintf(fid,'%i};\n',ept);
end
fprintf(fid,'Line Loop(1) = {1,2,3,4};\n');

% Sub-domain B (inclusions)
for k = 1:p
    fprintf(fid,'Line Loop(%i) = {%i};\n',k+1,k+4); 
end
for k = 1:p
    fprintf(fid,'Plane Surface(%i) = {%i};\n',k+1,k+1);
end

% Sub-domain A (connnected)
if strcmp(subdomain,'AB') || strcmp(subdomain,'A') 
    fprintf(fid,'Plane Surface(1) = {1'); 
    for k = 1:p
        fprintf(fid,', %i', k+1); 
    end
    fprintf(fid,'};\n');
end

% Interface edges between two sub-domains
fprintf(fid,'Physical Line(99) = {5'); 
for k = 2:p
    fprintf(fid,', %i', k+4);
end
fprintf(fid,'};\n');

% Build periodic array of cells
fprintf(fid,'Physical Surface(1) = {1};\n');
if strcmp(subdomain,'AB') || strcmp(subdomain,'B')
    fprintf(fid,'Physical Surface(2) = {2');
    for k = 2:p, 
        fprintf(fid,', %i', k+1); 
    end
    fprintf(fid,'};\n');
end
fclose(fid);
