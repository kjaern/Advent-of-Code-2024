const std = @import("std");
const utils = @import("utils.zig");
const allocator = std.heap.page_allocator;

const Rule = struct {
    before: usize,
    after: usize,
};

const Area = struct {
    data: []u8,
    width: usize,
    hight: usize,
    stride: usize,
};

const Guard = struct {
    x: usize,
    y: usize,
    dir: Direction,

    fn check(
        self: *Guard,
        area: *const Area,
    ) bool {
        return self.x >= 0 and self.x < area.width and self.y >= 0 and self.y < area.hight;
    }

    fn makeStep(self: *Guard, area: *const Area, visited: *const Area) bool {
        switch (self.dir) {
            Direction.up => {
                if (self.y == 0) {
                    return false;
                }

                if (area.data[(self.y - 1) * area.stride + self.x] == '#') {
                    self.dir = Direction.right;
                } else {
                    self.y -= 1;
                }
                visited.data[self.y * visited.stride + self.x] = 42;
                return true;
            },
            Direction.right => {
                if (self.x == area.width - 1) {
                    return false;
                }

                if (area.data[self.y * area.stride + self.x + 1] == '#') {
                    self.dir = Direction.down;
                } else {
                    self.x += 1;
                }
                visited.data[self.y * visited.stride + self.x] = 42;
                return true;
            },

            Direction.down => {
                if (self.y == area.hight - 1) {
                    return false;
                }

                if (area.data[(self.y + 1) * area.stride + self.x] == '#') {
                    self.dir = Direction.left;
                } else {
                    self.y += 1;
                }
                visited.data[self.y * visited.stride + self.x] = 42;
                return true;
            },

            Direction.left => {
                if (self.x == 0) {
                    return false;
                }

                if (area.data[self.y * area.stride + self.x - 1] == '#') {
                    self.dir = Direction.up;
                } else {
                    self.x -= 1;
                }
                visited.data[self.y * visited.stride + self.x] = 42;
                return true;
            },
        }
    }
};

const Direction = enum(u8) {
    up = 0,
    right = 1,
    down = 2,
    left = 3,
};

pub fn main() !void {
    std.debug.print("\nday6\n\n", .{});
    var args = try std.process.argsWithAllocator(allocator);

    defer args.deinit();

    _ = args.skip();

    const file_path = args.next() orelse {
        std.debug.print("Please give a path to a input file\n", .{});
        return;
    };
    // std.debug.print("{s}", .{file_path});

    const data = try utils.readData(file_path);
    defer allocator.free(data);

    var itt = std.mem.split(u8, data, "\r\n");
    var lines: usize = 0;
    var charsPrLine: usize = 0;

    var guard = Guard{
        .x = 0,
        .y = 0,
        .dir = Direction.up,
    };
    var guardX: usize = 0;
    var guardY: usize = 0;

    while (itt.next()) |line| {
        if (line.len > 0) {
            if (lines == 0) {
                charsPrLine = @intCast(line.len);
            } else {
                std.debug.assert(charsPrLine == line.len);
            }
            for (line, 0..) |c, i| {
                if (c == '^') {
                    guardX = @intCast(i);
                    guardY = lines;
                }
            }
            lines += 1;
        }
    }
    guard.x = guardX;
    guard.y = guardY;

    const area = Area{
        .data = data,
        .width = charsPrLine,
        .hight = lines,
        .stride = charsPrLine + 2,
    };

    const visitedData: []u8 = try allocator.alloc(u8, @intCast(charsPrLine * lines));
    defer allocator.free(visitedData);

    const wisitedArea = Area{
        .data = visitedData,
        .width = charsPrLine,
        .hight = lines,
        .stride = charsPrLine,
    };

    // for (0..@intCast(area.hight)) |y| {
    //     std.debug.print("{s}\n", .{area.data[y * area.stride .. y * area.stride + area.width]});
    // }
    // std.debug.print("{}\n", .{'^'});
    // std.debug.print("* {}\n", .{'*'});
    // std.debug.print("# {}\n", .{'#'});
    // std.debug.print("^ {}\n", .{'^'});
    wisitedArea.data[guard.y * wisitedArea.stride + guard.x] = 42;

    while (guard.makeStep(&area, &wisitedArea)) {
        // std.debug.print("{}\n", .{guard});
    }

    var steps: u32 = 0;
    for (0..@intCast(wisitedArea.hight)) |y| {
        for (0..@intCast(wisitedArea.width)) |x| {
            if (wisitedArea.data[y * wisitedArea.stride + x] == 42) {
                steps += 1;
            }
        }
        // std.debug.print("{s}\n", .{wisitedArea.data[y * wisitedArea.stride .. y * wisitedArea.stride + wisitedArea.width]});
    }
    std.debug.print("visited {}\n", .{steps});
    steps = 0;

    for (0..@intCast(area.hight)) |y| {
        for (0..@intCast(area.width)) |x| {
            if (wisitedArea.data[y * wisitedArea.stride + x] == 42) {
                if (area.data[y * area.stride + x] != 35 and area.data[y * area.stride + x] != 94) {
                    const tmp: u8 = area.data[y * area.stride + x];

                    area.data[y * area.stride + x] = '#';
                    guard.x = guardX;
                    guard.y = guardY;
                    guard.dir = Direction.up;

                    const visitedData2: []u8 = try allocator.alloc(u8, @intCast(charsPrLine * lines));
                    defer allocator.free(visitedData2);
                    const wisitedArea2 = Area{
                        .data = visitedData2,
                        .width = charsPrLine,
                        .hight = lines,
                        .stride = charsPrLine,
                    };

                    var guardsPos = std.ArrayList(Guard).init(allocator);
                    defer guardsPos.deinit();

                    loop: while (guard.makeStep(&area, &wisitedArea2)) {
                        for (guardsPos.items) |gg| {
                            if (gg.x == guard.x and gg.y == guard.y and gg.dir == guard.dir) {
                                steps += 1;
                                // std.debug.print("found one {} {} {}\n", .{ steps, x, y });
                                break :loop;
                            }
                        }
                        const g = Guard{
                            .x = guard.x,
                            .y = guard.y,
                            .dir = guard.dir,
                        };

                        try guardsPos.append(g);
                    }
                    area.data[y * area.stride + x] = tmp;
                }
            }
        }
    }
    std.debug.print("visited {}\n", .{steps});
}
