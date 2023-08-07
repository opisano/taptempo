module color;

import std.algorithm.comparison: clamp, max, min;

@safe:

/** 
 * Represents a color in the RGB color space. 
 */
struct RGB
{
    /// Red channel, between 0.0 and 1.0
    double r;
    /// Green channel, between 0.0 and 1.0
    double g;
    /// Blue channel, between 0.0 and 1.0
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
    immutable t = (value.clamp(MIN_VALUE, MAX_VALUE) - MIN_VALUE) / (MAX_VALUE - MIN_VALUE);
    assert (t >= 0 && t <= 1);

    // Interpolate in HSV space, then convert to RBG for display
    immutable temp = HSV (
        linear(MIN_COLOR.h, MAX_COLOR.h, t).clamp(0, 360.0),
        linear(MIN_COLOR.s, MAX_COLOR.s, t).clamp(0, 1.0),
        linear(MIN_COLOR.v, MAX_COLOR.v, t).clamp(0, 1.0),
    );

    return temp.toRGB;
}

private:

/// Minimum tempo value 
enum MIN_VALUE = 40.0;

/// Maximum tempo value
enum MAX_VALUE = 220.0;

/// Color associated to minimum value (blue)
static immutable HSV MIN_COLOR = HSV(240, 1, 1);

/// Color associated to maximum value (red)
static immutable HSV MAX_COLOR = HSV(0, 1, 1);

/** 
 * Linear interpolation function
 */
double linear(double a, double b, double t) pure nothrow @nogc
in
{
    assert (t >= 0 && t <= 1);
}
do
{
    return a * (1 - t) + b * t;
}

/** 
 * Represents a color in the HSV color space. 
 */
struct HSV 
{
    /// Hue angle in degrees, between 0 and 360
    double h;
    /// Saturation, between 0 and 1
    double s;
    /// Value, between 0 and 1
    double v;
}

/** 
 * HSV to RGB conversion.
 */
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
    immutable hh = hsv.h >= 360.0 ? 0.0 : hsv.h / 60.0;
    immutable i = cast(int) hh;
    immutable ff = hh - i;
    immutable p = hsv.v * (1.0 - hsv.s);
    immutable q = hsv.v * (1.0 - (hsv.s * ff));
    immutable t = hsv.v * (1.0 - (hsv.s * (1.0 - ff)));

    final switch (i) 
    {
    case 0:
        return RGB(hsv.v, t, p);

    case 1:
        return RGB(q, hsv.v, p);

    case 2:
        return RGB(p, hsv.v, t);

    case 3:
        return RGB(p, q, hsv.v);

    case 4:
        return RGB(t, p, hsv.v);

    case 5:
        return RGB(hsv.v, p, q);
    }
}
