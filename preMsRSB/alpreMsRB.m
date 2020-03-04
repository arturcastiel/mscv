function [ coarseElemCenter, coarse_interface_center, coarse_strips, boundRegion, bcoarse_strips] = alpreMsRB(npar,coarseneigh, centelem, ...
 coarseelem,coarseblockcenter,exinterface,exinterfaceaxes, multiCC)    
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%finding neighbors 
global intCoord elem coord inedge bedge esurn1 esurn2 elemloc edgesOnCoarseBoundary intinterface



coarseElemCenter = zeros(npar,1);
tol = 10^-4;
struct.RelTol = tol;

%% recalculate centers
    for ii = 1:npar
        ref = elemloc == ii;
        center_point = weiszfeld(centelem(ref,1:2));
        ref(ref) = minDis(center_point , centelem(ref,1:2));
        coarseElemCenter(ii) = find(ref);
    end
    
    

    

%% finding edge that represents the interface between two coarse volumes
    ref = intCoord(:, 3) == 2;
    points = intCoord(ref, 1:2);
    coarse_interface_center = zeros(size(points, 1), 1);
    p1 = coord(inedge(edgesOnCoarseBoundary,1),1:2);
    p2 = coord(inedge(edgesOnCoarseBoundary,1),1:2);
    edge_center_point = (p1+p2)./2;
    for ii = 1:size(points, 1)
       edge_ref =  minDis(points(ii,:), edge_center_point);
       coarse_interface_center(ii) = edgesOnCoarseBoundary(edge_ref);
    end
    
%% creating the coarse path connecting two coarse volumes
    coarse_element_bridge = elemloc(inedge(coarse_interface_center,3:4));
    coarse_element_target = inedge(coarse_interface_center,3:4);
    
    
%% moving centers to comply with lorens bc    
    bcflag = true;
    
    if bcflag == 1
        % moving center of coarse volumes
        for ii = 1:npar
           int_sum = sum(coarseneigh(ii,end-3:end));
           if int_sum == 1
               ref = (intCoord(:,3) == 3) & (intCoord(:,4) == ii);
               point = intCoord(ref,1:2);
               cref = elemloc == ii;
               cref(cref) = minDis(point, centelem(cref,1:2));
               coarseElemCenter(ii) = find(cref);               
           elseif int_sum ==2
               ref = (intCoord(:,3) == 4) & (intCoord(:,4) == ii);
               point = intCoord(ref,1:2);
               cref = elemloc == ii;
               cref(cref) = minDis(point, centelem(cref,1:2));
               coarseElemCenter(ii) = find(cref);               
           end  
        end
        % moving center of interfces
        all_boundary_nodes = unique(bedge(:,1:2));
        bcoarse = any(coarseneigh(:,end-3:end),2);
        bEdges = any(ismember(inedge(edgesOnCoarseBoundary,1:2),all_boundary_nodes),2);
        for ii = 1:size(coarse_element_bridge,1)
           flag = all(bcoarse(coarse_element_bridge(ii,:)));
           if flag == 1
              left =  coarse_element_bridge(ii,1);
              right =  coarse_element_bridge(ii,2);
              %ref1 = all(ismember(elemloc(inedge(edgesOnCoarseBoundary,3:4)),[left,right]),2);
              aux = elemloc(inedge(edgesOnCoarseBoundary,3:4));
              ref1 = (aux(:,1) == left) & (aux(:,2) == right);
              ref2 = (aux(:,2) == left) & (aux(:,1) == right);
              ref = (ref1 | ref2) &  bEdges;
              if sum(ref) ~= 0
                  if all(elemloc(inedge(edgesOnCoarseBoundary(ref),3:4)) == coarse_element_bridge(ii,:)) == 1
                      coarse_element_target(ii,:) = inedge(edgesOnCoarseBoundary(ref),3:4);
                  else
                      coarse_element_target(ii,1) = inedge(edgesOnCoarseBoundary(ref),4);
                      coarse_element_target(ii,2) = inedge(edgesOnCoarseBoundary(ref),3);
                  end
              end
              
           end
         
            
        end
        
        
    end    

