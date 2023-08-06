module color;

import std.algorithm.comparison: clamp, max, min;

@safe:

struct RGB
{
    double r;
    double g;
    double b;
}

/** 
 * Provide a color to associate to a tempo value.
 */
RGB tempoColor(double value) pure nothrow @nogc
in 
{
    assert (value >= 0);
}
out (rgb)
{
    assert (rgb.r >= 0 && rgb.r <= 1);
    assert (rgb.g >= 0 && rgb.g <= 1);
    assert (rgb.b >= 0 && rgb.b <= 1);
}
do
{
    // normalize input between 0.0 and 1.0
    value = clamp(value, MIN_VALUE, MAX_VALUE);
    immutable double t = (value - MIN_VALUE) / (MAX_VALUE - MIN_VALUE);
    assert (t >= 0 && t <= 1);

    // Interpolate in HSV space, then convert to RBG for display
    HSV temp;
    temp.h = clamp(linear(MIN_COLOR.h, MAX_COLOR.h, t), 0, 360.0);
    temp.s = clamp(linear(MIN_COLOR.s, MAX_COLOR.s, t), 0, 1.0);
    temp.v = clamp(linear(MIN_COLOR.v, MAX_COLOR.v, t), 0, 1.0);

    return temp.toRGB;
}

private:

/// Minimum tempo value 
enum MIN_VALUE = 40.0;

/// Maximum tempo value
enum MAX_VALUE = 220.0;

/// Color associated to minimum value 
static immutable HSV MIN_COLOR = HSV(240, 1, 1);

/// Color associated to maximum value 
static immutable HSV MAX_COLOR = HSV(0, 1, 1);

/** 
 * Linear interpolation function
 */
double linear(double a, double b, float t) pure nothrow @nogc
in
{
    assert (t >= 0 && t <= 1);
}
do
{
    return a * (1 - t) + b * t;
}

struct HSV 
{
    double h;
    double s;
    double v;
}

RGB toRGB(in HSV hsv) pure nothrow @nogc
in 
{
    assert (hsv.h >= 0 && hsv.h <= 360);
    assert (hsv.s >= 0 && hsv.s <= 1);
    assert (hsv.v >= 0 && hsv.v <= 1);
}
out (result)
{
    assert (result.r >= 0 && result.r <= 1);
    assert (result.g >= 0 && result.g <= 1);
    assert (result.b >= 0 && result.b <= 1);
}
do
{
    double hh = hsv.h;
    if (hh >= 360.0)
    {
        hh = 0.0;
    }

    hh /= 60.0;
    int i = cast(int) hh;
    double ff = hh - i;
    double p = hsv.v * (1.0 - hsv.s);
    double q = hsv.v * (1.0 - (hsv.s * ff));
    double t = hsv.v * (1.0 - (hsv.s * (1.0 - ff)));

    RGB rgb;
    switch (i) 
    {
    case 0:
        rgb.r = hsv.v;
        rgb.g = t;
        rgb.b = p;
        break;
    case 1:
        rgb.r = q;
        rgb.g = hsv.v;
        rgb.b = p;
        break;
    case 2:
        rgb.r = p;
        rgb.g = hsv.v;
        rgb.b = t;
        break;

    case 3:
        rgb.r = p;
        rgb.g = q;
        rgb.b = hsv.v;
        break;
    case 4:
        rgb.r = t;
        rgb.g = p;
        rgb.b = hsv.v;
        break;
    case 5:
    default:
        rgb.r = hsv.v;
        rgb.g = p;
        rgb.b = q;
        break;
    }
    return rgb;
}
