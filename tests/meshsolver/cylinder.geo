
/*
Copyright 2020 National Technology & Engineering Solutions of Sandia, 
LLC (NTESS). Under the terms of Contract DE-NA0003525 with NTESS, the 
U.S. Government retains certain rights in this software.

This file is part of WecOptTool.

    WecOptTool is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    WecOptTool is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with WecOptTool.  If not, see <https://www.gnu.org/licenses/>.
*/

Mesh.Algorithm = 9;

lc = 0.125;
top = 0;

// Define in command line call (using -setnumber)
//bottom = -0.5;

Point(1) = {0,0,top,lc};
Point(2) = {1,0,top,lc};
Point(3) = {0,1,top,lc};
Point(4) = {-1,0,top,lc};

Point(6) = {0,0,bottom,lc};
Point(7) = {1,0,bottom,lc};
Point(8) = {0,1,bottom,lc};
Point(9) = {-1,0,bottom,lc};

Circle(1) = {2,1,3};
Circle(2) = {3,1,4};

Circle(5) = {7,6,8};
Circle(6) = {8,6,9};

Line(8) = {9, 7};
Line(9) = {2, 7};
Line(10) = {3, 8};
Line(11) = {4, 9};

Curve Loop(20) = {-1,9,5,-10};
Curve Loop(21) = {-2,10,6,-11};
Line Loop(24) = {-8,-6,-5};

Surface(30) = {20};
Surface(31) = {21};
Plane Surface(34) = {24};

Mesh 2;
RecombineMesh;
