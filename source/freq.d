module freq;

import derelict.sdl2.sdl;
import std.algorithm: map, mean, sort, stripRight;
import std.range: slide;

@safe:

/// The number of ticks used to calculate the frequency (must be a power of two)
private enum BUFFER_SIZE = 4;

/**
 * Caculates in beats per minute the frequency at which the addTick method is called.
 */
struct FreqCalc
{
    /** 
     * Add a new tick in the buffer
     */
    void addTick() nothrow @nogc
    {
        m_ticks[m_index] = ( ()@trusted => SDL_GetTicks() )();
        m_index = (m_index + 1) & (BUFFER_SIZE - 1);
        m_length++;
    }

    /** 
     * Returns the tick frequency, in bpm
     */
    double bpm() const pure nothrow @nogc
    {
        uint[BUFFER_SIZE] ticks = m_ticks;

        // calculate mean period between ticks
        double m = ticks[].stripRight(0)
                          .sort
                          .slide(2)
                          .map!(tuple => tuple[1] - tuple[0])
                          .mean;

        // Period to Frequency
        return (1000.0 / m) * 60.0;
    }

    /** 
     * Returns how many ticks have been added so far.
     */
    size_t length() const pure nothrow @nogc
    {
        return m_length;
    }

private:
    /// Stores the latest ticks 
    uint[BUFFER_SIZE] m_ticks;
    /// Index of the next tick
    size_t m_index;
    /// tick count
    size_t m_length;
}


