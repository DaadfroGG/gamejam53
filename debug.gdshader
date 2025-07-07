shader_type canvas_item;

// === Main Uniforms ===
uniform vec2 pixel_size = vec2(8.0, 4.0);
uniform float aberration_amount = 0.005;
uniform float bulge_strength = 0.3;
uniform float scanline_intensity = 0.4;
uniform float scanline_size = 2.0;

// === LFO Amounts (0 = no modulation, 1 = fully modulate to zero) ===
uniform float pixel_lfo_amount : hint_range(0.0, 1.0) = 0.0;
uniform float aberration_lfo_amount : hint_range(0.0, 1.0) = 0.0;
uniform float bulge_lfo_amount : hint_range(0.0, 1.0) = 0.0;
uniform float scanline_lfo_amount : hint_range(0.0, 1.0) = 0.0;

// === LFO Speeds for Each Effect ===
uniform float pixel_lfo_speed = 0.25;
uniform float aberration_lfo_speed = 0.25;
uniform float bulge_lfo_speed = 0.25;
uniform float scanline_lfo_speed = 0.25;

void fragment() {
    vec2 resolution = vec2(textureSize(TEXTURE, 0));
    vec2 center = vec2(0.5, 0.5);
    vec2 offset = UV - center;
    float dist = length(offset);
    vec2 dir = normalize(offset);

    // === LFO Oscillators (0 to 1 range) ===
    float pixel_lfo = sin(TIME * pixel_lfo_speed * 6.28318) * 0.5 + 0.5;
    float aberration_lfo = sin(TIME * aberration_lfo_speed * 6.28318) * 0.5 + 0.5;
    float bulge_lfo = sin(TIME * bulge_lfo_speed * 6.28318) * 0.5 + 0.5;
    float scanline_lfo = sin(TIME * scanline_lfo_speed * 6.28318) * 0.5 + 0.5;

    // === Modulated Parameters ===
    vec2 mod_pixel_size = mix(pixel_size, vec2(0.0), pixel_lfo_amount * (1.0 - pixel_lfo));
    float mod_aberration = mix(aberration_amount, 0.0, aberration_lfo_amount * (1.0 - aberration_lfo));
    float mod_bulge = mix(bulge_strength, 0.0, bulge_lfo_amount * (1.0 - bulge_lfo));
    float mod_scanline = mix(scanline_intensity, 0.0, scanline_lfo_amount * (1.0 - scanline_lfo));

    // === Bulge Distortion ===
    float bulge = 1.0 + mod_bulge * dist * dist;
    vec2 distorted_uv = center + offset * bulge;

    // === Pixelation ===
    vec2 block_uv = floor(distorted_uv * resolution / mod_pixel_size) * mod_pixel_size / resolution;

    // === Chromatic Aberration ===
    vec2 shift = dir * mod_aberration * dist;
    float r = texture(TEXTURE, block_uv + shift).r;
    float g = texture(TEXTURE, block_uv).g;
    float b = texture(TEXTURE, block_uv - shift).b;

    vec4 color = vec4(r, g, b, 1.0);

    // === Scanlines ===
    float scanline = sin(distorted_uv.y * resolution.y / scanline_size * 3.14159);
    float brightness_mod = mix(1.0, 1.0 - mod_scanline, (scanline * 0.5 + 0.5));

    COLOR = color * brightness_mod;
}
