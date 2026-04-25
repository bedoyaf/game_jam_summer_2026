@tool

extends MultiMeshInstance2D

func _ready():
	# 1. Get the size of the mesh we are instancing
	# This assumes you are using a QuadMesh as suggested
	var sprite_size = multimesh.mesh.size 
	
	var grid_size = 10
	
	for i in range(multimesh.instance_count):
		# 2. Calculate grid coordinates (column and row)
		var column = i % grid_size
		var row = i / grid_size
		
		# 3. Calculate position using the actual width and height
		# column * width = X position
		# row * height = Y position
		var x_pos = column * sprite_size.x
		var y_pos = row * sprite_size.y
		
		var pos = Transform2D(0, Vector2(x_pos, y_pos))
		
		# 4. Apply to the specific instance
		multimesh.set_instance_transform_2d(i, pos)
