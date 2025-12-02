const std = @import("std");

pub fn main() !void {
    // Read Input File
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buffer: [1024]u8 = undefined;
    var reader = file.reader(&buffer);
    var first_answer: i16 = 0;
    var second_answer: i16 = 0;
    var sum: i16 = 50;

    while (try reader.interface.takeDelimiter('\n')) |line| {
        const direction = line[0..1];
        const temp: []u8 = line[1..line.len];
        const amount = try std.fmt.parseInt(i16, temp, 10);

        const mult: i16 = @divFloor(amount, 100); // Number of times the zero is clicked
        if (mult > 0) {
            second_answer = second_answer + mult;
        }

        // we take the remaining value from the amount
        const r: i16 = @mod(amount, 100);

        if (std.ascii.eqlIgnoreCase(direction, "L")) {
            if (sum - r <= 0 and sum != 0) {
                second_answer = second_answer + 1;
            }

            sum = @mod(sum - r, 100);
        } else if (std.ascii.eqlIgnoreCase(direction, "R")) {
            if (sum + r >= 100) {
                second_answer = second_answer + 1;
            }
            sum = @mod(sum + r, 100);
        }

        if (sum == 0) {
            first_answer = first_answer + 1;
        }
    }

    std.debug.print("First Password: {}\n", .{first_answer});
    std.debug.print("Second Password: {}\n", .{second_answer});
}
