const std = @import("std");
const utils = @import("utils.zig");
const allocator = std.heap.page_allocator;

const Rule = struct {
    before: u32,
    after: u32,
};

const RuleChecker = struct {
    const self = @This();

    ruleList: std.ArrayList(Rule),
    pub fn compare(context: self, a: u32, b: u32) bool {
        for (context.ruleList.items) |rule| {
            if (rule.before == b and rule.after == a) {
                return false;
            }
        }
        return true;
    }
};

pub fn main() !void {
    std.debug.print("\nday5\n\n", .{});
    var args = try std.process.argsWithAllocator(allocator);

    defer args.deinit();

    _ = args.skip();

    const file_path = args.next() orelse {
        std.debug.print("Please give a path to a input file\n", .{});
        return;
    };

    const dataRules = try utils.readData(file_path);
    defer allocator.free(dataRules);

    var ruleList = std.ArrayList(Rule).init(allocator);
    defer ruleList.deinit(); // try commenting this out and see if zig detects the memory leak!

    var itt = std.mem.split(u8, dataRules, "\r\n");
    firstSection: while (itt.next()) |line| {
        var ittWord = std.mem.split(u8, line, "|");
        if (line.len == 0) {
            break :firstSection;
        }

        var before: u32 = 0;
        var after: u32 = 0;

        if (ittWord.next()) |y| {
            before = std.fmt.parseUnsigned(u32, y, 10) catch 0;
        }

        if (ittWord.next()) |y| {
            after = std.fmt.parseUnsigned(u32, y, 10) catch 0;
        }
        if (before > 0 and after > 0) {
            const rule = Rule{ .before = before, .after = after };
            try ruleList.append(rule);
        }
    }
    const ruleChecker = RuleChecker{ .ruleList = ruleList };

    var sum: u32 = 0;
    var sumSorted: u32 = 0;
    var success: bool = true;
    while (itt.next()) |line| {
        success = true;
        var pageList = std.ArrayList(u32).init(allocator);
        defer pageList.deinit();
        if (line.len > 0) {
            var ittWord = std.mem.split(u8, line, ",");
            var page: u32 = 0;
            while (ittWord.next()) |word| {
                page = std.fmt.parseUnsigned(u32, word, 10) catch 0;
                try pageList.append(page);
            }
            hmm: for (pageList.items, 0..) |itm, i| {
                for (pageList.items[i..]) |itm2| {
                    for (ruleList.items) |rule| {
                        if (rule.before == itm2 and rule.after == itm) {
                            std.mem.sort(u32, pageList.items, ruleChecker, comptime RuleChecker.compare);

                            sumSorted += pageList.items[pageList.items.len / 2];
                            success = false;
                            break :hmm;
                        }
                    }
                }
            }

            if (success) {
                sum += pageList.items[pageList.items.len / 2];
            }
        }
    }
    std.debug.print("Sum {}\n", .{sum});
    std.debug.print("Sorted sum {}\n", .{sumSorted});
}
