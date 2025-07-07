shader_type canvas_item;

uniform vec2 pixel_size = vec2(8.0, 4.0);       // Size of each pixel block
uniform float aberration_amount = 0.005;        // Max chromatic offset at edges
uniform float bulge_strength = 0.3;             // Positive for bulge, negative for pinch

void fragment() {
    vec2 resolution = vec2(textureSize(TEXTURE, 0));
    vec2 center = vec2(0.5, 0.5);

    // Vector from center
    vec2 offset = UV - center;
    float dist = length(offset);

    // Bulge distortion
    float bulge = 1.0 + bulge_strength * dist * dist;
    vec2 distorted_uv = center + offset * bulge;

    // Pixelation on distorted UV
    vec2 block_uv = floor(distorted_uv * resolution / pixel_size) * pixel_size / resolution;

    // Direction outward from center (for chromatic shift)
    vec2 dir = normalize(offset);
    vec2 shift = dir * aberration_amount * dist;

    // Sample texture with RGB shifts
    float r = texture(TEXTURE, block_uv + shift).r;
    float g = texture(TEXTURE, block_uv).g;
    float b = texture(TEXTURE, block_uv - shift).b;

    COLOR = vec4(r, g, b, 1.0);
}
