const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "tetriz",
        .root_source_file = .{ .path = "src/main.zig" },
        .optimize = optimize,
    });
    // exe.setBuildMode(optimize);
    exe.linkSystemLibrary("SDL2");
    exe.linkSystemLibrary("sdl2_ttf"); // Added
    exe.linkSystemLibrary("c");

    b.default_step.dependOn(&exe.step);
    b.installArtifact(exe);

    const run = b.step("run", "Run the demo");
    const run_cmd = std.Build.addRunArtifact(b, exe);
    run.dependOn(&run_cmd.step);

    // const mode = b.standardReleaseOptions();
    // const exe = b.addExecutable("tetriz", "src/main.zig");
    // exe.setBuildMode(mode);

    // exe.linkLibC();
    // exe.linkSystemLibrary("SDL2");
    // exe.linkSystemLibrary("sdl2_ttf"); // Added
    // exe.linkSystemLibrary("c");

    // b.default_step.dependOn(&exe.step);
    // b.installArtifact(exe);

    // const run = b.step("run", "Run the demo");
    // const run_cmd = exe.run();
    // run.dependOn(&run_cmd.step);

    // exe.install();

    // // Standard target options allows the person running `zig build` to choose
    // // what target to build for. Here we do not override the defaults, which
    // // means any target is allowed, and the default is native. Other options
    // // for restricting supported target set are available.
    // const target = b.standardTargetOptions(.{});

    // // Standard release options allow the person running `zig build` to select
    // // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    // const mode = b.standardReleaseOptions();

    // const exe = b.addExecutable("tetriz", "src/main.zig");
    // exe.setTarget(target);
    // exe.setBuildMode(mode);
    // exe.linkLibC();
    // exe.linkSystemLibrary("SDL2"); // Added
    // exe.linkSystemLibrary("sdl2_ttf"); // Added
    // exe.install();

    // const run_cmd = exe.run();

    // run_cmd.step.dependOn(b.getInstallStep());
    // if (b.args) |args| {
    //     run_cmd.addArgs(args);
    // }

    // const run_step = b.step("run", "Run the app");
    // run_step.dependOn(&run_cmd.step);

    // const exe_tests = b.addTest("src/main.zig");
    // exe_tests.setTarget(target);
    // exe_tests.setBuildMode(mode);

    // const test_step = b.step("test", "Run unit tests");
    // test_step.dependOn(&exe_tests.step);
}
