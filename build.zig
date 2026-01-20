const std = @import("std");
const fs = std.fs;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Dependencies
    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });
    const raylib = raylib_dep.module("raylib");
    const raylib_artifact = raylib_dep.artifact("raylib");

    const core = b.addModule("core", .{
        .root_source_file = b.path("src/core/root.zig"),
        .target = target,
        .imports = &.{
            .{ .name = "raylib", .module = raylib },
        },
    });

    const basic_exe = b.addExecutable(.{
        .name = "basic",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/basic/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "core", .module = core },
                .{ .name = "raylib", .module = raylib },
            },
        }),
    });

    const verlet_exe = b.addExecutable(.{
        .name = "verlet",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/verlet/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "core", .module = core },
                .{ .name = "raylib", .module = raylib },
            },
        }),
    });

    basic_exe.linkLibrary(raylib_artifact);
    verlet_exe.linkLibrary(raylib_artifact);

    b.installArtifact(basic_exe);
    b.installArtifact(verlet_exe);

    const run_verlet = b.addRunArtifact(verlet_exe);
    run_verlet.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_verlet.addArgs(args);
    }

    const run_basic = b.addRunArtifact(basic_exe);
    run_basic.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_basic.addArgs(args);
    }

    b.step("run-v", "Run the verlet version1").dependOn(&run_verlet.step);
    b.step("run-b", "Run the basic app").dependOn(&run_basic.step);
    // Creates an executable that will run `test` blocks from the provided module.
    // Here `mod` needs to define a target, which is why earlier we made sure to
    // set the releative field.
    const core_tests = b.addTest(.{
        .root_module = core,
    });

    // A run step that will run the test executable.
    const run_core_tests = b.addRunArtifact(core_tests);

    // Creates an executable that will run `test` blocks from the executable's
    // root module. Note that test executables only test one module at a time,
    // hence why we have to create two separate ones.
    const exe_tests = b.addTest(.{
         .root_module = verlet_exe.root_module,
    });

    // A run step that will run the second test executable.
    const run_exe_tests = b.addRunArtifact(exe_tests);

    // A top level step for running all tests. dependOn can be called multiple
    // times and since the two run steps do not depend on one another, this will
    // make the two of them run in parallel.
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_core_tests.step);
    test_step.dependOn(&run_exe_tests.step);
}
