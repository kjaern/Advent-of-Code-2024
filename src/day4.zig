const std = @import("std");
const utils = @import("utils.zig");
const allocator = std.heap.page_allocator;

const Data2d = struct {
    data: []u8,
    rows: usize,
    colms: usize,
    stride: usize,
};

pub fn main() !void {
    std.debug.print("\nday4\n\n", .{});
    var args = try std.process.argsWithAllocator(allocator);

    defer args.deinit();

    _ = args.skip();

    const file_path = args.next() orelse {
        std.debug.print("Please give a path to a input file\n", .{});
        return;
    };

    const data = try utils.readData(file_path);
    defer allocator.free(data);

    var itt = std.mem.split(u8, data, "\r\n");
    var da = Data2d{
        .data = data,
        .colms = 0,
        .rows = 0,
        .stride = 0,
    };

    while (itt.next()) |x| {
        if (x.len > 0) {
            da.rows += 1;
            da.colms = @intCast(x.len);
        }
    }
    da.stride = da.colms + 2;

    std.debug.print("rows {} colm {}\n", .{ da.rows, da.colms });
    const msg = "XMAS";
    const foundStr1 = findString(da, msg);
    const msg2 = "SAMX";
    const foundStr2 = findString(da, msg2);
    std.debug.print("total xmas {}\n", .{foundStr1 + foundStr2});

    const xval1 = findStringFilter(da, "MAS");
    const xval2 = findStringFilter(da, "SAM");
    std.debug.print("total x-mas {}\n", .{xval1 + xval2});
}

fn findStringFilter(data: Data2d, msg: *const [3:0]u8) u16 {
    var count: u16 = 0;
    var found: bool = true;

    for (1..data.rows - 1) |row| {
        for (1..data.colms - 1) |colm| {
            found =
                data.data[colm + data.stride * (row - 1) - 1] == msg[0] and
                data.data[colm + data.stride * (row - 1) + 1] == msg[0] and
                data.data[colm + data.stride * (row + 0) + 0] == msg[1] and
                data.data[colm + data.stride * (row + 1) - 1] == msg[2] and
                data.data[colm + data.stride * (row + 1) + 1] == msg[2] or
                data.data[colm + data.stride * (row - 1) - 1] == msg[0] and
                data.data[colm + data.stride * (row - 1) + 1] == msg[2] and
                data.data[colm + data.stride * (row + 0) + 0] == msg[1] and
                data.data[colm + data.stride * (row + 1) - 1] == msg[0] and
                data.data[colm + data.stride * (row + 1) + 1] == msg[2];
            if (found) {
                count += 1;
            }
            // if (found) {
            //     std.debug.print("+", .{});
            // } else {
            //     std.debug.print(".", .{});
            // }
        }
        // std.debug.print("\n", .{});
    }
    return count;
}
fn findString(data: Data2d, msg: []const u8) u16 {
    var count: u16 = 0;
    var found: bool = true;
    var foundDiagUp: bool = true;
    var foundDiagDown: bool = true;

    for (0..data.rows) |row| {
        for (0..data.colms - msg.len + 1) |colm| {
            found = true;
            for (0..msg.len) |i| {
                if (data.data[colm + data.stride * row + i] != msg[i]) {
                    found = false;
                }
            }
            if (found) {
                count += 1;
            }
        }
    }
    for (0..data.rows - msg.len + 1) |row| {
        for (0..data.colms) |colm| {
            found = true;
            for (0..msg.len) |i| {
                if (data.data[colm + data.stride * (row + i)] != msg[i]) {
                    found = false;
                }
            }
            if (found) {
                count += 1;
            }
        }
    }
    for (0..data.rows - msg.len + 1) |row| {
        for (0..data.colms - msg.len + 1) |colm| {
            found = true;
            foundDiagUp = true;
            foundDiagDown = true;
            for (0..msg.len) |i| {
                if (data.data[colm + data.stride * (row + i) + i] != msg[i]) {
                    foundDiagDown = false;
                }
                if (data.data[colm + data.stride * (row + i) + msg.len - i - 1] != msg[i]) {
                    foundDiagUp = false;
                }
            }
            if (foundDiagUp) {
                count += 1;
            }
            if (foundDiagDown) {
                count += 1;
            }
        }
    }
    return count;
}
