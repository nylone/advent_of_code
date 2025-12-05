const std = @import("std");

const Value = struct {
    max: u8,
    pos: usize,
};

fn getMax(line: []u8, pos: usize, len: usize) Value {
    var value: Value = undefined;
    value.max = '1';
    value.pos = 0;

    var i: usize = pos;

    while (i < pos + len) {
        if (value.max < line[i]) {
            value.max = line[i];
            value.pos = i;
        } else if (line[i] == '1' and value.max == '1') {
            value.pos = i;
        }

        i = i + 1;
    }

    return value;
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buffer: [1024]u8 = undefined;
    var reader = file.reader(&buffer);

    var i: u16 = 0;
    var answer: u64 = 0;

    while (try reader.interface.takeDelimiter('\n')) |line| {
        var pos: usize = 0;
        var index: usize = 0;
        var combination: [12]u8 = undefined;
        var remaining: usize = 12; // 2 for the first solution
        var linelen: usize = line.len;

        while (remaining > 0) {
            remaining = remaining - 1;
            const len: usize = linelen - remaining;
            const max: Value = getMax(line, pos, len);

            combination[index] = max.max;

            pos = max.pos + 1;
            linelen = line.len - pos;
            index = index + 1;
        }

        answer = answer + try std.fmt.parseInt(u64, &combination, 10);

        i = i + 1;
    }

    std.debug.print("answer: {d}\n", .{answer});
}
