function mesh = read_msh(fname)
% MESH_GEO Reads the .msh file created by Gmsh.
%
%   Usage:
%   -----------------------------------------------------------------------
%   mesh = read_msh(fname)
%
%   Input Arguments:
%   -----------------------------------------------------------------------       
%   fname  filename of .msh file
%
%   Output Arguments:
%   -----------------------------------------------------------------------       
%   mesh  A structure containing the mesh properties with fields:
%          - no_nodes     number of nodes in mesh
%          - no_elements  number of elements in mesh
%          - nodes        an no_nodes-by-2 array containing the x and y 
%                         coordinates of the nodes. nodes(i,1:2) give the x
%                         and y coordinates of node i.
%          - elements     an no_elements-by-3 array containing the
%                         triangular element vertices. elements(i,1:3)
%                         gives the vertices of element i.
%          - subdomain    an no_elements-by-1 array specifying which
%                         sub-domain the elements are located. subdomain(i)
%                         = 1 means that element i is located in the
%                         connected sub-domain. subdomain(i) = 2 means that
%                         element i is located in the inclusion sub-domain.
%
%   This code is part of Hmesh.
%   Copyright (c) 2015, Elliot Carr.

% Read gmsh .msh file
fid = fopen([fname,'.msh'], 'r');
while 1
    tline = fgetl(fid);
    if ~ischar(tline)
        break
    end
    switch tline
        case '$MeshFormat'
            tline = fgetl(fid);
            if ~ischar(tline), break, end
            tline = fgetl(fid);
            if ~ischar(tline) || ~strcmp(tline,'$EndMeshFormat')
                break
            end
        case '$Nodes'
            tline = fgetl(fid);
            no_nodes = sscanf(tline,'%g');            
            nodes = zeros(no_nodes,2);            
            for i = 1:no_nodes
                tline = fgetl(fid);
                type = sscanf(tline,'%g %g %g %g');
                nodes(i,1:2) = type(2:3);
            end            
            tline = fgetl(fid);
            if ~ischar(tline) || ~strcmp(tline,'$EndNodes')
                break
            end            
        case '$Elements'
            tline = fgetl(fid);
            if ~ischar(tline)
                break
            end
            no_elements = 0;
            no_objects  = sscanf(tline,'%g'); elements = []; 
            subdomain = []; %ifnodes = []; ifedges = []; no_ifedges = 0; 
            for i = 1:no_objects
                tline = fgetl(fid);
                type=sscanf(tline,'%g %g %g %g %g %g %g %g')';
                if type(2)==2
                    no_elements = no_elements+1;
                    elements(no_elements,1:3) = type(6:8);
                    subdomain(no_elements,1) = type(4);
                end
                %if type(4) == 99
                %    no_ifedges = no_ifedges + 1;
                %    ifnodes = union(ifnodes, type(6:7));
                %    ifedges(no_ifedges,1:3) = [type(6:7),-1];
                %end
            end
            tline = fgetl(fid);
            if ~ischar(tline) || ~strcmp(tline,'$EndElements')
                break
            end
        otherwise
            disp('Unknown type encountered...')
            break
    end
    
end
fclose(fid);

mesh.no_nodes    = no_nodes;
mesh.no_elements = no_elements;
mesh.nodes       = nodes;
mesh.elements    = elements;
mesh.subdomain   = subdomain;