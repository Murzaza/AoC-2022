package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"


day15 :: proc(data: []u8, row, max_xy: i128) {
    sensors := make(map[[2]i128]i128)
    defer delete(sensors)

    // 0 - min, 1 - max
    row_range := [2]i128{0, 0}
    beacons_at_row := make(map[[2]i128]bool)
    defer delete(beacons_at_row)

    it := string(data)
    for line in strings.split_lines_iterator(&it) {
        parts := strings.split_multi(line, {"Sensor at x=", ", y=", ": closest beacon is at x="})[1:]
        //Should contain [s.x, s.y, b.x, b.y]
        sx, sx_ok := strconv.parse_i128(parts[0])
        if !sx_ok {
            fmt.printf("Unable to convert sx %s\n", parts[0])
            return
        }
        sy, sy_ok := strconv.parse_i128(parts[1])
        if !sy_ok {
            fmt.printf("Unable to convert sy %s\n", parts[1])
            return
        }
        sensor := [2]i128{sx, sy}

        bx, bx_ok := strconv.parse_i128(parts[2])
        if !bx_ok {
            fmt.printf("Unable to convert bx %s\n", parts[0])
            return
        }
        by, by_ok := strconv.parse_i128(parts[3])
        if !by_ok {
            fmt.printf("Unable to convert by %s\n", parts[1])
            return
        }
        beacon := [2]i128{bx, by}

        sensors[sensor] = manhattan_distance(sensor, beacon)

        check_min := sensor.x - sensors[sensor]
        check_max := sensor.x + sensors[sensor]
        row_range[0] = min(row_range[0], check_min)
        row_range[1] = max(row_range[1], check_max)

        if beacon.y == row {
            beacons_at_row[beacon] = true
        }
    }

    /* Part 1 */
    unplaceable := 0
    for i in row_range[0]..=row_range[1] {
        check := [2]i128{i, row}
        in_range := false
        if check in beacons_at_row {
            continue
        }
        for k, v in sensors {
            if manhattan_distance(k, check) <= v {
                in_range = true
                break
            }
        }
        if in_range {
            unplaceable += 1
        }
    }

    fmt.printf("Part 1: %v\n", unplaceable) 

    /* Part 2 */
    for x : i128 = 0; x <= max_xy; x += 1 {
        for y : i128 = 0; y <= max_xy; y += 1 {
            check := [2]i128{x, y}
            in_range := false

            for k, v in sensors {
                if manhattan_distance(k, check) <= v {
                    // scoot along to the edge.
                    y += v - manhattan_distance(k, check)
                    in_range = true
                    break
                }
            }

            if !in_range {
                fmt.printf("Part 2: %v\n", u128(4_000_000) * u128(check.x) + u128(check.y))
                return
            }
        }
    }
}

manhattan_distance :: proc(p1, p2: [2]i128) -> i128 {
    diff := p1 - p2
    return math.abs(diff.x) + math.abs(diff.y)
}

main :: proc() {
    data := #load("input.txt")
    day15(data, 2_000_000, 4_000_000)
}