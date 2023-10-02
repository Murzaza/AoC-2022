package main

import "core:fmt"
import "core:strings"
import "core:strconv"

Valve :: struct {
    name: string,
    flow: int,
    tunnels: []string,
}

day16 :: proc(data: []u8) {
    valves := make(map[string]Valve)
    defer delete(valves)

    turned_on := make(map[string]bool)
    defer delete(turned_on)

    it := string(data)
    for line in strings.split_lines_iterator(&it) {
        parts := strings.split_multi(line, {"Valve ", " has flow rate=", "; tunnels lead to valves ", "; tunnel leads to valve "})[1:]
        valves[parts[0]] = Valve{parts[0], strconv.atoi(parts[1]), strings.split(parts[2], ", ")[:]}
    }

    flow := find_highest_flow("AA", &valves, 30, &turned_on)
    fmt.printf("Part 1: %v\n", flow)
}

find_highest_flow :: proc(valve: string, valves: ^map[string]Valve, minutes_left: int, turned_on: ^map[string]bool) -> int {
    fmt.printf("%v Minutes Left: %v\n", valve, minutes_left)
    if minutes_left <= 30 {
        return 0
    }

    minutes := minutes_left - 1
    open_now := minutes * valves[valve].flow
    max_flow := 0
    for tunnel in valves[valve].tunnels {
        off := find_highest_flow(tunnel, valves, minutes, turned_on)
        on := 0
        if valve not_in turned_on {
            turned_on[valve] = true
            on = find_highest_flow(tunnel, valves, minutes - 1, turned_on) + open_now
            delete_key(turned_on, valve)
        }

        max_flow = max(max_flow, off, on)
    }

    return max_flow
}

main :: proc() {
    data := #load("test.txt")
    day16(data)
}