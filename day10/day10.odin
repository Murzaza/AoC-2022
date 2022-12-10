package main

import "core:fmt"
import "core:strings"
import "core:strconv"

parse_input :: proc(data: []u8) {

    x := 1
    cycles : [dynamic]int
    defer delete(cycles)

    it := string(data)
    for line in strings.split_lines_iterator(&it) {
        parts := strings.split(line, " ")
        instruction := parts[0] 
        if strings.compare(instruction, "noop") == 0 {
            append(&cycles, x)
        } else { //addx 
            for i := 0; i < 2; i += 1 {
                append(&cycles, x)
            }
            add := strconv.atoi(parts[1])
            x += add
        }
    }

    /* Part 1 */
    signals := [6]int{
        20,
        60,
        100,
        140,
        180,
        220,
    }
    sum := 0
    for signal in signals {
        ss := get_signal_strength(&cycles, signal)
        sum += ss
    }
    fmt.printf("Part 1: %d\n", sum)

    /* Part 2 */
    fmt.printf("\nPart 2:")
    for i := 0; i < len(cycles); i += 1 {
        pixel := i % 40
        if pixel == 0 {
            fmt.println()
        }
        fmt.print(get_pixel(pixel, cycles[i]))
    }
}

get_signal_strength :: proc(cycles: ^[dynamic]int, cycle: int) -> int {
    return cycle * cycles[cycle - 1]
}

get_pixel :: proc(cycle, x : int) -> rune {
    if x - 1 <= cycle && x + 1 >= cycle {
        return '#'
    }
    return '.'
}

main :: proc() {
    data := #load("input.txt")
    parse_input(data)
}