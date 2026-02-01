shader_type canvas_item;

uniform vec4 background_color:source_color = vec4(1.0);
uniform vec4 line_color:source_color = vec4(0.0);
uniform vec4 shape_color:source_color = vec4(0.5);

uniform vec4 success_color:source_color = vec4(1.0,1.0,1.0,1.0);
uniform vec4 fail_color:source_color = vec4(1.0,1.0,1.0,1.0);
uniform vec4 soft_fail_color:source_color = vec4(1.0,1.0,1.0,1.0);

uniform sampler2D viewport_tex:source_color, filter_nearest;
uniform sampler2D actual_image:source_color, filter_nearest;

uniform float only_orig_image:hint_range(0.0,1.0,0.01) = 0.0;
uniform float only_interior_lines:hint_range(0.0,1.0,0.01) = 0.0;
uniform float only_ext_lines:hint_range(0.0,1.0,0.01) = 0.0;
uniform float only_non_filled_lines:hint_range(0.0,1.0,0.01) = 0.0;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {

	vec4 v_tex = texture(viewport_tex, UV);
	vec4 ai_tex = texture(actual_image, UV);
	
	float v_greyscale = v_tex.r + v_tex.g + v_tex.b / 3.0;
	vec4 final_color = vec4(0.0);
	final_color.a = 1.0;
	
	if (v_tex.b > 0.9 && v_tex.r < 1.0) {
		final_color.rgb = line_color.rgb;
	}

	if (v_tex.r > 0.9 && v_tex.b < 1.0) {
		final_color.rgb = shape_color.rgb;
	}
	
	if (v_tex.r > 0.9 && v_tex.b > 0.99) {
		final_color.rgb = background_color.rgb;
	}
	
	
	
	
	float avg_var = (only_interior_lines + only_ext_lines + only_non_filled_lines) / 3.0;
	if (only_orig_image > 0.0) {
		final_color = mix(final_color,vec4(1.0),only_orig_image);
	}
	
	if (only_interior_lines > 0.0) 
	{
		if (v_tex.b < 0.9 && ai_tex.r < 0.9) {
			final_color.rgb = mix(final_color.rgb,success_color.rgb,only_interior_lines);
		} else {
			final_color.rgb = vec3(1.0);
		}
	}
	
	if (only_ext_lines > 0.0) 
	{
		if (v_tex.b < 0.95 && ai_tex.r > 0.95) {
			final_color.rgb = mix(final_color.rgb,fail_color.rgb,only_ext_lines);
		} else {
			final_color.rgb = vec3(1.0);
		}
	}
	
	if (only_non_filled_lines > 0.0) {
		if (v_tex.r < 0.9) {
			final_color.rgb = mix(final_color.rgb,soft_fail_color.rgb,only_non_filled_lines);
		} else {
			final_color.rgb = vec3(1.0);
		}
	}

	COLOR = final_color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