%% creat coarse path center-nodes boundary for those coarse cells located on the boundaries of the physical domain
    boundaryTarget = zeros(npar,2);
    numBoundary = sum(coarseneigh(:,end-3:end), 2);
    for ii = 1:npar
        if numBoundary(ii) == 1
            edges_ref = exinterface{ii};
            edge_nodes = bedge(edges_ref,1:2);
            center_bedges =  0.5*(coord(edge_nodes(:,1),1:2) + coord(edge_nodes(:,2),1:2));
            average_point = mean(center_bedges);
            target_edge = minDis(average_point, center_bedges);
            boundaryTarget(ii,1) = bedge(edges_ref(target_edge),3);     
        elseif numBoundary(ii) == 2
            ref =  find(coarseneigh(ii,end-3:end));
            edge_ref1 = exinterfaceaxes{ii,ref(1)};
            edge_ref2 = exinterfaceaxes{ii,ref(2)};
            edge_nodes1 = bedge(edge_ref1,1:2);
            edge_nodes2 = bedge(edge_ref2,1:2);
            center_bedges1 =  0.5*(coord(edge_nodes1(:,1),1:2) + coord(edge_nodes1(:,2),1:2));
            average_point1 = mean(center_bedges1);
            center_bedges2 =  0.5*(coord(edge_nodes2(:,1),1:2) + coord(edge_nodes2(:,2),1:2));
            average_point2 = mean(center_bedges2);            
            target_edge1 = minDis(average_point1, center_bedges1);
            target_edge2 = minDis(average_point2, center_bedges2);
            boundaryTarget(ii,:) = [bedge(edge_ref1(target_edge1),3) , bedge(edge_ref2(target_edge2),3)];     
    
            
        end
            
        
    end
    

    
%% creating the mesh graph
    P1 = centelem(inedge(:, 3),1:2);
    P2 = centelem(inedge(:, 4),1:2);
    dist = vecnorm(P2-P1, 2, 2) ;
    dist(:) = 1;
    G = graph(inedge(:,3),inedge(:,4), dist);
    %G = graph(inedge(:,3),inedge(:,4));
    
%% finding the shortest path
    coarse_strips = cell(size(coarse_element_bridge,1),1);
    
    for ii = 1:size(coarse_strips,1)
        center1 = coarseElemCenter(coarse_element_bridge(ii,1));
        target1 = coarse_element_target(ii,1);
        center2 = coarseElemCenter(coarse_element_bridge(ii,2));
        target2 = coarse_element_target(ii,2);        
        strip = union(shortestpath(G,center1,target1), shortestpath(G,center2,target2));
        strip = setdiff(strip, [center1,center2]);
        coarse_strips{ii} = strip;
    end
  
%% finding the shortest path for boundary elements
    bcoarse_strips = cell(npar,2);
    for ii = 1:npar
        center = coarseElemCenter(ii);
        strip = [];
        if  numBoundary(ii) == 1
           target1 = boundaryTarget(ii,1);
           strip1 = shortestpath(G,center,target1);
           strip1 = setdiff(strip1, center1);
           strip = [strip1];
           bcoarse_strips{ii,1} = strip;
        elseif  numBoundary(ii) == 2
           target1 = boundaryTarget(ii,1);
           target2 = boundaryTarget(ii,2);
           strip1 = shortestpath(G,center,target1);
           strip2 = shortestpath(G,center,target2);
           strip1 = setdiff(strip1, center);
           strip2 = setdiff(strip2, center);
           bcoarse_strips{ii,1} = strip1;
           bcoarse_strips{ii,2} = strip2;
        end
                  
    end

    
 %% finding boundary regions
    boundRegion = cell(npar,1);
    coarse_brige =sort(coarse_element_bridge,2);
    for ii=1:npar
        celsur = find(coarseneigh(ii,1:npar));
        cnpar = [];
        for jj = celsur
            celsur_local = intersect(celsur, find(coarseneigh(jj,1:npar)));
            celsur_local_boundary =  coarseneigh(celsur_local, end-3:end);

            all_par = sort([jj * ones(size(celsur_local))' , celsur_local'], 2);
            cnpar = unique([cnpar; all_par], 'rows');
            for ff = 1:size(celsur_local_boundary,1)
                if sum(celsur_local_boundary(ff,:)) == 1
                     boundRegion{ii} =  unique([boundRegion{ii}, bcoarse_strips{celsur_local(ff),1}]);
                elseif sum(celsur_local_boundary(ff,:)) == 2
                    c1 = bcoarse_strips{celsur_local(ff),1};
                    c1 = centelem(c1 ,1:2);
                    c2 = bcoarse_strips{celsur_local(ff),2};
                    c2 = centelem(c2, 1:2);
                    if sum(coarseneigh(ii,end-3:end)) == 1
                        ref = (intCoord(:,3) == 3) &  (intCoord(:,4) == ii);
                        center = intCoord(ref,1:2);
                    else
                        center = centelem(coarseElemCenter(ii),1:end-1); 
                    end
                    repcenter1 = repmat(center, size(c1,1),1);
                    repcenter2 = repmat(center, size(c2,1),1);
                    dis1 = mean(vecnorm(repcenter1 - c1,2,2));
                    dis2 = mean(vecnorm(repcenter2 - c2,2,2));
                    if dis1 < dis2
                        boundRegion{ii} =  unique([boundRegion{ii}, bcoarse_strips{celsur_local(ff),1}]);
                    else
                        boundRegion{ii} =  unique([boundRegion{ii}, bcoarse_strips{celsur_local(ff),2}]);
                    end
                    
                end
            end
            
        end
            
        for jj = 1:size(cnpar,1)
            ref = ismember(coarse_brige, cnpar(jj,:), 'rows');
            boundRegion{ii} = unique([boundRegion{ii}, coarse_strips{ref}]);
