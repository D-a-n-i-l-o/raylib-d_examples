/*******************************************************************************************
*
*   raylib [core] example - custom frame control
*
*   NOTE: WARNING: This is an example for advance users willing to have full control over
*   the frame processes. By default, EndDrawing() calls the following processes:
*       1. Draw remaining batch data: rlDrawRenderBatchActive()
*       2. SwapScreenBuffer()
*       3. Frame time control: WaitTime()
*       4. PollInputEvents()
*
*   To avoid steps 2, 3 and 4, flag SUPPORT_CUSTOM_FRAME_CONTROL can be enabled in
*   config.h (it requires recompiling raylib). This way those steps are up to the user.
*
*   Note that enabling this flag invalidates some functions:
*       - GetFrameTime()
*       - SetTargetFPS()
*       - GetFPS()
*
*   Example originally created with raylib 4.0, last time updated with raylib 4.0
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2021-2023 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylib;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
void main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - custom frame control");

    // Custom timming variables
    double previousTime = GetTime();    // Previous time measure
    double currentTime = 0.0;           // Current time measure
    double updateDrawTime = 0.0;        // Update + Draw time
    double waitTime = 0.0;              // Wait time (if target fps required)
    float deltaTime = 0.0f;             // Frame time (Update + Draw + Wait time)

    float timeCounter = 0.0f;           // Accumulative time counter (seconds)
    float position = 0.0f;              // Circle position
    bool pause = false;                 // Pause control flag

    int targetFPS = 60;                 // Our initial target fps
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        PollInputEvents();              // Poll input events (SUPPORT_CUSTOM_FRAME_CONTROL)

        if (IsKeyPressed(KeyboardKey.KEY_SPACE)) pause = !pause;

        if (IsKeyPressed(KeyboardKey.KEY_UP)) targetFPS += 20;
        else if (IsKeyPressed(KeyboardKey.KEY_DOWN)) targetFPS -= 20;

        if (targetFPS < 0) targetFPS = 0;

        if (!pause)
        {
            position += 200*deltaTime;  // We move at 200 pixels per second
            if (position >= GetScreenWidth()) position = 0;
            timeCounter += deltaTime;   // We count time (seconds)
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            for (int i = 0; i < GetScreenWidth()/200; i++) DrawRectangle(200*i, 0, 1, GetScreenHeight(), Colors.SKYBLUE);

            DrawCircle(cast(int)position, GetScreenHeight()/2 - 25, 50, Colors.RED);

            DrawText(TextFormat("%03.0f ms", timeCounter*1000.0f), cast(int)position - 40, GetScreenHeight()/2 - 100, 20, Colors.MAROON);
            DrawText(TextFormat("PosX: %03.0f", position), cast(int)position - 50, GetScreenHeight()/2 + 40, 20, Colors.BLACK);

            DrawText("Circle is moving at a constant 200 pixels/sec,\nindependently of the frame rate.", 10, 10, 20, Colors.DARKGRAY);
            DrawText("PRESS SPACE to PAUSE MOVEMENT", 10, GetScreenHeight() - 60, 20, Colors.GRAY);
            DrawText("PRESS UP | DOWN to CHANGE TARGET FPS", 10, GetScreenHeight() - 30, 20, Colors.GRAY);
            DrawText(TextFormat("TARGET FPS: %i", targetFPS), GetScreenWidth() - 220, 10, 20, Colors.LIME);
            DrawText(TextFormat("CURRENT FPS: %i", cast(int)(1.0f/deltaTime)), GetScreenWidth() - 220, 40, 20, Colors.GREEN);

        EndDrawing();

        // NOTE: In case raylib is configured to SUPPORT_CUSTOM_FRAME_CONTROL,
        // Events polling, screen buffer swap and frame time control must be managed by the user

        //SwapScreenBuffer();         // Flip the back buffer to screen (front buffer)

        currentTime = GetTime();
        updateDrawTime = currentTime - previousTime;

        if (targetFPS > 0)          // We want a fixed frame rate
        {
            waitTime = (1.0f/cast(float)targetFPS) - updateDrawTime;
            if (waitTime > 0.0)
            {
                WaitTime(cast(float)waitTime);
                currentTime = GetTime();
                deltaTime = cast(float)(currentTime - previousTime);
            }
        }
        else deltaTime = cast(float)updateDrawTime;    // Framerate could be variable

        previousTime = currentTime;
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}