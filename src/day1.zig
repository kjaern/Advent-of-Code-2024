const std = @import("std");
const utils = @import("utils.zig");
const allocator = std.heap.page_allocator;

pub fn main() !void {
    std.debug.print("\nday1\n\n", .{});
    var args = try std.process.argsWithAllocator(allocator);

    defer args.deinit();

    _ = args.skip();

    const file_path = args.next() orelse {
        std.debug.print("Please give a path to a input file\n", .{});
        return;
    };

    const data = try utils.readData(file_path);
    defer allocator.free(data);

    const arrays = try prepData(data);

    const dist = distance(arrays.a1, arrays.a2);
    const score = similarity(arrays.a1, arrays.a2);
    std.debug.print("dist = {}\n", .{dist});
    std.debug.print("score = {}\n", .{score});
}

const Arrays = struct { a1: []u32, a2: []u32 };

fn prepData(data: []u8) !Arrays {
    var iter = std.mem.split(u8, data, "\r\n");
    var list1 = std.ArrayList(u32).init(allocator);
    var list2 = std.ArrayList(u32).init(allocator);

    var index: u16 = 0;
    while (iter.next()) |line| {
        if (!std.mem.eql(u8, line, " ")) {
            var iter2 = std.mem.split(u8, line, " ");
            var id: u8 = 0;

            while (iter2.next()) |words| {
                if (words.len > 0) {
                    const val: u32 = try std.fmt.parseUnsigned(u32, words, 10);
                    if (id == 0) {
                        try list1.append(val);
                    }
                    if (id == 1) {
                        try list2.append(val);
                    }
                    id = id + 1;
                }
            }
        }
        index = index + 1;
    }

    const array1 = try list1.toOwnedSlice();
    const array2 = try list2.toOwnedSlice();

    std.mem.sort(u32, array1, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, array2, {}, comptime std.sort.asc(u32));
    const arrays = Arrays{
        .a1 = array1,
        .a2 = array2,
    };
    return arrays;
}

fn distance(array1: []u32, array2: []u32) u32 {
    var dist: u32 = 0;
    for (array1, array2) |itm1, itm2| {
        if (itm1 < itm2) {
            dist = dist + itm2 - itm1;
        } else {
            dist = dist + itm1 - itm2;
        }
    }
    return dist;
}

fn similarity(array1: []u32, array2: []u32) u32 {
    var index: u32 = 0;
    var repeats: u32 = 0;
    var repeatsLeft: u32 = 1;
    var score: u32 = 0;

    for (array1, 0..) |itm, i| {
        if (index < array2.len and itm < array2[index]) {
            repeats = 0;
        } else if (i < array1.len - 1 and itm == array1[i + 1]) {
            repeatsLeft = repeatsLeft + 1;
        } else {
            repeats = 0;
            while (index < array2.len and itm >= array2[index]) {
                if (itm == array2[index]) {
                    repeats = repeats + 1;
                }
                index = index + 1;
            }
            while (index < array2.len and itm > array2[index]) {
                index = index + 1;
            }
            score = score + itm * repeats * repeatsLeft;
            repeatsLeft = 1;
        }
    }
    return score;
}

test "Day 1 test part 1" {
    const file_path = "data/day1_test.txt";
    const data = try utils.readData(file_path);
    defer allocator.free(data);
    const arrays = try prepData(data);
    const dist = distance(arrays.a1, arrays.a2);
    try std.testing.expectEqual(@as(u32, 11), dist);
}

test "Day 2 test part 2" {
    std.debug.print("test 2 dag 1", .{});
    const file_path = "data/day1_test.txt";
    const data = try utils.readData(file_path);
    defer allocator.free(data);
    const arrays = try prepData(data);
    const score = similarity(arrays.a1, arrays.a2);
    try std.testing.expectEqual(@as(u32, 31), score);
}
