const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const day = b.option([]const u8, "day", "Select which day to run") orelse "all";
    const runtime_data = b.option([]const u8, "data", "Run on the large dataset") orelse "test";

    const options = b.addOptions();
    options.addOption([]const u8, "day", day);

    options.addOption([]const u8, "data", runtime_data);

    const optimize = b.standardOptimizeOption(.{});

    const run_step = b.step("run", "Run code for all the days.");
    const run_day_step = b.step("day", "Run a single day.");

    const test_step = b.step("test", "Run unit tests");

    std.debug.print("\nWorking on assignments:\n ", .{});

    for (exercises) |ex| {
        if (std.mem.eql(u8, day, ex.day_code) or std.mem.eql(u8, day, "all")) {
            std.debug.print("\nday{s}\n ", .{ex.name});
            const exe = b.addExecutable(.{
                .name = ex.name,
                .root_source_file = b.path(ex.main_file),
                .target = target,
                .optimize = optimize,
            });

            b.installArtifact(exe);

            const run_cmd = b.addRunArtifact(exe);
            run_cmd.step.dependOn(b.getInstallStep());
            if (b.args) |args| {
                run_cmd.addArgs(args);
            }

            if (std.mem.eql(u8, runtime_data, "test")) {
                std.debug.print("data {s} {s}\n ", .{ day, ex.data_test_file });
                run_cmd.addArgs(&[_][]const u8{ex.data_test_file});
            } else {
                std.debug.print("data {s} {s}\n ", .{ day, ex.data_file });
                run_cmd.addArgs(&[_][]const u8{ex.data_file});
            }

            run_step.dependOn(&run_cmd.step);
            run_day_step.dependOn(&run_cmd.step);

            const exe_unit_tests = b.addTest(.{
                .root_source_file = b.path(ex.main_file),
                .target = target,
                .optimize = optimize,
            });

            const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
            test_step.dependOn(&run_exe_unit_tests.step);
        }
    }
}
const Kind = enum {
    /// Run the artifact as a normal executable.
    exe,
    /// Run the artifact as a test.
    @"test",
};

pub const Exercise = struct {
    main_file: []const u8,
    day_code: []const u8,
    name: []const u8,
    data_file: []const u8,
    data_test_file: []const u8,
};

const exercises = [_]Exercise{
    .{
        .main_file = "src/day8.zig",
        .day_code = "8",
        .name = "day8",
        .data_test_file = "data/day8_test.txt",
        .data_file = "data/day8.txt",
    },
    .{
        .main_file = "src/day7.zig",
        .day_code = "7",
        .name = "day7",
        .data_test_file = "data/day7_test.txt",
        .data_file = "data/day7.txt",
    },
    .{
        .main_file = "src/day6.zig",
        .day_code = "6",
        .name = "day6",
        .data_test_file = "data/day6_test.txt",
        .data_file = "data/day6.txt",
    },
    .{
        .main_file = "src/day5.zig",
        .day_code = "5",
        .name = "day5",
        .data_test_file = "data/day5_test.txt",
        .data_file = "data/day5.txt",
    },
    .{
        .main_file = "src/day4.zig",
        .day_code = "4",
        .name = "day4",
        .data_test_file = "data/day4_test.txt",
        .data_file = "data/day4.txt",
    },
    .{
        .main_file = "src/day3.zig",
        .day_code = "3",
        .name = "day3",
        .data_test_file = "data/day3_test.txt",
        .data_file = "data/day3.txt",
    },
    .{
        .main_file = "src/day2.zig",
        .day_code = "2",
        .name = "day2",
        .data_test_file = "data/day2_test.txt",
        .data_file = "data/day2.txt",
    },
    .{
        .main_file = "src/day1.zig",
        .day_code = "1",
        .name = "day1",
        .data_test_file = "data/day1_test.txt",
        .data_file = "data/day1.txt",
    },
};
