import derelict.sdl2.mixer;
import derelict.sdl2.sdl;
import derelict.sdl2.ttf;

import std.algorithm;
import std.file;
import std.format;
import std.range;
import std.stdio;
import std.string;

import color;
import freq;


/** 
 * Entry point 
 * 
 * Params: 
 *     args = Command-line arguments
 */
void main(string[] args)
{
    App app = App(args);
    app.loop();
}


/** 
 * The application 
 */
struct App
{
    /** 
     * Initializes the application and loads resources.
     * 
     * Params: 
     *     args = Command-line arguments
     */
    this(string[] args)
    {
        initializeSDL;
        createWindow;
        loadFont;

        // if an arg was provided on the command line, try to load the music file
        if (args.length > 1)
        {
            loadMusicFile(args[1]);
            Mix_PlayMusic(m_pMusic, -1);
        }
    }

    /** 
     * Frees loaded resources
     */
    ~this()
    {
        if (m_pMusic != null)
        {
            if (Mix_PlayingMusic())
            {
                Mix_HaltMusic();
            }

            Mix_FreeMusic(m_pMusic);
            m_pMusic = null;
            Mix_Quit();
        }

        if (m_pFont != null)
        {
            TTF_CloseFont(m_pFont);
            m_pFont = null;
        }

        if (m_pRenderer != null)
        {
            SDL_DestroyRenderer(m_pRenderer);
            m_pRenderer = null;
        }

        if (m_pWindow != null)
        {
            SDL_DestroyWindow(m_pWindow);
            m_pWindow = null;
        }
    }

    /** 
     * Main loop
     */
    void loop()
    {
        m_active = true;
        while (m_active)
        {
            doInput;
            doDisplay;
        }
    }

private:

    /** 
     * SDL-related initialization
     */
    void initializeSDL()
    {
        DerelictSDL2.load;
        DerelictSDL2ttf.load;
        DerelictSDL2Mixer.load;

        if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO) < 0)
        {
            throw new Exception("Could not initialize SDL: %s".format(SDL_GetError));
        }

        if (TTF_Init() < 0)
        {
	        throw new Exception("Could not initialize SDL_TTF: %s".format(TTF_GetError));
        }

        if (Mix_OpenAudio(44_100, MIX_DEFAULT_FORMAT, 2, 2048) < 0)
        {
            throw new Exception("Could not open audio: %s".format(Mix_GetError));
        }
    }

    /** 
     * Create window and graphical resources
     */
    void createWindow()
    {
        const winFlags = SDL_WINDOW_RESIZABLE;
        m_pWindow = SDL_CreateWindow("Tap tempo", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 640, 480, winFlags);
        if (!m_pWindow)
        {
            throw new Exception("Could not create Window: %s\n".format(SDL_GetError));
        }

        const rendererFlags = SDL_RENDERER_ACCELERATED;
        m_pRenderer = SDL_CreateRenderer(m_pWindow, -1, rendererFlags);
        if (!m_pRenderer)
        {
            throw new Exception("Could not create Renderer: %s\n".format(SDL_GetError));
        }
    }

    /** 
     * Load the font used to display text
     */
    void loadFont()
    {
        string path = "/usr/share/fonts";
        foreach (entry; dirEntries(path, SpanMode.breadth, false))
        {
            if (entry.isFile && entry.name.endsWith("arial.ttf"))
            {
                m_pFont = TTF_OpenFont(entry.name.toStringz, 36);
                break;
            }
        }

        if (m_pFont == null)
        {
            throw new Exception("Could not open fond arial.ttf");
        }
    }

    /** 
     * Load music to tap against 
     * 
     * Params:
     *     filename = File to load 
     * 
     */
    void loadMusicFile(string filename)
    {
        m_pMusic = Mix_LoadMUS( filename.toStringz );

        if (m_pMusic == null)
        {
            throw new Exception("Failed to load music file %s".format(filename));
        }
    }

    /** 
     * Draws to the screen 
     */
    void doDisplay() @nogc
    {
        if (m_needToUpdate && m_fc.length > 1)
        {
            char[16] buffer = 0;
            double bpm = m_fc.bpm();
            sprintf(buffer.ptr, "BPM: %d", cast(int)bpm);

            // Set background color according to bpm
            RGB bgColor = tempoColor(bpm);
            SDL_SetRenderDrawColor(m_pRenderer, 
                                   cast(ubyte)(bgColor.r * 255), 
                                   cast(ubyte)(bgColor.g * 255), 
                                   cast(ubyte)(bgColor.b * 255), 
                                   255);
            SDL_RenderClear(m_pRenderer);

            // Draw text on a surface
            SDL_Color black = SDL_Color(0, 0, 0, 255);
            SDL_Surface* textSurface = TTF_RenderText_Blended(m_pFont, &buffer[0], black);
            scope (exit) SDL_FreeSurface(textSurface);

            // Convert it to a texture
            SDL_Texture* textTexture = SDL_CreateTextureFromSurface(m_pRenderer, textSurface);
            scope (exit) SDL_DestroyTexture(textTexture);

            // Blit it on the center of the screen
            int textWidth, textHeight, screenWidth, screenHeight;
            SDL_QueryTexture(textTexture, null, null, &textWidth, &textHeight);
            SDL_GetWindowSize(m_pWindow, &screenWidth, &screenHeight);

            auto rect = SDL_Rect(
                screenWidth / 2 - textWidth / 2,
                screenHeight / 2 - textHeight / 2,
                textWidth,
                textHeight
            );

            SDL_RenderCopy(m_pRenderer, textTexture, null, &rect);

            SDL_RenderPresent(m_pRenderer);
            m_needToUpdate = false;
        }
    }

    /**
     * Handles input 
     */
    void doInput() @nogc 
    {
        SDL_Event event;

        while (SDL_PollEvent(&event))
        {
            switch (event.type)
            {
            case SDL_QUIT:
                quit;
                break;

            case SDL_KEYDOWN:
                doKeyDown(event.key);
                break;

            default:
                break;
            }
        }
    }

    /** 
     * Handles KeyDown keyboard event.
     * 
     * Params:
     *     event = contains information about the key down event.
     */
    void doKeyDown(scope ref SDL_KeyboardEvent event) @nogc @safe
    {
        if (event.repeat == 0)
        {
            switch (event.keysym.sym)
            {
            case SDLK_ESCAPE:
                quit;
                break;

            case SDLK_SPACE:
                m_fc.addTick;
                m_needToUpdate = true;
                break;
            
            default: 
                break;
            }
        }
    }

    /** 
     * Exit main loop
     */
    void quit() @nogc @safe
    {
        m_active = false;
        m_needToUpdate = false;
    }

    /// Calculates the tap frequency in bpm
    FreqCalc m_fc;
    SDL_Renderer* m_pRenderer;
    SDL_Window* m_pWindow;
    TTF_Font* m_pFont;
    Mix_Music* m_pMusic;
    bool m_active;
    bool m_needToUpdate;
}


