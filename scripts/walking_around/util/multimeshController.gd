@tool

extends MultiMeshInstance2D

func _ready():
	var spacing = 128 # Change this to your sprite width
	var grid_size = 10
	
	for i in range(multimesh.instance_count):
		# Calculate x and y coordinates for a 10x10 grid
		var x = i % grid_size
		var y = i / grid_size
		
		# Create a transform for the position
		var pos = Transform2D(0, Vector2(x * spacing, y * spacing))
		
		# Set the instance's position
		multimesh.set_instance_transform_2d(i, pos)
