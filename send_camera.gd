extends Spatial

onready var TheCamera := $SoldierPosition/CameraOffset
onready var TheProjection := $SoldierPosition/ViewConeDisplay
onready var TheFullscreenQuad := $SoldierViewport/SoldierCamera/FullscreenQuad

var _projection_material = null


func _ready() -> void:
	if TheProjection.is_inside_tree() :
		# grab the material being used on the projection surface
		_projection_material = TheProjection.get_surface_material(0)
	
	# also, make the fullscreen quad visible on play
	TheFullscreenQuad.visible = true


func _process(_delta: float) -> void:
	var _cam_xform = TheCamera.global_transform.inverse()
	if _projection_material :
		# send the camera inverse transform to the projection shader
		_projection_material.set_shader_param("DepthCamXForm", _cam_xform)

