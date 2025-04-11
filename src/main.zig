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

    const renderer = c.SDL_CreateRenderer(window, -1, 0); // orelse {};

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

        for (0..numberOfStars) |i| {
            var s = starCollection[i];
            s.update();
            starCollection[i].x = s.x;
            starCollection[i].y = s.y;
            starCollection[i].angle = s.angle;
            starCollection[i].speed = s.speed;

            _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 0);
            _ = c.SDL_RenderDrawPoint(renderer, s.x, s.y);
        }
        _ = c.SDL_RenderPresent(renderer);
        _ = c.SDL_Delay(10);
    }
    c.SDL_DestroyWindow(window);
    c.SDL_Quit();
}
