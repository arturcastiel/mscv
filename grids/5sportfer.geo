cl__1 = 1e+22;
Point(1) = {0, 0, 0, 1e+22};
Point(2) = {1, 0, 0, 1e+22};
Point(3) = {1, 1, 0, 1e+22};
Point(4) = {0, 1, 0, 1e+22};
Point(5) = {0.375, 0.375, 0, 1e+22};
Point(6) = {0.625, 0.375, 0, 1e+22};
Point(7) = {0.625, 0.625, 0, 1e+22};
Point(8) = {0.375, 0.625, 0, 1e+22};
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};
Line(5) = {5, 6};
Line(6) = {6, 7};
Line(7) = {7, 8};
Line(8) = {8, 5};
Line Loop(1) = {1, 2, 3, 4, -8, -7, -6, -5};
Plane Surface(1) = {1};
Line Loop(2) = {5, 6, 7, 8};
Plane Surface(2) = {2};
Line {5} In Surface {2};
Line {6} In Surface {2};
Line {7} In Surface {2};
Line {8} In Surface {2};
Physical Point(101) = {1, 2, 3, 4};
Physical Line(101) = {1, 2, 3, 4};
Physical Surface(1) = {1};
Physical Surface(2) = {2};
