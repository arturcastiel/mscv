cl__1 = 1e+22;
Point(1) = {0, 0, 0, 1e+22};
Point(2) = {1, 0, 0, 1e+22};
Point(3) = {1, 1, 0, 1e+22};
Point(4) = {0, 1, 0, 1e+22};

Point(5) = {0.5, 0.5, 0, 1e+22};

Point(6) = {0.8, 0.8, 0, 1e+22};
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};
Line(5) = {5, 6};



Line Loop(1) = {1, 2, 3, 4};
Plane Surface(1) = {1};
Line{5} In Surface {1};

Physical Point(201) = {1, 2, 3, 4};
Physical Line(201) = {1, 2, 3, 4};
Physical Line(202) = {5};

Physical Surface(1) = {1};