%             if sum(celsur_local_boundary) == 1
%                  boundRegion{ii} =  unique([boundRegion{ii}, bcoarse_strips{jj}]);
%             end
            
            
        end
    end
%     if bcflag == 0
%          for ii =1:npar
%              boundRegion{ii} = union(boundRegion{ii},  bcoarse_strips{ii})';             
%          
%          end
%     end
%% Creating inRegion

intRegion = cell(npar,1);
%createPolygon(boundRegion{5}, coarseElemCenter')

% for ii = find(sum(coarseneigh(:,1:end-4)) >= 1)
%     createPolygon(boundRegion{ii}, coarseElemCenter')
% end

createPolygon(boundRegion{6}, coarseElemCenter')

% createPolygon(boundRegion{2}, coarseElemCenter')
%createPolygon(boundRegion{5}, find(coarseneigh(5,1:end-4)))

    
end


function [path] = createPolygon(vol, neighbor_centers)
    global inedge centelem strips
    all_vols = unique([vol, neighbor_centers]);
    ref = all(ismember(inedge(:,3:4), all_vols),2);
    
    g1 = inedge(ref,3);
    g2 = inedge(ref,4);
    pos = unique([g1,g2]) 
    target = 1:size(pos,1)
    transvec = zeros(size(centelem,1),1);
    transvec(pos) = target;
    
    transback = pos;
    
    G = graph(transvec(g1),transvec(g2));
    graphType = classifyGraph(G);
    count_adj = sum(G.adjacency,2);
    if graphType == 1
        ref = find((count_adj == 1));
        path =  shortestpath(G,ref(1), ref(2));
    elseif graphType == 2
     
        
       circleStrip(G)
    elseif graphType == 3
        3
    elseif graphType == 4
        4
    elseif graphType == 5
        findCircleStrip(G)
    else
        6
    end
    figure
    strips{1} = transback(strips{1});
    strips{2} = transback(strips{2});

    
    plot(G)
    title(['Type Graph: ', num2str(graphType)])

end


function [out] = findCircleStrip(G)
    global strips
    nadj = sum(G.adjacency,2);
    ref3 = find(nadj == 3);
    ref2 = find(nadj == 2);
    ref1 = find(nadj == 1);
    
    strips = cell(size(ref1,1),1) ;
    
    for ii = 1:size(ref1,1)
        for jj = 1:size(ref1,1)
            path = shortestpath(G, ref1(ii),ref3(jj));
            if (size(path,2) <= size(strips{ii,1})) | (jj == 1)
                strips{ii,1} = path;
            end
        end
    end
    out = strips
    
    remove_nodes = setdiff(strips{2}, ref3);
    F = rmnode(G, remove_nodes)
   
end


function [path] = circleStrip(G)
    tedge = G.Edges(1,:);
    tedge = tedge{:,:};
    G = rmedge(G,tedge(1),tedge(2));
    path =  shortestpath(G,tedge(1), tedge(2));
end


function[flag] = classifyGraph(G)
    edges_count = full(sum(G.adjacency,2));
    [a,b]= hist(edges_count,unique(edges_count));
    n = size(G.Nodes,1);
    n1 = 0;
    n2 = 0;
    n3 = 0;
    n4 = 0;
    for ii = 1:size(b,1)
        if b(ii) == 1
            n1 = a(ii); 
        elseif b(ii) == 2
            n2 = a(ii);
        elseif b(ii) == 3
            n3 = a(ii);
        else
            n4 = b(ii);
        end
    end
        
    if (n1 == 2) && (n2 == (n-2)) && (n3 == 0)  && (n4 == 0)
    % linear graph
        flag = 1;
    elseif  (n1 == 0) && (n2 == n) && (n3 == 0)  && (n4 == 0) 
    % circular graph
        flag = 2;
    elseif (n1 == 3) && (n2 == (n-4)) && (n3 == 1)  && (n4 == 0) 
    % strip + linear
        flag = 3;
    elseif (n1 == 1) && (n2 == (n-2)) && (n3 == 1)  && (n4 == 0) 
    % circular + strip
        flag = 4;
    elseif (n3 == n1) &&  (n2 ==  (n - 2*n1))
    % raise error    
        flag = 5;
    else
        flag = 6;
    end

end

function [out] = minDis(center, points)
    mcenter = repelem(center, size(points,1),1);
    dists = vecnorm(mcenter - points, 2,2);
    ref = dists == min(dists);
    if sum(ref) == 1
        out = ref;
    else        
        pref = false(size(ref,1),1);
        target = find(ref);
        pref(target(1)) = true;
        out = pref;
    end
end