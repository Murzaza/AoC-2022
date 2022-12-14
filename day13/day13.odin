package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:encoding/json"
import "core:slice"

Comparison :: enum {LESS, EQUAL, GREATER}

parse_input :: proc(data: []u8) {
    packets : [dynamic]json.Value

    part_1 := 0
    part_2 := 0

    lines := strings.split_lines(string(data))
    // Input expects the first line is left, the second line is right, and the third line is blank. 
    // So make sure the input has a blank line at the end.
    for i := 0; i <= len(lines) - 3; i += 3 {
        left, lok := json.parse_string(lines[i], .JSON5, true)
        if lok != .None {
            fmt.printf("Unable to parse %v\n", lines[i])
            return
        }

        right, rok := json.parse_string(lines[i+1], .JSON5, true)
        if rok != .None {
            fmt.printf("Unable to parse %v\n", lines[i+1])
            return
        }
        append(&packets, left)
        append(&packets, right)

        if compare(left, right) == .LESS {
            part_1 += len(packets) / 2
        }
    }
    fmt.printf("Part 1: %v\n", part_1)

    divisor_2, d_2_err := json.parse_string("[[2]]", .JSON5, true)
    divisor_6, d_6_err := json.parse_string("[[6]]", .JSON5, true)
    if d_2_err != .None || d_6_err != .None {
        fmt.printf("Unable to parse divisor strings\n")
        return
    }
    append(&packets, divisor_2)
    append(&packets, divisor_6)

    slice.sort_by(packets[:], proc(x, y: json.Value) -> bool {
        return compare(x, y) == .LESS
    })

    idx_d2, found_d2 := slice.linear_search_proc(packets[:], proc(x: json.Value) -> bool {
        div_2, _ := json.parse_string("[[2]]", .JSON5, true)
        return compare(x, div_2) == .EQUAL
    })

    idx_d6, found_d6 := slice.linear_search_proc(packets[:], proc(x: json.Value) -> bool {
        div_6, _ := json.parse_string("[[6]]", .JSON5, true)
        return compare(x, div_6) == .EQUAL
    })

    if !found_d2 || !found_d6 {
        fmt.printf("Unable to find divisors in sorted list\n")
        return
    }

    part_2 = (idx_d2 + 1) * (idx_d6 + 1)
    fmt.printf("Part 2: %v\n", part_2)

}

compare :: proc(left, right: json.Value) -> Comparison {
    
    // Compare integer values
    l_int, l_int_ok := left.(i64)
    r_int, r_int_ok := right.(i64)
    if l_int_ok && r_int_ok {
        if l_int == r_int {
            return .EQUAL
        } else if l_int > r_int {
            return .GREATER
        } else {
            return .LESS 
        }
    }

    // Compare arrays one item at a time.
    l_array, l_array_ok := left.(json.Array)
    r_array, r_array_ok := right.(json.Array)
    if l_array_ok && r_array_ok {
        llen := len(l_array)
        rlen := len(r_array)
        min_len := min(llen, rlen)
        for i := 0; i < min_len; i += 1 {
            cmp := compare(l_array[i], r_array[i])
            if cmp == .LESS || cmp == .GREATER {
                return cmp
            }
        }
        if llen == rlen {
            return .EQUAL
        } else if rlen < llen {
            return .GREATER
        }

        return .LESS
    }

    // Convert integer to array and compare those
    if l_int_ok {
        l_array := make(json.Array, 1, 1)
        l_array[0] = l_int
        return compare(l_array, right) 
    }

    if r_int_ok {
        r_array := make(json.Array, 1, 1)
        r_array[0] = r_int
        return compare(left, r_array)
    }

    return .EQUAL
}

main :: proc() {
   data := #load("input.txt")
   parse_input(data)
}