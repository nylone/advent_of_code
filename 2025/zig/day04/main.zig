const std = @import("std");

fn getRowNum(file: std.fs.File) !usize {
    var buffer: [1024]u8 = undefined;
    var reader = file.reader(&buffer);
    var num: usize = 0;

    while (try reader.interface.takeDelimiter('\n')) |line| {
        _ = line;
        num = num + 1;
    }

    return num;
}

fn getColNum(file: std.fs.File) !usize {
    var buffer: [1024]u8 = undefined;
    var reader = file.reader(&buffer);
    var num: usize = 0;

    const line = (try reader.interface.takeDelimiter('\n')).?;
    for (line) |char| {
        _ = char;
        num = num + 1;
    }

    return num;
}

fn removeCrate(buffer: [][]u8, nrows: usize, ncols: usize) !u64 {
    var first_answer: u64 = 0;

    // Allocation of a copy of the buffer
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var buffer_copy = try allocator.alloc([]u8, nrows);

    for (buffer, 0..) |_, i| {
        buffer_copy[i] = try allocator.alloc(u8, ncols);
        for (buffer_copy[i], 0..) |_, j| {
            buffer_copy[i][j] = buffer[i][j];
        }
    }

    for (buffer, 0..) |row, row_index| {
        for (row, 0..) |cell, col_index| {
            if (cell == '@') {
                const i: usize = if (row_index != 0) row_index - 1 else row_index;
                const j: usize = if (col_index != 0) col_index - 1 else col_index;
                var rolls: u32 = 0;

                for (i..if (row_index < nrows - 1) row_index + 2 else row_index + 1) |check_i| {
                    for (j..if (col_index < ncols - 1) col_index + 2 else col_index + 1) |check_j| {
                        if (!(check_i == row_index and check_j == col_index) and buffer[check_i][check_j] == '@') {
                            rolls += 1;
                        }
                    }
                }
                if (rolls < 4) {
                    first_answer += 1;
                    buffer_copy[row_index][col_index] = '.';
                    //std.debug.print("position: [{d}][{d}], rolls: {d}\n", .{ row_index, col_index, rolls });
                }
            }
        }
    }

    @memcpy(buffer, buffer_copy);

    return first_answer;
}

pub fn main() !void {
    // File
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    // Allocation
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const nrows: usize = try getRowNum(file);
    const ncols: usize = try getColNum(file);

    var file_buffer: [1024]u8 = undefined;
    var reader = file.reader(&file_buffer);

    const buffer = try allocator.alloc([]u8, nrows);
    defer allocator.free(buffer);

    var index: usize = 0;

    while (try reader.interface.takeDelimiter('\n')) |row| {
        buffer[index] = try allocator.alloc(u8, ncols);
        @memcpy(buffer[index], row);

        index += 1;
    }

    // Execution
    var first_answer: u64 = 0;

    first_answer = try removeCrate(buffer, nrows, ncols);

    var second_answer: u64 = first_answer;
    var answer: u64 = first_answer;

    while (answer != 0) {
        answer = try removeCrate(buffer, nrows, ncols);
        second_answer += answer;
    }

    std.debug.print("\nFirst answer: {d}\n", .{first_answer});
    std.debug.print("\nSecond answer: {d}\n", .{second_answer});

    std.debug.print("\n-------------- CRASHING ON PURPOSE... --------------\n", .{});

    // Free
    for (buffer, 0..) |_, i| {
        allocator.free(buffer[i]);
    }
}
