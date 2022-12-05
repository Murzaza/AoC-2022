package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import queue "core:container/queue"

parse_input :: proc(data: []u8, do_part_1: bool = true) -> [dynamic]queue.Queue(string) {
    input : [dynamic]queue.Queue(string)

    it := string(data)
    stack_count := 0
    for line in strings.split_lines_iterator(&it) {
        if (!strings.contains(line, "move")) {
            /* Proceess initial stacks */
            // Figure out how many stacks we need and create them.
            if stack_count == 0 {
                stack_count = (len(line) + 1)/4
                for len(input) < stack_count {
                    stack := queue.Queue(string){}
                    if !queue.init(&stack) {
                        return nil
                    }
                    append(&input, stack)
                }
            }

            if !strings.contains(line, "[") {
                // Skip empty line and line with stack numbers
                continue
            }

            // place the initial items into the stacks.
            start := 0
            end := 3
            idx := 0
            for idx < len(input) {
                crate := line[start:end]
                if strings.contains(crate, "[") {
                    if !queue.push_front(&input[idx], string(crate[1:2])) {
                        return nil
                    }
                }
                start = end + 1
                end += 4
                idx += 1
            } 
        } else {
            /* Process the movements */
            move := strings.split_multi(line[5:], {" from ", " to "})
            amount := strconv.atoi(move[0])
            from := strconv.atoi(move[1]) - 1
            to := strconv.atoi(move[2]) - 1
            
            if do_part_1 {
                process_command_p1(amount, &input[from], &input[to])
            } else {
                process_command_p2(amount, &input[from], &input[to])
            }
        }
    }

    return input
}

process_command_p1 :: proc(amount: int, from: ^queue.Queue(string), to: ^queue.Queue(string)) {
    for i := 0; i < amount; i += 1 {
        queue.push_back(to, queue.pop_back(from))
    }
}

process_command_p2 :: proc(amount: int, from: ^queue.Queue(string), to: ^queue.Queue(string)) {
    holder : [dynamic]string
    defer delete(holder)
    for i := 0; i < amount; i += 1 {
        append(&holder, queue.pop_back(from))
    }

    for i := amount - 1; i >= 0; i -= 1 {
        queue.push_back(to, holder[i])
    }
}

main :: proc() {
    input_data := #load("input.txt")
    input := parse_input(input_data, false)
    defer delete(input)
    if input == nil {
        fmt.println("Error getting input")
        return
    }
    builder := strings.Builder{}
    strings.builder_init_len(&builder, len(input))
    for i := 0; i < len(input); i += 1 {
        q : queue.Queue(string) = input[i]
        strings.write_string(&builder, queue.peek_back(&q)^)
    }
    fmt.println(strings.to_string(builder))
}