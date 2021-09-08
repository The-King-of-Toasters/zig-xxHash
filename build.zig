const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("xxhash", "src/xxhash.zig");
    lib.setBuildMode(mode);
    lib.install();

    const test_step = b.step("test", "Run library tests");
    var main_tests = b.addTest("src/xxhash.zig");
    main_tests.setBuildMode(mode);
    test_step.dependOn(&main_tests.step);

    const benchmark_step = b.step("benchmark", "Run the benchmark.");
    const benchmark = b.addExecutable("benchmark", "src/benchmark.zig");
    benchmark.setBuildMode(mode);
    benchmark.setTarget(target);
    const benchmark_run = benchmark.run();
    benchmark_run.step.dependOn(b.getInstallStep());
    benchmark_step.dependOn(&benchmark_run.step);
}
