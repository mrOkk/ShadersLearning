inline float2 voronoi_noise_dir(float2 uv, const float offset)
{
    const float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
    uv = frac(sin(mul(uv, m)) * 46839.32);
    return float2(sin(uv.y * offset) * 0.5 + 0.5, cos(uv.x * offset) * 0.5 + 0.5);
}

void voronoi_noise(float2 uv, float angle_offset, float cell_density, out float value, out float cells)
{
    const float2 g = floor(uv * cell_density);
    const float2 f = frac(uv * cell_density);
    float3 res = float3(8.0, 0.0, 0.0);

    for (int y = -1; y <= 1; y++)
    {
        for (int x = -1; x <= 1; x++)
        {
            float2 lattice = float2(x, y);
            float2 offset = voronoi_noise_dir(lattice + g, angle_offset);
            float d = distance(lattice + offset, f);
            if (d < res.x)
            {
                res = float3(d, offset.x, offset.y);
                value = res.x;
                cells = res.y;
            }
        }
    }
}

inline float2 gradient_noise_dir(float2 p)
{
    p = p % 289;
    float x = (34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

float gradient_noise(float2 p)
{
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(gradient_noise_dir(ip), fp);
    float d01 = dot(gradient_noise_dir(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(gradient_noise_dir(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(gradient_noise_dir(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
}