const std = @import("std");
const utils = @import("utils.zig");
const allocator = std.heap.page_allocator;

fn readData(filename: []const u8) ![]u8 {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(filename, .{});
    defer file.close();
    const file_size = (try file.stat()).size;

    const content = try allocator.alloc(u8, file_size);

    const datasize = try std.fs.File.read(file, content);
    std.debug.assert(datasize == file_size);
    return content;
}

fn multDigits(val: i64) i64 {
    if (val < 10) return 10;
    if (val < 100) return 100;
    if (val < 1000) return 1000;
    if (val < 10000) return 10000;
    if (val < 100000) return 100000;
    if (val < 1000000) return 1000000;
    return 0;
}

fn checkResults(testResutl: i64, tmpResult: i64, numbers: []i64, pos: usize, checkCon: bool) bool {
    if (pos == numbers.len) {
        return testResutl == tmpResult;
    }
    if (tmpResult > testResutl) {
        return false;
    }
    if (checkResults(testResutl, tmpResult + numbers[pos], numbers, pos + 1, checkCon)) {
        return true;
    }
    if (checkResults(testResutl, tmpResult * numbers[pos], numbers, pos + 1, checkCon)) {
        return true;
    }
    if (checkCon and checkResults(testResutl, (multDigits(numbers[pos])) * tmpResult + numbers[pos], numbers, pos + 1, checkCon)) {
        return true;
    }
    return false;
}

fn check(data: []u8, useCon: bool) !i64 {
    var itt = std.mem.split(u8, data, "\r\n");

    var totalResult: i64 = 0;
    while (itt.next()) |line| {
        if (line.len > 0) {
            var lineItt = std.mem.split(u8, line, " ");

            var first: bool = true;
            var testResult: i64 = 0;

            var numbers = std.ArrayList(i64).init(allocator);
            defer numbers.deinit();

            while (lineItt.next()) |word| {
                if (first) {
                    testResult = std.fmt.parseInt(i64, word[0..@as(usize, word.len - 1)], 10) catch 0;
                    first = false;
                } else {
                    try numbers.append(std.fmt.parseInt(i64, word, 10) catch 0);
                }
            }

            const isValid: bool = checkResults(testResult, numbers.items[0], numbers.items, 1, useCon);
            if (isValid) {
                totalResult += testResult;
            }
        }
    }
    return totalResult;
}

pub fn main() !void {
    std.debug.print("\nday7\n\n", .{});
    var args = try std.process.argsWithAllocator(allocator);

    defer args.deinit();

    _ = args.skip();

    const file_path = args.next() orelse {
        std.debug.print("Please give a path to a input file\n", .{});
        return;
    };

    const data = try utils.readData(file_path);
    defer allocator.free(data);
    var result = try check(data, false);
    std.debug.print("total = {}\n", .{result});
    result = try check(data, true);
    std.debug.print("total = {}\n", .{result});
}

test "Day 7 part 1 test" {
    const file_path = "data/day7_test.txt";
    const data = try readData(file_path);
    defer allocator.free(data);
    const result = try check(data, false);
    try std.testing.expectEqual(3749, result);
}

test "Day 7 part 2 test" {
    const file_path = "data/day7_test.txt";
    const data = try readData(file_path);
    defer allocator.free(data);
    const result = try check(data, true);
    try std.testing.expectEqual(11387, result);
}
