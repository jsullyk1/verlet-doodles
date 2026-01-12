# verlet-doodles

A Verlet integration 2D physics engine written in zig... for fun.

This is a simple implementation of a verlet integration simulation written in zig. 
It is for for my own education and learning of the zig programming language and game physics.

## Sources of Inspiration

The source of inspiration for this project comes from the following video and associated videos and repository:

[Writing a Physics Engine From Scratch](https://www.youtube.com/watch?v=lS_qeBy3aQI)

## Dependencies

[Raylib Zig Bindings](https://github.com/raylib-zig/raylib-zig)

## Build and run

To build the project, make sure you have Zig installed on your system. Then, run the following command in the project directory:

```bash
zig build run
```

## TODO

- [X] Click to set emitter location
- [X] Reset button
- [X] Random size particles
- [X] Change colors over time
- [X] Turn gravity on/off
- [X] Add logging
- [ ] Add profiler [Tracy](https://www.reddit.com/r/Zig/comments/zpwoca/is_profiling_with_tracy_still_straightforward_can/)
- [ ] Switch between AoS and SoA.
- [ ] Systems need some global state info... like mouse position, keypressed etc, but I don't want raylib to bleed into my
      application code (even though its a cool library) instead I likely want to pass something like a UIStateData reference
      that my systems can use to get things like the cursor or mouse position.
- [ ] Smarter collision algorithm
- [ ] Change container shape

## First steps

I want to play with performance a bit and see how I can approach the organization of this code to support a larger 
number of particles. My current termination condition is when the application can no longer maintain 75% of the target fps (45fps).

The initial implementation gets to about 1100 particles before dropping below 45fps on my machine. This is with a naive O(n^2) 
collision detection algorithm. This is also with 8 substeps per frame, which gives a nice stable simulation.

![Verlet Doodles Screenshot 8 substeps](docs/doodles_1100.png)

### 16 Substeps

![Verlet Doodles Screenshot 16 substeps](docs/doodles_850.png)

### Detrminism

The simulation is also deterministic which is nice. Running the same simulation multiple times with the same initial conditions produces the same results.

![Verlet Doodles Screenshot Deterministic](docs/doodles_deterministic.png)


### Notes

#### iOS Support

Raylib doesn't currently support iOS, but there's a PR with an approach that may work. Not sure if this will be something I want to play with later.

[Raylib iOS Support PR](https://github.com/raysan5/raylib/pull/3880)

#### Saturating math operators

This if pretty cool. You can specify an arbitrary bit width with zig numbers like `u23`, or `u13` which is weird. It also has saturating operators... the normal ones will panic if an underflow or overflow occurs.

So this alg for cycling through the rainbow uses `u8` sized ints, and relies on the saturating operators. The cycle rate can be arbitrary, and it won't panic.

```zig
const ColorGenerator = struct {
    r: u8 = 255,
    g: u8 = 0,
    b: u8 = 0,
    phase: u8 = 0,
    rate: u8 = 4,

    pub fn nextRGBA(self: *@This()) u32 {
        switch (self.phase) {
            0 => {
                self.g +|= self.rate;
                if (self.g == 255) self.phase = 1;
            },
            1 => {
                self.r -|= self.rate;
                if (self.r == 0) self.phase = 2;
            },
            2 => {
                self.b +|= self.rate;
                if (self.b == 255) self.phase = 3;
            },
            3 => {
                self.g -|= self.rate;
                if (self.g == 0) self.phase = 4;
            },
            4 => {
                self.r +|= self.rate;
                if (self.r == 255) self.phase = 5;
            },
            5 => {
                self.b -|= self.rate;
                if (self.b == 0) self.phase = 0;
            },
            else => {},
        }
        return (@as(u32, self.r) << 24) | (@as(u32, self.g) << 16) | (@as(u32, self.b) << 8) | 0xFF;
    }
};
```


