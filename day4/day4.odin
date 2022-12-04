package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

get_input :: proc(filepath: string) -> [dynamic]bool {
    input : [dynamic]bool
    data, ok := os.read_entire_file(filepath, context.allocator)
    if !ok {
        fmt.printf("Unable to read file: %s\n", filepath)
        return input
    }
    defer delete(data, context.allocator)

    it := string(data)
    for line in strings.split_lines_iterator(&it) {
        assignments := strings.split(line, ",")
        first := strings.split(assignments[0], "-")
        second := strings.split(assignments[1], "-")
        f_start := strconv.atoi(first[0])
        f_end := strconv.atoi(first[1])
        s_start := strconv.atoi(second[0])
        s_end := strconv.atoi(second[1])
        /* Part 1
        if f_start >= s_start && f_end <= s_end ||
            s_start >= f_start && s_end <= f_end {
            append(&input, true);
        }
        */
        /* Part 2 */
        if f_start >= s_start && f_start <= s_end ||
            s_start >= f_start && s_start <= f_end {
            append(&input, true);
        }
    }

    return input
}

main :: proc() {
    input := get_input("input.txt")
    fmt.println(len(input))
}
