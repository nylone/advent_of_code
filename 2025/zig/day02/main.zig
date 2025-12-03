const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buffer: [1024]u8 = undefined;
    var reader = file.reader(&buffer);
    var firstanswer: u64 = 0;
    var secondanswer: u64 = 0;

    while (try reader.interface.takeDelimiter('\n')) |line| {
        var sequence = std.mem.splitAny(u8, line, ",");
        while (sequence.next()) |next| {
            var subseq = std.mem.splitSequence(u8, next, "-");
            var ID: u64 = try std.fmt.parseInt(u64, subseq.first(), 10);

            if (subseq.next()) |subnext| {
                const LastID: u64 = try std.fmt.parseInt(u64, subnext, 10);
                while (ID <= LastID) {
                    // Parses ID as a String for easier manipulation
                    var buff: [128]u8 = undefined;
                    const temp = try std.fmt.bufPrint(&buff, "{d}", .{ID});

                    const len = temp.len;
                    var occ: u8 = 0;
                    var templen: u16 = @intCast(len);

                    // First answer
                    while (templen > 1 and occ < 1) {
                        templen = try std.math.divCeil(u16, templen, 2);
                        const secondlen: u16 = @intCast(temp[templen..].len);
                        const firstvalue: u64 = try std.fmt.parseInt(u64, temp[0..templen], 10);
                        const secondvalue: u64 = try std.fmt.parseInt(u64, temp[templen..], 10);

                        if (firstvalue == secondvalue and temp[templen..][0] != '0') {
                            firstanswer = firstanswer + ID;
                            secondanswer = secondanswer + ID;
                            occ = occ + 1;

                            // Second answers
                        } else if (templen < secondlen) {
                            const secondhalf = temp[templen..];
                            const step: u16 = templen;
                            var i: u16 = 0;

                            while (i < secondlen) {
                                if (!(i + step > secondlen)) {
                                    const subvalue: u64 = try std.fmt.parseInt(u64, secondhalf[i .. i + step], 10);
                                    if (firstvalue == subvalue and secondhalf[0] != '0') {
                                        occ = occ + 1;
                                        i = i + step;
                                    } else {
                                        occ = 0;
                                        i = 0;
                                        break;
                                    }
                                } else {
                                    break;
                                }
                            }

                            if (occ >= 2 and i == secondlen) {
                                secondanswer = secondanswer + ID;
                            } else {
                                occ = 0;
                            }
                        } else if (templen >= secondlen) {}
                    }

                    ID = ID + 1;
                }
            }
        }
    }

    std.debug.print("first answer: {d}\n", .{firstanswer});
    std.debug.print("second answer: {d}", .{secondanswer});
}
