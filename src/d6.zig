const std = @import("std");

const alloc = std.heap.smp_allocator;

const Symbol = enum {
    add,
    mult,
};

pub fn main() !void {
    const file = try std.fs.cwd().openFile("data/d6.txt", .{ .mode = .read_only });
    const readbuf = try alloc.alloc(u8, 512);
    var reader = file.reader(readbuf);

    var linebuf: [1024 * 1024]u8 = undefined;

    var rows: std.ArrayList([]u64) = try .initCapacity(alloc, 4);
    var symbols: []Symbol = undefined;

    while (true) {
        var linebuf_w = std.Io.Writer.fixed(&linebuf);
        const n = try reader.interface.streamDelimiterEnding(&linebuf_w, '\n');
        if (n == 0) break;
        reader.interface.toss(1); // Skip over the delimiter itself
        const line = linebuf[0..n];

        if (line[0] == '+' or line[0] == '*') {
            var row: std.ArrayList(Symbol) = try .initCapacity(alloc, 4);

            var start_i: usize = 0;
            while (std.mem.indexOfAnyPos(u8, line, start_i, &.{ '+', '*' })) |i| {
                start_i = i + 1;
                const symbol: Symbol = switch (line[i]) {
                    '+' => .add,
                    '*' => .mult,
                    else => return error.InvalidSymbol,
                };
                try row.append(alloc, symbol);
            }

            symbols = try row.toOwnedSlice(alloc);
        } else {
            var row: std.ArrayList(u64) = try .initCapacity(alloc, 4);

            var start_index: usize = std.mem.indexOfNone(u8, line, &.{' '}).?;
            var end_index: usize = undefined;
            while (true) {
                end_index = std.mem.indexOfScalarPos(u8, line, start_index + 1, ' ') orelse n;
                const num = try std.fmt.parseInt(u64, line[start_index..end_index], 10);
                try row.append(alloc, num);
                if (end_index == n) break;
                start_index = std.mem.indexOfNonePos(u8, line, end_index + 1, &.{' '}) orelse break;
            }

            try rows.append(alloc, try row.toOwnedSlice(alloc));
        }
    }

    std.debug.print("{any}\n", .{rows});
    std.debug.print("{any}\n", .{symbols});

    var sum: u64 = 0;

    for (0..rows.items[0].len) |col| {
        const symbol = symbols[col];
        var local_sum: u64 = 0;
        switch (symbol) {
            .add => {
                for (rows.items) |row| local_sum += row[col];
            },
            .mult => {
                local_sum = 1;
                for (rows.items) |row| local_sum *= row[col];
            },
        }
        sum += local_sum;
    }

    std.debug.print("{}\n", .{sum});
}
