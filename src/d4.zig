const std = @import("std");

const alloc = std.heap.smp_allocator;

const Grid = struct {
    data: []u8,
    w: i32,
    h: i32,

    pub fn at(grid: Grid, x: i32, y: i32) u8 {
        if (x < 0 or y < 0 or x >= grid.w or y >= grid.h) return '.';
        return grid.data[@intCast(y * (grid.w + 1) + x)];
    }
};

pub fn main() !void {
    var count: u32 = 0;

    const file = try std.fs.cwd().readFileAlloc(alloc, "data/d4.txt", 1024 * 1024);
    var grid_w: i32 = undefined;
    var grid_h: i32 = undefined;
    var i: usize = 0;
    while (i < file.len) : (i += 1) {
        if (file[i] == '\n') {
            grid_w = @intCast(i);
            break;
        }
    }
    grid_h = @divExact(@as(i32, @intCast(file.len)), grid_w + 1);
    const grid = Grid{ .data = file, .w = grid_w, .h = grid_h };

    var y: i32 = 0;
    while (y < grid.h) : (y += 1) {
        var x: i32 = 0;
        while (x < grid.w) : (x += 1) {
            if (grid.at(x, y) == '@') {
                var adjacent_rolls: u8 = 0;
                adjacent_rolls += @intFromBool(grid.at(x - 1, y - 1) == '@');
                adjacent_rolls += @intFromBool(grid.at(x, y - 1) == '@');
                adjacent_rolls += @intFromBool(grid.at(x + 1, y - 1) == '@');
                adjacent_rolls += @intFromBool(grid.at(x - 1, y) == '@');
                // adjacent_rolls += @intFromBool(grid.at(x, y) == '@');
                adjacent_rolls += @intFromBool(grid.at(x + 1, y) == '@');
                adjacent_rolls += @intFromBool(grid.at(x - 1, y + 1) == '@');
                adjacent_rolls += @intFromBool(grid.at(x, y + 1) == '@');
                adjacent_rolls += @intFromBool(grid.at(x + 1, y + 1) == '@');
                if (adjacent_rolls < 4) count += 1;
            }
        }
    }

    std.debug.print("{}\n", .{count});
}
