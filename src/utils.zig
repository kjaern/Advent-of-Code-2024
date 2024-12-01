const std = @import("std");
const allocator = std.heap.page_allocator;

pub fn readData(filename: []const u8) ![]u8 {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(filename, .{});
    defer file.close();
    const file_size = (try file.stat()).size;

    std.debug.print("file size {}\n", .{file_size});
    const content = try allocator.alloc(u8, file_size);

    const datasize = try std.fs.File.read(file, content);
    std.debug.assert(datasize == file_size);
    return content;
}
