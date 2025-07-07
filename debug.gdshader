shader_type canvas_item;

uniform vec2 pixel_size = vec2(8.0, 4.0);       // Size of each pixel block
uniform float aberration_amount = 0.005;        // Max chromatic offset at edges
uniform float bulge_strength = 0.3;             // Positive for bulge, negative for pinch
uniform float scanline_intensity = 0.4;         // How dark scanlines get (0 = no effect, 1 = full black)
uniform float scanline_size = 2.0;              // Scanline height in pixels (higher = thicker scanlines)

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

    vec4 color = vec4(r, g, b, 1.0);

    // CRT scanline effect with bulge deformation:
    // Use distorted_uv.y instead of UV.y to deform scanlines with bulge
    float scanline = sin(distorted_uv.y * resolution.y / scanline_size * 3.14159);

    float brightness_mod = mix(1.0, 1.0 - scanline_intensity, (scanline * 0.5 + 0.5));

    COLOR = color * brightness_mod;
}
