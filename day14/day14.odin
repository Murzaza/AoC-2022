package main

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:math"

day14 :: proc(data: []u8, part_2: bool = false) {

    blocked := make(map[[2]int]bool)
    defer delete(blocked)

    lowest := 0
    sand_placed := 0

    it := string(data)
    for line in strings.split_lines_iterator(&it) {
        parts := strings.split(line, " -> ")

        for i in 1..<len(parts) {
            prev := make_coord(parts[i-1])
            curr := make_coord(parts[i])
            
            lowest = max(curr.y, lowest)

            diff := prev - curr
            if diff.x != 0 {
                for x in 0..=math.abs(diff.x) {
                    if diff.x > 0 {
                        blocked[[2]int{curr.x + x, curr.y}] = true
                    } else {
                        blocked[[2]int{curr.x - x, curr.y}] = true
                    }
                }
            } else {
                for y in 0..=math.abs(diff.y) {
                    if diff.y > 0 {
                        blocked[[2]int{curr.x, curr.y + y}] = true
                    } else {
                        blocked[[2]int{curr.x, curr.y - y}] = true
                    }
                }
            }
        }
    }

    if (!part_2) {
        placed := true
        for placed {
            sand := [2]int{500, 0}
            placed = place_sand(&blocked, sand, lowest) 
            if placed {
                sand_placed += 1
            }
        }
        fmt.printf("Part 1: %v\n", sand_placed)
    } else {
        placed := true
        for placed {
            sand := [2]int{500, 0}
            placed = place_sand_floored(&blocked, sand, lowest + 2)
            sand_placed += 1
        }
        fmt.printf("Part 2: %v\n", sand_placed)
    }

}

place_sand :: proc(blocked: ^map[[2]int]bool, sand: [2]int, lowest: int) -> bool {
    if sand.y > lowest {
        return false
    }

    holder := sand + [2]int{0, 1}
    down := holder in blocked
    if !down {
        return place_sand(blocked, holder, lowest)
    }

    holder -= [2]int{1, 0}
    left := holder in blocked
    if !left {
        return place_sand(blocked, holder, lowest)
    }

    holder += [2]int{2, 0}
    right := holder in blocked
    if !right {
        return place_sand(blocked, holder, lowest)
    }

    blocked[sand] = true
    return true
}

place_sand_floored :: proc(blocked: ^map[[2]int]bool, sand: [2]int, lowest: int) -> bool {
    if sand.y + 1 == lowest {
        blocked[sand] = true
        return true
    }

    holder := sand + [2]int{0, 1}
    down := holder in blocked
    if !down {
        return place_sand_floored(blocked, holder, lowest)
    }

    holder -= [2]int{1, 0}
    left := holder in blocked
    if !left {
        return place_sand_floored(blocked, holder, lowest)
    }

    holder += [2]int{2, 0}
    right := holder in blocked
    if !right {
        return place_sand_floored(blocked, holder, lowest)
    }

    blocked[sand] = true
    if (sand == [2]int{500, 0}) {
        return false
    }
    return true
}

make_coord :: proc(part: string) -> [2]int {
    pieces := strings.split(part, ",")
    x := strconv.atoi(pieces[0])
    y := strconv.atoi(pieces[1])
    return [2]int{x,y}
}

main :: proc() {
    data := #load("input.txt")
    day14(data, true)
}