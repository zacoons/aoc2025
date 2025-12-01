const std = @import("std");

const alloc = std.heap.smp_allocator;

pub fn main() !void {
    var r: i16 = 50;
    var passwd: u16 = 0;

    const file = try std.fs.cwd().openFile("data/d1.txt", .{ .mode = .read_only });
    const readbuf = try alloc.alloc(u8, 512);
    var reader = file.reader(readbuf);

    var linebuf: [4]u8 = undefined;

    while (true) {
        var linebuf_w = std.Io.Writer.fixed(&linebuf);
        const n = reader.interface.streamDelimiter(&linebuf_w, '\n') catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        reader.interface.toss(1); // Skip over the delimiter itself
        const line = linebuf[0..n];
        const number = try std.fmt.parseInt(i16, line[1..], 10);
        switch (line[0]) {
            'L' => {
                r = r - number;
                while (r < 0) r += 100;
            },
            'R' => {
                r = @mod(r + number, 100);
            },
            else => return error.InvalidFormat,
        }

        if (r == 0) {
            passwd += 1;
        }
    }

    var stdout_w_buf: [2]u8 = undefined;
    var stdout_w = std.fs.File.stdout().writer(&stdout_w_buf);
    try stdout_w.interface.print("{}\n", .{passwd});
    try stdout_w.interface.flush();
}
