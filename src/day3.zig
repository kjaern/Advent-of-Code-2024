const std = @import("std");
const utils = @import("utils.zig");
const allocator = std.heap.page_allocator;

fn doMult(data: []const u8) i32 {
    var itt = std.mem.split(u8, data, "mul(");
    var sum: i32 = 0;
    while (itt.next()) |x| {
        // std.debug.print("{s}\n", .{x});
        var wordItt = std.mem.split(u8, x, ",");

        var num1: i32 = 0;
        var num2: i32 = 0;
        if (wordItt.next()) |y| {
            num1 = std.fmt.parseInt(i32, y, 10) catch 0;
        }
        if (wordItt.next()) |y| {
            var wordItt2 = std.mem.split(u8, y, ")");

            if (wordItt2.next()) |y2| {
                num2 = std.fmt.parseInt(i32, y2, 10) catch 0;
                sum = sum + num1 * num2;
            }
        }
    }
    return sum;
}

fn correctBranching(data: []u8) i32 {
    var ittDont = std.mem.split(u8, data, "don't()");
    var sum: i32 = 0;
    const first = ittDont.first();

    sum = sum + doMult(first);

    while (ittDont.next()) |x| {
        var itt = std.mem.split(u8, x, "do()");
        if (itt.next()) |y| {
            sum = sum + doMult(x[y.len..]);
        }
    }
    return sum;
}

pub fn main() !void {
    std.debug.print("\nday3\n\n", .{});
    var args = try std.process.argsWithAllocator(allocator);

    defer args.deinit();

    _ = args.skip();

    const file_path = args.next() orelse {
        std.debug.print("Please give a path to a input file\n", .{});
        return;
    };

    const data = try utils.readData(file_path);
    defer allocator.free(data);
    var sum: i32 = 0;

    sum = doMult(data);
    std.debug.print("sum {}\n", .{sum});

    sum = correctBranching(data);
    std.debug.print("sum2 {}\n", .{sum});
    // 82045421
}
