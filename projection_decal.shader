shader_type spatial;
render_mode world_vertex_coords, unshaded;

uniform sampler2D DepthTexture;
uniform mat4 DepthCamXForm;
uniform float ViewConeAngle = 60.0;
uniform float ViewDistance = 8.0;

// from godotshaders.org decal example
// Credit: https://stackoverflow.com/questions/32227283/getting-world-position-from-depth-buffer-value
vec3 world_pos_from_depth(float depth, vec2 screen_uv, mat4 inverse_proj, mat4 inverse_view) {
	float z = depth * 2.0 - 1.0;
	
	vec4 clipSpacePosition = vec4(screen_uv * 2.0 - 1.0, z, 1.0);
	vec4 viewSpacePosition = inverse_proj * clipSpacePosition;
	
	viewSpacePosition /= viewSpacePosition.w;
	
	vec4 worldSpacePosition = inverse_view * viewSpacePosition;
	
	return worldSpacePosition.xyz;
}



void fragment() {
	
	// from godotshaders.org decal example
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	vec3 world_pos = world_pos_from_depth(depth, SCREEN_UV, INV_PROJECTION_MATRIX, (CAMERA_MATRIX));

	// point in world space
	vec4 P_world = vec4(world_pos, 1);
	// move the world point vertically to limit bias issues
	P_world.y += 0.02;
	
	// skip shading surfaces that are vertical (based on Y derivative)
	if (dot(normalize(dFdy(P_world.xyz)), vec3(0,1,0)) > 0.45) {
		discard;
	}
	
	// convert point into soldier camera space
	vec4 P_depth = DepthCamXForm * P_world;
	
	// we can bail out early if the point is behind the camera	
	if (P_depth.z > 0.0) {
		discard;
	}
	
	// reverse the depth so it increases as we move away from the camera
	P_depth.z *= -1.0;
	
	// this is the distance for our currently shaded fragment
	float P_dist = P_depth.z;
	
	// generate ndc coordinates from our point, essentially applying
	// the projection matrix. 
	// INFO: this leverages the fact we are rendering the
	// depth image into a square viewport with a 90deg FOV camera.
	// therefore xy in ndc space is simply proportional to the 
	// depth of the point.  
	float ndc_x = P_depth.x / P_depth.z;
	float ndc_y = P_depth.y / P_depth.z;
	
	// again we can early-out if the ndc point would be outside
	// of the ndc view frustum
	if (abs(ndc_x) > 1.0) {
		discard;
	}
	if (abs(ndc_y) > 1.0) {
		discard;
	}	
	
	// test the viewcone angle 
	float P_angle = acos(dot(normalize(vec3(ndc_x, ndc_y, 1.0)), vec3(0,0,1)));
	float angular_limit = smoothstep( radians(ViewConeAngle/2.0), radians((ViewConeAngle-5.0)/2.0), P_angle );
	if (angular_limit < 0.0001) {
		discard;
	} 
	
	// test the viewcone max distance with some falloff
	float dist_limit = smoothstep( ViewDistance, ViewDistance*0.8, length(P_depth) );
	if (dist_limit < 0.0001) {
		discard;
	} 	
		
	
	// convert the ndc coords into a screen coord system (0..1)
	vec2 depth_uv = vec2( ndc_x, ndc_y );
	depth_uv *= 0.5;
	depth_uv += 0.5;
	
	// sample the depth texture using this uv coordinate
	float depth_tex_value = texture( DepthTexture, depth_uv ).r;
	
	// compare the depth texture value against the computed depth of this fragment.
	float vis = P_dist <= depth_tex_value ? 1.0 : 0.0;
	
	// compute some stripes
	float stripeA = smoothstep(0.45,0.5, mod(length(P_depth), 0.1)*10.0);
	float stripeB = smoothstep(1,0.95, mod(length(P_depth), 0.1)*10.0);
	float stripe = min(stripeA, stripeB);
	
	ALBEDO = vec3(vis, 0, 0);
	ALBEDO *= stripe;
	
	// set an alpha value to fade the view cone
	ALPHA = 0.5 * angular_limit * dist_limit * stripe;
}

