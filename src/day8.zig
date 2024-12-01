const std = @import("std");
const utils = @import("utils.zig");
const allocator = std.heap.page_allocator;

pub fn main() !void {
    std.debug.print("\nday8\n\n", .{});
    var args = try std.process.argsWithAllocator(allocator);

    defer args.deinit();

    _ = args.skip();

    const file_path = args.next() orelse {
        std.debug.print("Please give a path to a input file\n", .{});
        return;
    };

    std.debug.print("{s}\n", .{file_path});
    const data = try utils.readData(file_path);

    var itt = std.mem.split(u8, data, "\r\n");

    while (itt.next()) |line| {
        if (line.len > 0) {
            std.debug.print("{s}\n", .{line});
        }
    }
}
