package main 

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

get_input :: proc(filepath: string) -> [dynamic]int {
    input : [dynamic]int
    data, ok := os.read_entire_file(filepath, context.allocator)    
    if !ok {
        fmt.printf("Unable to read file: %s\n", filepath)
        return input
    }
    defer delete(data, context.allocator)

    it := string(data)
    acc := 0
    for line in strings.split_lines_iterator(&it) {
        if (strings.compare(line, "") != 0) {
            acc += strconv.atoi(line)
        } else {
            append(&input, acc)
            acc = 0
        }
    }

    return input
}

main :: proc() {
    input := get_input("input.txt")
    first := 0 
    second := 0 
    third := 0
    for item in input {
        if item > first {
            third = second
            second = first
            first = item
        } else if item > second {
            third = second
            second = item
        } else if item > third {
            third = item
        }
    }

    fmt.printf("%d\n", first + second + third)
}