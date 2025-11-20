shader_type canvas_item;

uniform vec2 node2d_scale;
uniform vec4 border_color = vec4(0.4, 0.7, 0.9, 0.9);
uniform vec4 field_background_color = vec4(0.2,0.2,0.6,0.2);
uniform vec4 field_primary_color = vec4(0.1, 0.7, 1.0, 1.0);
uniform vec4 field_secondary_color = vec4(0.2, 0.5, 1.0, 1.0);

const int pixelation = 100;

float border(vec2 uv, float border_width) {
	vec2 bottom_left = step(vec2(border_width/node2d_scale), uv);
	vec2 top_right = step(vec2(border_width/node2d_scale), 1.0 - uv);
	return bottom_left.x * bottom_left.y * top_right.x * top_right.y;
}

vec2 random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
			   dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

vec3 random(vec3 uvt){
    uvt = vec3( dot(uvt, vec3(127.1,311.7,478.3) ),
				dot(uvt, vec3(433.1,126.4,324.8) ),
				dot(uvt, vec3(269.5,183.3,128.3) ) );
    return -1.0 + 2.0 * fract(sin(uvt) * 43758.5453123);
}

float noise(vec2 uv) {
	vec2 uv_index = floor(uv);
	vec2 uv_fract = fract(uv);

	vec2 blur = smoothstep(0.0, 1.0, uv_fract);

	return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
					 dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
				mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
					 dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) + 0.5;
}

float noise2(vec3 uvt) {
	vec3 uv_index = floor(uvt);
	vec3 uv_fract = fract(uvt);

	vec3 blur = smoothstep(0.0, 1.0, uv_fract);

	// 8 corner contributions of the unit cube
	float n000 = dot(random(uv_index + vec3(0.0, 0.0, 0.0)), uv_fract - vec3(0.0, 0.0, 0.0));
	float n100 = dot(random(uv_index + vec3(1.0, 0.0, 0.0)), uv_fract - vec3(1.0, 0.0, 0.0));
	float n010 = dot(random(uv_index + vec3(0.0, 1.0, 0.0)), uv_fract - vec3(0.0, 1.0, 0.0));
	float n110 = dot(random(uv_index + vec3(1.0, 1.0, 0.0)), uv_fract - vec3(1.0, 1.0, 0.0));

	float n001 = dot(random(uv_index + vec3(0.0, 0.0, 1.0)), uv_fract - vec3(0.0, 0.0, 1.0));
	float n101 = dot(random(uv_index + vec3(1.0, 0.0, 1.0)), uv_fract - vec3(1.0, 0.0, 1.0));
	float n011 = dot(random(uv_index + vec3(0.0, 1.0, 1.0)), uv_fract - vec3(0.0, 1.0, 1.0));
	float n111 = dot(random(uv_index + vec3(1.0, 1.0, 1.0)), uv_fract - vec3(1.0, 1.0, 1.0));

	// Trilinear interpolation
	float nx00 = mix(n000, n100, blur.x);
	float nx10 = mix(n010, n110, blur.x);
	float nx01 = mix(n001, n101, blur.x);
	float nx11 = mix(n011, n111, blur.x);

	float nxy0 = mix(nx00, nx10, blur.y);
	float nxy1 = mix(nx01, nx11, blur.y);

	return mix(nxy0, nxy1, blur.z) + 0.5;
}

float aug_noise1(vec2 uv) {
	return noise2(vec3(uv,TIME));
}

float aug_noise2(vec2 uv) {
	float n = noise2(vec3(uv,TIME*0.01));
	n = pow(4.0*n*(1.0-n),6.0);
	return n;
}

float aug_noise3(vec2 uv) {
	float n = 10.0*noise2(vec3(uv,TIME))-5.0;
	n = 1.0-pow(4.0*n*(1.0-n),7.0);
	return n;
}

float pcurve( float x, float a, float b ){
    float k = pow(a+b,a+b) / (pow(a,a)*pow(b,b));
    return k * pow( x, a ) * pow( 1.0-x, b );
}

void fragment() {
	vec2 scaled_uv = UV*node2d_scale;
	vec2 custom_uv = 4.0*round(scaled_uv * float(pixelation)) / float(pixelation);
	float b = border(UV, 0.0);
	float field1 = aug_noise1(custom_uv*1.0);
	float field2 = aug_noise2((custom_uv+vec2(133.0,231.0))*3.0);
	float ratio = 0.5;
	float final_field = ((field1*field2*ratio+field1*(1.0-ratio))*0.7+0.1);
	vec4 final_colored_field = field_background_color + field_primary_color*field1 + field_secondary_color*field2;
	COLOR = final_colored_field * b + border_color * (1.0-b);
	//COLOR = vec4(1.0, 0.0, 1.0, 1.0) * pcurve(fract(TIME+1.0*length(custom_uv+1.0*aug_noise2(custom_uv)-vec2(0.5))),7.0,1.0);
}
