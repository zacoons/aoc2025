const std = @import("std");

const alloc = std.heap.smp_allocator;

pub fn main() !void {
    var count: usize = 0;

    const file = try std.fs.cwd().openFile("data/d2.txt", .{ .mode = .read_only });
    const readbuf = try alloc.alloc(u8, 512);
    var reader = file.reader(readbuf);

    var range_str_buf: [64]u8 = undefined;
    var id_str_buf: [32]u8 = undefined;

    while (true) {
        var range_str_buf_w = std.Io.Writer.fixed(&range_str_buf);
        const n = reader.interface.streamDelimiter(&range_str_buf_w, ',') catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        reader.interface.toss(1); // Skip over the delimiter itself
        const range_str = range_str_buf[0..n];
        const hyphen_idx = std.mem.indexOfScalar(u8, range_str, '-').?;
        const left = try std.fmt.parseInt(usize, range_str[0..hyphen_idx], 10);
        const right = try std.fmt.parseInt(usize, range_str[hyphen_idx + 1 ..], 10);
        for (left..right + 1) |id| {
            const id_str_len = std.fmt.printInt(&id_str_buf, id, 10, .lower, .{});
            const id_str = id_str_buf[0..id_str_len];
            if (id_str.len % 2 != 0) continue;
            const half_id_str_len = @divExact(id_str_len, 2);
            const id_str_left = id_str[0..half_id_str_len];
            const id_str_right = id_str[half_id_str_len..];
            if (std.mem.eql(u8, id_str_left, id_str_right)) {
                count += id;
            }
        }
    }

    var stdout_w_buf: [8]u8 = undefined;
    var stdout_w = std.fs.File.stdout().writer(&stdout_w_buf);
    try stdout_w.interface.print("{}\n", .{count});
    try stdout_w.interface.flush();
}
