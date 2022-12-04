package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

get_input :: proc(filepath: string) -> [dynamic]rune {
    input : [dynamic]rune
    data, ok := os.read_entire_file(filepath, context.allocator)
    if !ok {
        fmt.printf("Unable to read file: %s\n", filepath)
        return input
    }
    defer delete(data, context.allocator)

    it := string(data)
    /* For part 1
    for line in strings.split_lines_iterator(&it) {
        half := len(line)/2
        compartment1 := line[:half]
        compartment2 := line[half:]
        m := make(map[rune]int)
        defer delete(m)
        for r in compartment1 {
           m[r] = 2 
        }
        for r in compartment2 {
            ok := r in m
            if ok {
                append(&input, r)
                break
            }
        }
    }
    */
    /* part 2 */
    lines := strings.split_lines(it)
    for i := 0; i < len(lines); i += 3 {
        m := make(map[rune]int)
        defer delete(m)

        for r in lines[i] {
            m[r] = 1
        }

        for r in lines[i + 1] {
            if r in m {
                m[r] = 2
            } 
        }

        for r in lines[i + 2] {
            count, ok := m[r]
            if ok {
                if count == 2 {
                    append(&input, r)
                    break
                }
            }
        }
    }

    return input
}

get_priority :: proc(r: rune) -> int {
    value := 0
    switch r {
        case 'A'..='Z': value = 27 + (int(r) - 65)
        case 'a'..='z': value = 1 + (int(r) - 97)
    }
    return value 
}

main :: proc() {
    input := get_input("input.txt")
    sum := 0
    for i in input {
        priority := get_priority(i)
        fmt.printf("%c : %d\n", i, priority)
        sum += priority
    }

    fmt.printf("sum: %d\n", sum)
}