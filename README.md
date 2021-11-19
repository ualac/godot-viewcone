# godot-viewcone
basic godot project implementing a commandos-like viewcone effect

## notes

The SoldierViewport is used to render a soldier PoV depth buffer. Note: the viewport is setup with HDR and Keep 3D Linear enabled to ensure the depth value is stored as-is. This depth buffer is then passed into the main viewcone projection shader which uses it to test visibility. It does this by converting it's fragment into the soldier's camera space and testing it against the depth buffer value. 
