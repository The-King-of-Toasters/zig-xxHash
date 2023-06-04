const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "xxhash",
        .root_source_file = .{ .path = "src/xxhash.zig" },
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);

    const main_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/xxhash.zig" },
        .target = target,
        .optimize = optimize,
    });
    const run_main_tests = b.addRunArtifact(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);

    const benchmark = b.addExecutable(.{
        .name = "benchmark",
        .root_source_file = .{ .path = "src/benchmark.zig" },
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(benchmark);
    const run_cmd = b.addRunArtifact(benchmark);
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("benchmark", "Run the benchmark");
    run_step.dependOn(&run_cmd.step);
}
