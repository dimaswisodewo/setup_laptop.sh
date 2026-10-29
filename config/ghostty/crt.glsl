// CRT treatment: scanlines, color fringing, phosphor glow, and a soft vignette.

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Sample the original screen coordinates so terminal rows and columns stay straight.
    vec2 screenUV = fragCoord / iResolution.xy;
    vec2 centered = screenUV * 2.0 - 1.0;

    // Red/blue separation grows toward the edges to suggest a glass CRT lens.
    float edgeAmount = clamp(dot(centered, centered) * 0.5, 0.0, 1.0);
    float fringePixels = 0.75 + 0.75 * edgeAmount;
    vec2 fringe = vec2(fringePixels / iResolution.x, 0.0);
    vec4 centerColor = texture(iChannel0, screenUV);
    vec4 leftColor = texture(iChannel0, clamp(screenUV - fringe, 0.0, 1.0));
    vec4 rightColor = texture(iChannel0, clamp(screenUV + fringe, 0.0, 1.0));
    vec3 phosphor = vec3(leftColor.r, centerColor.g, rightColor.b);

    // A visible but controlled horizontal halo softens bright glyphs like phosphor bloom.
    vec3 horizontalAverage = (leftColor.rgb + rightColor.rgb) * 0.5;
    phosphor += max(horizontalAverage - centerColor.rgb, vec3(0.0)) * 0.24;

    // Pronounced scanlines, spaced three physical pixels apart.
    float scanline = 1.0 - 0.18 * (0.5 + 0.5 * cos(fragCoord.y * 2.0943951));

    // A slightly stronger cool phosphor bias preserves the palette's character.
    phosphor *= vec3(0.985, 1.0, 1.025);

    // Darken the glass toward the edges without a hard border.
    vec2 vignettePosition = centered;
    vignettePosition.x *= iResolution.x / iResolution.y;
    float edge = smoothstep(0.55, 1.4, length(vignettePosition));
    float vignette = 1.0 - 0.20 * edge;

    fragColor = vec4(phosphor * scanline * vignette, centerColor.a);
}
