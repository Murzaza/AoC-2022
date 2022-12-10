package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"

Position :: [2]int

parse_input :: proc(data: []u8) {
    direction_map := map[rune]Position{
        'U' = Position{  0,  1 },
        'D' = Position{  0, -1 },
        'R' = Position{  1,  0 },
        'L' = Position{ -1,  0 },
    }

    knots := [10]Position{
        Position{ 0, 0 },
        Position{ 0, 0 },
        Position{ 0, 0 },
        Position{ 0, 0 },
        Position{ 0, 0 },
        Position{ 0, 0 },
        Position{ 0, 0 },
        Position{ 0, 0 },
        Position{ 0, 0 },
        Position{ 0, 0 },
    }

    tail_locations : [dynamic]Position
    defer delete(tail_locations)

    knot9_locations : [dynamic]Position
    defer delete(knot9_locations)

    append(&tail_locations, knots[1]) // For part 1
    append(&knot9_locations, knots[9]) // For part 2

    it := string(data)
    for line in strings.split_lines_iterator(&it) {
        parts := strings.split(line, " ")
        direction := rune(parts[0][0])
        steps := strconv.atoi(parts[1])

        for i := 0; i < steps; i += 1 {
            knots[0] += direction_map[direction]
            for i := 1; i < len(knots); i += 1 {
                if !is_head_near_tail(&knots[i-1], &knots[i]) {
                    move_tail(&knots[i-1], &knots[i])
                } else {
                    // We don't need to keep going if the knot didn't move
                    break
                }
            }
            
            add_location(&tail_locations, &knots[1])
            add_location(&knot9_locations, &knots[9])
        }
    }

    fmt.printf("Part 1: %d\n", len(tail_locations))
    fmt.printf("Part 2: %d\n", len(knot9_locations))
}

move_tail :: proc(head: ^Position, tail: ^Position) {
    diff := head^ - tail^
    delta := Position{0, 0}
    if diff.x > 0 {
        delta.x += 1
    } else if diff.x < 0 {
        delta.x -= 1
    }

    if diff.y > 0 {
        delta.y += 1
    } else if diff.y < 0 {
        delta.y -= 1
    }

    tail^ += delta
}

is_head_near_tail :: proc(head: ^Position, tail: ^Position) -> bool {
    if math.abs(head.x - tail.x) >= 2 ||
        math.abs(head.y - tail.y) >= 2 {
            return false
        }
    return true
}

add_location :: proc(locations: ^[dynamic]Position, tail: ^Position) {
    for loc in locations {
        if loc.x == tail.x && loc.y == tail.y {
            // Don't add anything it's already there
            return
        }
    }

    append(locations, tail^)
}

main :: proc() {
    data := #load("input.txt")
    parse_input(data)
}