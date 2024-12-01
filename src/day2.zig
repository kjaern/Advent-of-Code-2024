const std = @import("std");
const utils = @import("utils.zig");
const allocator = std.heap.page_allocator;

fn readData() ![]u8 {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile("data.txt", .{});
    defer file.close();
    const file_size = (try file.stat()).size;

    const content = try allocator.alloc(u8, file_size);

    const datasize = try std.fs.File.read(file, content);
    std.debug.assert(datasize == file_size);
    return content;
}

pub fn main() !void {
    std.debug.print("\nday2\n\n", .{});
    var args = try std.process.argsWithAllocator(allocator);

    defer args.deinit();

    _ = args.skip();

    const file_path = args.next() orelse {
        std.debug.print("Please give a path to a input file\n", .{});
        return;
    };

    const data = try utils.readData(file_path);
    defer allocator.free(data);

    const arr = try safeReports(data);
    std.debug.print("safe reports {}\n", .{arr});
    const arr2 = try safeReports2(data);
    std.debug.print("safe reports {}\n", .{arr2});
}

fn isSafe(line: []const u8, skipvalue: usize) !bool {
    var iter2 = std.mem.split(u8, line, " ");
    var id: u8 = 0;
    var lastWord: u32 = 0;
    var same: u8 = 0;
    var increasing: u8 = 0;
    var decreasing: u8 = 0;
    var bigChange: u8 = 0;
    var start: u8 = 0;
    if (skipvalue == 0) {
        start = 2;
    } else {
        start = 1;
    }

    // while (iter2.next()) |words| {
    while (iter2.next()) |words| {
        if (words.len > 0) {
            if (skipvalue != id) {
                const val: u32 = try std.fmt.parseUnsigned(u32, words, 10);

                if (id >= start) {
                    if (val > lastWord) {
                        increasing = increasing + 1;
                        if (val - lastWord > 3) {
                            bigChange = bigChange + 1;
                        }
                    } else if (val == lastWord) {
                        same = same + 1;
                    } else {
                        decreasing = decreasing + 1;
                        if (lastWord - val > 3) {
                            bigChange = bigChange + 1;
                        }
                    }
                }
                lastWord = val;
            }

            id = id + 1;
        }
    }

    if (line.len > 1) {
        if (same == 0 and (decreasing == 0 or increasing == 0) and bigChange == 0) {
            return true;
        }
    }
    return false;
}

fn safeReports(data: []const u8) !u32 {
    var iter = std.mem.split(u8, data, "\r\n");

    var index: u16 = 0;
    var safeReportsFound: u32 = 0;
    while (iter.next()) |line| {
        if (!std.mem.eql(u8, line, " ")) {
            if (try isSafe(line, 100)) {
                safeReportsFound = safeReportsFound + 1;
            }
        }
        index = index + 1;
    }

    return safeReportsFound;
}

fn safeReports2(data: []const u8) !u32 {
    var iter = std.mem.split(u8, data, "\r\n");

    var count: usize = 0;
    var index: u16 = 0;
    var safeReportsFound: u32 = 0;
    while (iter.next()) |line| {
        count = 0;
        var iter2 = std.mem.split(u8, line, " ");

        while (iter2.next()) |_| {
            count = count + 1;
        }
        count = count + 1;
        if (!std.mem.eql(u8, line, " ")) {
            var safe = false;
            arrr: for (0..(count + 1)) |i| {
                safe = try isSafe(line, i);
                if (safe) {
                    break :arrr;
                }
            }
            if (safe) {
                safeReportsFound = safeReportsFound + 1;
            }
        }
        index = index + 1;
    }

    return safeReportsFound;
}

test "Day 2 test part 1" {
    const file_path = "data/day2_test.txt";
    const data = try utils.readData(file_path);
    defer allocator.free(data);
    const value = safeReports(data);
    try std.testing.expectEqual(@as(u32, 2), value);
}

test "Day 2 test part 2" {
    const file_path = "data/day2_test.txt";
    const data = try utils.readData(file_path);
    defer allocator.free(data);
    const value = safeReports2(data);
    try std.testing.expectEqual(@as(u32, 4), value);
}
