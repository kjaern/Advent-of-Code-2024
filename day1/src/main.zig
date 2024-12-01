const std = @import("std");

pub fn main() !void {
    const cwd = std.fs.cwd();

    const file = try cwd.openFile("data.txt", .{});
    defer file.close();
    const file_size = (try file.stat()).size;

    const allocator = std.heap.page_allocator;
    const content = try allocator.alloc(u8, file_size);
    defer allocator.free(content);

    const datasize = try std.fs.File.read(file, content);
    std.debug.assert(datasize == file_size);

    var iter = std.mem.split(u8, content, "\r\n");
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

    distance(array1, array2);
    similarity(array1, array2);
}

fn distance(array1: []u32, array2: []u32) void {
    var dist: u32 = 0;
    for (array1, array2) |itm1, itm2| {
        if (itm1 < itm2) {
            dist = dist + itm2 - itm1;
        } else {
            dist = dist + itm1 - itm2;
        }
    }
    std.debug.print("dist = {}\n", .{dist});
}

fn similarity(array1: []u32, array2: []u32) void {
    var index: u32 = 0;
    var repeats: u32 = 0;
    var repeatsLeft: u32 = 1;
    var score: u32 = 0;
    var previous: u32 = 0;

    for (array1) |itm| {
        if (index < array2.len and itm < array2[index]) {
            previous = itm;
            repeats = 0;
        } else if (previous == itm) {
            repeatsLeft = repeatsLeft + 1;
        } else {
            previous = itm;
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
    std.debug.print("score = {}\n", .{score});
}
