const std = @import("std");

const alloc = std.heap.smp_allocator;

pub fn main() !void {
    var r: i16 = 50;
    var passwd: i16 = 0;

    const file = try std.fs.cwd().openFile("data/d1.txt", .{ .mode = .read_only });
    const readbuf = try alloc.alloc(u8, 512);
    var reader = file.reader(readbuf);

    while (true) {
        const line_with_delim = reader.interface.takeDelimiterInclusive('\n') catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        const line = line_with_delim[0 .. line_with_delim.len - 1];
        const number = try std.fmt.parseInt(i16, line[1..], 10);
        switch (line[0]) {
            'L' => {
                if (r == 0) passwd -= 1;
                r = r - number;
                while (r < 0) {
                    passwd += 1;
                    r += 100;
                }
            },
            'R' => {
                r = r + number;
                while (r >= 100) {
                    passwd += 1;
                    r -= 100;
                }
                if (r == 0) passwd -= 1;
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
