const std = @import("std");

const alloc = std.heap.smp_allocator;

pub fn main() !void {
    var count: usize = 0;

    const file = try std.fs.cwd().openFile("data/d2.txt", .{ .mode = .read_only });
    const readbuf = try alloc.alloc(u8, 512);
    var reader = file.reader(readbuf);

    var range_str_buf: [64]u8 = undefined;
    var id_str_buf: [32]u8 = undefined;
    var pattern_buf: [32]u8 = undefined;

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
            if (id_str_len == 1) continue;
            const id_str = id_str_buf[0..id_str_len];

            const half_id_str_len = @divTrunc(id_str_len, 2);
            for (1..half_id_str_len + 1) |pattern_size| {
                if (id_str_len % pattern_size != 0) continue;
                const max_pattern_match_count = id_str_len / pattern_size;
                for (0..pattern_size) |i| pattern_buf[i] = id_str[i];
                var pattern_match_count: u8 = 0;
                var i: usize = 0;
                while (i < id_str_len) : (i += pattern_size) {
                    if (std.mem.eql(u8, id_str[i .. i + pattern_size], pattern_buf[0..pattern_size])) {
                        pattern_match_count += 1;
                    }
                }
                if (pattern_match_count == max_pattern_match_count) {
                    count += id;
                    break;
                }
            }
        }
    }

    var stdout_w_buf: [8]u8 = undefined;
    var stdout_w = std.fs.File.stdout().writer(&stdout_w_buf);
    try stdout_w.interface.print("{}\n", .{count});
    try stdout_w.interface.flush();
}
