const std = @import("std");

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
    const cwd = std.fs.cwd();
    const file = try cwd.openFile("data.txt", .{});
    defer file.close();
    const file_size = (try file.stat()).size;

    const content = try allocator.alloc(u8, file_size);
    defer allocator.free(content);

    const data = try std.fs.File.read(file, content);
    std.debug.assert(data == file_size);
    // const data =
    //     \\7 6 4 2 1
    //     \\1 2 7 8 9
    //     \\9 7 6 2 1
    //     \\1 3 2 4 5
    //     \\8 6 4 4 1
    //     \\1 3 6 7 9
    // ;

    // const data = readData();
    // std.debug.print("{}", .{data});
    const arr = try safeReports(content);
    std.debug.print("safe reports {}", .{arr});
}

fn safeReports(data: []const u8) !u32 {
    var iter = std.mem.split(u8, data, "\r\n");

    var index: u16 = 0;
    var safeReportsFound: u32 = 0;
    while (iter.next()) |line| {
        if (!std.mem.eql(u8, line, " ")) {
            var iter2 = std.mem.split(u8, line, " ");
            var id: u8 = 0;
            var lastWord: u32 = 0;
            var same: u8 = 0;
            var increasing: u8 = 0;
            var decreasing: u8 = 0;
            var bigIncrease: u8 = 0;
            var bigDecrease: u8 = 0;

            // while (iter2.next()) |words| {
            while (iter2.next()) |words| {
                if (words.len > 0) {
                    const val: u32 = try std.fmt.parseUnsigned(u32, words, 10);

                    if (id >= 1) {
                        if (val > lastWord) {
                            increasing = increasing + 1;
                            if (val - lastWord > 3) {
                                bigIncrease = bigIncrease + 1;
                            }
                        } else if (val == lastWord) {
                            same = same + 1;
                        } else {
                            decreasing = decreasing + 1;
                            if (lastWord - val > 3) {
                                bigDecrease = bigDecrease + 1;
                            }
                        }
                    }
                    id = id + 1;
                    lastWord = val;
                }
            }

            if (line.len > 1) {
                if (same == 0 and (decreasing == 0 or increasing == 0)) {
                    safeReportsFound = safeReportsFound + 1;
                    std.debug.print("{s} safe\n", .{line});
                } else {
                    std.debug.print("{s} not safe\n", .{line});
                }

                // const safeReportsFound: u32 = 0;
            }
        }
        index = index + 1;
    }

    return safeReportsFound;
}

fn safeReports2(data: []const u8) !u32 {
    std.debug.print("{s}", .{data});

    var iter = std.mem.split(u8, data, "\r\n");

    var index: u16 = 0;
    var safeReportsFound: u32 = 0;
    // const safeReportsFound: u32 = 0;
    while (iter.next()) |line| {
        if (!std.mem.eql(u8, line, " ")) {
            var iter2 = std.mem.split(u8, line, " ");
            var id: u8 = 0;
            var lastWord: u32 = 0;
            var decreasing: bool = true;
            var safe: bool = true;

            // while (iter2.next()) |words| {
            report: while (iter2.next()) |words| {
                if (words.len > 0) {
                    const val: u32 = try std.fmt.parseUnsigned(u32, words, 10);
                    // const val: u32 = try std.fmt.parseUnsigned(u32, "1", 10);
                    // const val: u32 = try std.fmt.parseUnsigned(u32, "15", 10);

                    // const val: u32 = try std.fmt.parseUnsigned(u32, words, 255);
                    // if (val == std.fmt.ParseIntError) {
                    //     std.debug.print("failed {s}", .{words});
                    //     val = 0;
                    // }
                    // const val: u32 = 0; // try std.fmt.parseUnsigned(u32, words, 10);

                    if (id == 1) {
                        if (lastWord > val) {
                            decreasing = true;
                        } else {
                            decreasing = false;
                        }
                    }
                    if (id >= 1) {
                        if (decreasing) {
                            if (val > lastWord) {
                                safe = false;
                                break :report;
                            } else {
                                if (lastWord - val < 1 or lastWord - val > 3) {
                                    safe = false;

                                    break :report;
                                }
                            }
                        } else {
                            if (val < lastWord) {
                                safe = false;
                                break :report;
                            } else {
                                if (val - lastWord < 1 or val - lastWord > 3) {
                                    safe = false;
                                    break :report;
                                }
                            }
                        }
                    }
                    id = id + 1;
                    lastWord = val;
                }
            }
            if (line.len > 1) {
                if (safe) {
                    safeReportsFound = safeReportsFound + 1;
                }
                std.debug.print("report safe {s} {} \n", .{ line, safe });
            }
        }
        index = index + 1;
    }
    return safeReportsFound;
}

test "safe report test" {
    const data = try readData();
    defer allocator.free(data);
    const value = safeReports2(data);

    try std.testing.expectEqual(@as(u32, 2), value);
}

test "safe report test part 2" {
    const data = try readData();
    defer allocator.free(data);
    const value = safeReports2(data);

    try std.testing.expectEqual(@as(u32, 2), value);
}
