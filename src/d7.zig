const std = @import("std");

const alloc = std.heap.smp_allocator;

pub fn main() !void {
    var timer = try std.time.Timer.start();

    const file = try std.fs.cwd().readFileAlloc(alloc, "data/d7.txt", 1024 * 1024);
    const w = std.mem.indexOfScalar(u8, file, '\n').? + 1;

    var count: u32 = 0;

    const beams = try alloc.alloc(bool, w);
    beams[std.mem.indexOfScalar(u8, file, 'S').?] = true;
    var i: usize = w;
    while (i < file.len) : (i += w) {
        const line = file[i .. i + w];
        var start_x: usize = 0;
        while (std.mem.indexOfScalarPos(u8, line, start_x, '^')) |splitter_x| : (start_x = splitter_x + 1) {
            if (beams[splitter_x]) {
                beams[splitter_x] = false;
                beams[splitter_x - 1] = true;
                beams[splitter_x + 1] = true;
                count += 1;
            }
        }
    }

    std.debug.print("{} {D}\n", .{ count, timer.read() });
}
