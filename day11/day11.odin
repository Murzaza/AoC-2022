package main

import "core:fmt"
import "core:strings"
import "core:strconv"

Op :: enum{ ADD, MULTIPLY, SQUARE }

Monkey :: struct {
    items: [dynamic]u128,
    operation: Op,
    by: u128,
    test: u128,
    pass: int,
    fail: int,
}

parse_input :: proc(data: []u8, do_part_1: bool) {

    monkeys : [dynamic]Monkey
    defer delete(monkeys)

    monkey_business : [dynamic]u128
    defer delete(monkey_business)

    all_divisor : u128 = 1

    lines := strings.split_lines(string(data))
    defer delete(lines)
    for i := 0; i < len(lines); i += 7 {
        // Get current items.
        items : [dynamic]u128
        item_values := strings.split_multi(lines[i+1], {": ", ", "})
        defer delete(item_values)

        for value in item_values[1:] {
            n, ok := strconv.parse_u128(value)
            if !ok {
                fmt.printf("Error parsing %s\n", value)
            }
            append(&items, n)
        }

        // Get operaton
        operation : Op
        by : u128 = 0
        op_values := strings.split(lines[i+2], " ")
        if strings.compare(op_values[7], "old") == 0 {
            operation = .SQUARE
        } else { 
            if strings.compare(op_values[6], "+") == 0 {
                operation = .ADD
            } else {
                operation = .MULTIPLY
            }
            v, ok := strconv.parse_u128(op_values[7])
            by = v
        }

        // Get test
        test : u128 = 0
        test_values := strings.split(lines[i+3], " ")
        v, ok := strconv.parse_u128(test_values[5])
        if !ok {
            fmt.printf("Error parsing %s\n", test_values[5])
        }
        test = v
        all_divisor *= test


        // Get pass
        pass := 0
        pass_values := strings.split(lines[i+4], " ")
        pass = strconv.atoi(pass_values[9])

        // Get fail
        fail := 0
        fail_values := strings.split(lines[i+5], " ")
        fail = strconv.atoi(fail_values[9])

        monkey := Monkey{items, operation, by, test, pass, fail}
        append(&monkeys, monkey)
        append(&monkey_business, 0)
    }
   
    if do_part_1 {
        /* Part 1 */
        for i := 0; i < 20; i += 1 {
            // Inspect
            for m := 0; m < len(monkeys); m += 1 {
                monkey_business[m] += u128(len(monkeys[m].items))
                for item in monkeys[m].items {
                    worry := get_worry(item, monkeys[m].operation, monkeys[m].by) / 3
                    if worry % monkeys[m].test == 0 {
                        append(&monkeys[monkeys[m].pass].items, worry)
                    } else {
                        append(&monkeys[monkeys[m].fail].items, worry)
                    }
                }
                clear(&monkeys[m].items)
            }
        }

        top := [2]u128{0, 0}
        for mb in monkey_business {
            if mb > top[0] {
                top[1] = top[0]
                top[0] = mb
            } else if mb > top[1] {
                top[1] = mb
            }
        }
        fmt.printf("Part 1: %d\n", top[0] * top[1])
    } else {
        /* Part 2 */
        for i := 0; i < 10_000; i += 1 {
            // Inspect
            for m := 0; m < len(monkeys); m += 1 {
                monkey_business[m] += u128(len(monkeys[m].items))
                for item in monkeys[m].items {
                    worry := get_worry(item, monkeys[m].operation, monkeys[m].by) % all_divisor
                    if worry % monkeys[m].test == 0 {
                        append(&monkeys[monkeys[m].pass].items, worry)
                    } else {
                        append(&monkeys[monkeys[m].fail].items, worry)
                    }
                }
                clear(&monkeys[m].items)
            }
        }

        top := [2]u128{0, 0}
        for mb in monkey_business {
            if mb > top[0] {
                top[1] = top[0]
                top[0] = mb
            } else if mb > top[1] {
                top[1] = mb
            }
        }
        fmt.printf("Part 2: %d\n", top[0] * top[1])

    }

    // Clean up! Clean up! Everybody clean up!
    for monkey in monkeys {
        delete(monkey.items)
    }
}

get_worry :: proc(item: u128, op: Op, by: u128) -> u128 {
    value : u128 = 0
    switch op {
        case .ADD: value = item + by
        case .MULTIPLY: value = item * by
        case .SQUARE: value = item * item
    }

    return value
}

main :: proc() {
    data := #load("input.txt")
    parse_input(data, true)
    parse_input(data, false)
}