function output_structure = Weiszfeld(input_structure)
%
% This function numerically calculates the geometric mean of a
% N-Dimensional set of points using the Wieszfeld's algorithm
%
% INPUT: Structure
% -- [REQUIRED] input_strucuture.Data = Input data matrix. Each row is a point, each
% column a dimension
% -- input_structure.RelTol = Relative tolerance for stopping the search.
% Default: 0.001
% -- input_structure.x0 = A vector with the initial point. If not provided,
% it is automatically calcualted based on the centroid of the original
% series of points


%% Default values
RelTolDefault = 0.001 ;
expectedIterations = 300 ;

%% Reading inputs
% Reading the data matrix 
data = input_structure.Data ;
% Check if the RelTol field is provided. Otherwise, use the default value
if any(strcmp(fields(input_structure),'RelTol'))
    relTol = input_structure.RelTol ;
else
    relTol = RelTolDefault ;
end
% Check if a starting point is provided. Otherwise, calculate it
if any(strcmp(fields(input_structure),'x0'))
    x0 = input_structure.x0 ;
else
    x0 = mean(data,1) ;
end

%% Calculating some useful parameters
[nPoints, nDimensions] = size(data) ;

% Initialize the relative difference
eps = 1 ;
counter = 0 ;
% Initialize the matrix storing all iterations. 
xTemp = NaN([expectedIterations , nDimensions]) ;
xTemp(1,:) = x0 ;
%% Iterations
while eps > relTol
    counter = counter + 1 ;
    weights = sum((data - xTemp(counter,:)).^2, 2).^-0.5 ;
    temp = sum(data .* (weights .* ones(nPoints, nDimensions)), 1) / sum(weights) ;
    xTemp(counter+1, :) = temp ;
    eps = (sum((xTemp(counter+1,:) - xTemp(counter,:)).^2))^0.5 ;
end

%% Post compute
% Compute the difference at the last computation
err = sum(sum((data - xTemp(counter+1,:)).^2,2).^0.5) / nPoints;

output_structure.xMedian = xTemp(counter+1,:) ;
output_structure.err = err ;
output_strucutre.tol = eps ;

end
