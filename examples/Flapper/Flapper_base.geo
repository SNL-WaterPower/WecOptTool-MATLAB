//+
SetFactory("OpenCASCADE");

Mesh.Algorithm = 6; // 1: MeshAdapt, 2: Automatic, 5: Delaunay, 6: Frontal-Delaunay, 7: BAMG, 8: Frontal-Delaunay for Quads, 9: Packing of Parallelograms (default 6)
//Mesh.CharacteristicLengthMin = 0.1;
//Mesh.CharacteristicLengthMax = 0.1;


width = 5;
thick = 1;
height = 6;
depth = 10;

Box(1) = {-1*width/2, -1*thick/2, -1*depth, width, thick, height};
