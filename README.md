# Survival simulator prototype

This is a prototype survival simulator game made with Godot.
The goal of this project is to implement systems and mechanics inherent in most games in the survival/sandbox genre.

# Run
Godot version 4.2 is required to run the project.

# Features

## Terrain

The Terrain system is designed from scratch to achieve maximum flexibility and performance.
Terrain is based on a height map. The calculation of heights and normals takes place in the surface shader.
This makes it possible to change the shape of the terrain in real time.

The quality of the terrain mesh is calculated by a quadtree. It depends on the distance to the observer and can be adjusted.

![TerrainQuadtreePlayer](https://github.com/user-attachments/assets/d0378493-4b51-439d-88a6-d75a173b248a)

Terrain has an offset parameter that allows you to create a seamless sequence of several terrans. Since each of the terrains is processed separately, this can give a performance boost. Potentially, the size of the terrine is not limited.

## Vegetation

Quadtree optimization

![Octree](https://github.com/user-attachments/assets/c30b3f92-04fd-4280-971f-8d6c62ec3420)



![Demo480-2x](https://github.com/Soromytko/Survival-simulator-prototype/assets/98621939/a41801af-9273-4e8d-9793-c3ccef6cbf42)