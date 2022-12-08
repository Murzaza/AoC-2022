package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import queue "core:container/queue"

parse_input :: proc(data: []u8) {
    dir_size := make(map[string]uint)
    defer delete(dir_size)
    
    dir_stack : [dynamic]string
    defer delete(dir_stack)

    it := string(data)
    for line in strings.split_lines_iterator(&it) {
        if strings.contains(line, "dir ") || strings.contains(line, "$ ls") {
            // We can ignore these.
            continue
        }

        // Check stack operations
        if strings.compare(line, "$ cd ..") == 0 {
            pop(&dir_stack)
            continue
        } else if strings.contains(line, "$ cd") {
            // Build the full path of the dir
            dir_name_builder := strings.Builder{}
            strings.builder_init_none(&dir_name_builder)
            for parent in dir_stack {
                strings.write_string(&dir_name_builder, parent)
                if strings.compare(parent, "/") != 0 {
                    strings.write_rune(&dir_name_builder, '/')
                }
            }
            strings.write_string(&dir_name_builder, line[5:])

            dir := strings.to_string(dir_name_builder)
            ok := dir in dir_size
            if !ok {
                dir_size[dir] = 0
            } else {
                fmt.printf("Found %s again\n", dir)
            }
            append(&dir_stack, dir)
            continue
        }

        // only thing left is the files.
        size, ok := strconv.parse_uint(strings.split(line, " ")[0])
        if !ok {
            fmt.printf("Unable to get uint")
            return
        }
        for dir in dir_stack {
            dir_size[dir] += size
        }
    }
    sum : uint = 0
    for k, v in dir_size {
        if v <= 100000 {
            sum += v
        }
    }
    fmt.printf("Part 1: %d\n", sum)

    used := dir_size["/"]
    unused := 70000000 - used
    if unused > 30000000 {
        fmt.printf("We already have enough space\n")
    }

    target := 30000000 - unused
    lowest := used
    for k, v in dir_size {
        if v < lowest && v >= target {
            lowest = v
        }
    }
    fmt.printf("Part 2: %d\n", lowest)
}

main :: proc() {
    data := #load("input.txt")
    parse_input(data)
}