# Survival simulator prototype

This is a prototype survival simulator game made with Godot.
The goal of this project is to implement systems and mechanics inherent in most games in the survival/sandbox genre.

![Demo480-2x](https://github.com/Soromytko/Survival-simulator-prototype/assets/98621939/a41801af-9273-4e8d-9793-c3ccef6cbf42)

# Run
Godot version 4.2 is required to run the project.

# Features

## Open world

### Terrain

The Terrain system is designed from scratch to achieve maximum flexibility and performance.
Terrain is based on a height map. The calculation of heights and normals takes place in the surface shader.
This makes it possible to change the shape of the terrain in real time.
The quality of the mesh depends on the distance to the observer and can be adjusted.
Terran has a global offset, which allows a large terrain to be divided into smaller parts, each of which is optimized separately.
Potentially, the size of the terrine is not limited.

### Vegetation

Quadtree optimization

