const std = @import("std");

const star = @import("stars.zig").Star;

const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub fn main() !void {
    const numberOfStars: u16 = 1000;
    var starCollection: [numberOfStars]star = undefined;
    var prng = std.Random.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });

    const rand = prng.random();

    for (0..numberOfStars) |i| {
        starCollection[i] = star.new(400, 300, rand);
    }

    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Failed to initialise SDL: %s", c.SDL_GetError());
        return error.SDLInitialisationFailure;
    }

    const window = c.SDL_CreateWindow("Stars with Zig and SDL", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, 800, 600, c.SDL_WINDOW_SHOWN);

    const renderer = c.SDL_CreateRenderer(window, -1, 0);

    var running = true;
    while (running) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    running = false;
                },
                else => {},
            }
        }
        _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 0);
        _ = c.SDL_RenderClear(renderer);

        for (starCollection[0..numberOfStars]) | *stars| {
            stars.update();
            _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 0);
            _ = c.SDL_RenderDrawPoint(renderer, stars.x, stars.y);
        }
        _ = c.SDL_RenderPresent(renderer);
        _ = c.SDL_Delay(10);
    }
    c.SDL_DestroyWindow(window);
    c.SDL_Quit();
}
