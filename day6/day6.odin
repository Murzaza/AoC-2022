package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

parse_input :: proc(data: []u8) {
    stream := string(data)

    /* Part 1 */
    for i := 3; i < len(data); i += 1 {
        if check_rune_uniqueness(string(data[i-3 : i+1])) {
            fmt.printf("Start of packet: %d\n", i+1)
            break
        }
    } 

    /* Part 2 */
    for i := 13; i < len(data); i += 1 {
        if check_rune_uniqueness(string(data[i-13 : i+1])) {
            fmt.printf("Start of message: %d\n", i+1)
            break
        }
    }
}

check_rune_uniqueness :: proc(window: string) -> bool {
    for i := 0; i < len(window); i += 1 {
        for j := i+1; j < len(window); j += 1 {
            if window[i] == window[j] {
                return false
            }
        }
    }

    return true
}

main :: proc() {
    data := #load("input.txt")
    parse_input(data)
}