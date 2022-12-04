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
    for line in strings.split_lines_iterator(&it) {
        append(&input, strconv.atoi(line))
    }

    return input
}

find_2020_addition_of_2 :: proc(input: [dynamic]int) -> int {
    first := 0
    last := len(input) - 1
    total := input[first] + input[last];
    for total != 2020 {
        if total > 2020 {
            last -= 1
        }
        if total < 2020 {
            first += 1
        } 
        total = input[first] + input[last]
    }
    product := input[first] * input[last];
    return product
}

find_2020_addition_of_3 :: proc(input: [dynamic]int) -> int {
    for item in input {
        goal := 2020 - item
        first := 0
        last := len(input) - 1
        total := input[first] + input[last]
        for total != goal && first < last {
            if total > goal {
                last -= 1
            }
            if total < goal {
                first += 1
            }
            total = input[first] + input[last]
        }
        if goal == total {
            return item * input[first] * input[last]
        }
    }
    return 0
}

main :: proc() {
    input := get_input("input.txt")
    slice.sort(input[:])
    for item in input {
        fmt.printf("%d\n", item)
    }

    fmt.printf("%d\n", find_2020_addition_of_2(input))
    fmt.printf("%d\n", find_2020_addition_of_3(input))
}