shader_type spatial;
render_mode unshaded;


void vertex() 
{
	// expand the quad to full the view
  	POSITION = vec4(VERTEX, 1.0);
}


void fragment() 
{
	// read the value from the DEPTH_TEXTURE buffer
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	// ndc is the coordinates of the sample in the view frustum
	// NOTE: the view frustum is a unit cube and has no perspective
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	// linear depth is just the distance into the screen (ie. negative Z axis)
	float linear_depth = -view.z;
	// output this as the fragment color
	// IMPORTANT: 
	// the viewport this is rendering into _must_ be set to 3D, and have
	// HDR and Kepp 3D Linear activated, otherwise the buffer will have
	// an sRGB conversion applied to it's values.
	ALBEDO = vec3(linear_depth);
}
