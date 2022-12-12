package main

import "core:fmt"
import "core:strings"


SearchContext :: struct {
    loc : [2]int,
    steps : int,
}

parse_input :: proc(data: []u8) {
    topo : [dynamic][dynamic]rune
    defer delete(topo)

    visited : [dynamic][dynamic]bool
    defer delete(visited)

    distance : [dynamic][dynamic]int
    defer delete(distance)

    start := [2]int{0, 0}
    end := [2]int{0, 0}

    // Part 1
    part_1 := 0

    // Part 2
    all_a: [dynamic][2]int
    defer delete(all_a)
    low_starts: [dynamic][2]int
    defer delete(low_starts)

    it := string(data)
    for line in strings.split_lines_iterator(&it) {
        row_t : [dynamic]rune
        row_v : [dynamic]bool
        row_d : [dynamic]int

        for r in line {
            h := r
            d := 1_000_000
            if r == 'S' {
                h = 'a'
                start = [2]int{len(topo), len(row_t)}
                d = 0
            } else if r == 'E' {
                h = 'z'
                end = [2]int{len(topo), len(row_t)}
            }

            if h == 'a' {
                append(&all_a, [2]int{len(topo), len(row_t)})
            }
            append(&row_t, h)
        }
        append(&topo, row_t)
    }

    for a in all_a {
        /*
            Optimization: 'a' can only go to 'a' or 'b', so if the 'a' isn't
            right next to a 'b' then it can't be the shortest path, eliminate it from testing.
        */
        if has_b_neighbor(&topo, a) {
            append(&low_starts, a)
        }
    }

    // Part 1
    clear_and_init(&topo, &visited, &distance, start)
    part_1 = dijkstra(&topo, &visited, &distance, end)

    // Part 2
    part_2 := 1_000_000
    for s in low_starts {
        clear_and_init(&topo, &visited, &distance, s)
        moves := dijkstra(&topo, &visited, &distance, end)
        if moves < part_2 {
            part_2 = moves
        }
    }

    fmt.printf("Part 1: %v\n", part_1)
    fmt.printf("Part 2: %v\n", part_2)
}

has_b_neighbor :: proc(topo: ^[dynamic][dynamic]rune, start: [2]int) -> bool {
    // Up
    if start[0] > 0 {
        p := [2]int{start[0]-1, start[1]}
        n := topo[p[0]][p[1]]
        if n == 'b' {
            return true
        }
    }

    // Down
    if start[0] < len(topo)-1 {
        p := [2]int{start[0]+1, start[1]}
        n := topo[p[0]][p[1]]
        if n == 'b' {
            return true
        }
    }

    // Right
    if start[1] < len(topo[start[0]]) - 1 {
        p := [2]int{start[0], start[1]+1}
        n := topo[p[0]][p[1]]
        if n == 'b' {
            return true
        }
    }

    // Left
    if start[1] > 0 {
        p := [2]int{start[0], start[1]-1}
        n := topo[p[0]][p[1]]
        if n == 'b' {
            return true
        }
    }

    return false
}

clear_and_init :: proc(topo: ^[dynamic][dynamic]rune, visited: ^[dynamic][dynamic]bool, distance: ^[dynamic][dynamic]int, start: [2]int) {
    clear(visited)
    clear(distance)

    for row := 0; row < len(topo); row += 1 {
        v : [dynamic]bool
        d : [dynamic]int
        for col := 0; col < len(topo[row]); col += 1 {
            append(&v, false)
            place := [2]int{row, col}
            if start == place {
                append(&d, 0)
            } else {
                append(&d, 1_000_000)
            }
        }
        append(visited, v)
        append(distance, d)
    } 
}

dijkstra :: proc(topo: ^[dynamic][dynamic]rune, visited: ^[dynamic][dynamic]bool, distance: ^[dynamic][dynamic]int, end: [2]int) -> int {
    for visited[end[0]][end[1]] == false {
        v := get_min(visited, distance)
        visited[v[0]][v[1]] = true

        neighbors := get_valid_next_steps(topo, visited, &v) 
        defer delete(neighbors)
        for n in neighbors {
            dist := distance[v[0]][v[1]] + 1
            if dist < distance[n[0]][n[1]] {
                distance[n[0]][n[1]] = dist
            }
        }
    }

    return distance[end[0]][end[1]]
}

get_min :: proc(visited: ^[dynamic][dynamic]bool, distance: ^[dynamic][dynamic]int) -> [2]int {
    min := 1_000_001
    min_place := [2]int{-1, -1}
    for row := 0; row < len(distance); row += 1 {
        for col := 0; col < len(distance[row]); col += 1 {
            if !visited[row][col] && distance[row][col] < min {
                min = distance[row][col]
                min_place = [2]int{row, col}
            }
        }
    }

    return min_place
}

all_visited :: proc(visited: ^[dynamic][dynamic]bool) -> bool {
    all_visited := true
    for row in visited {
        for p in row {
            all_visited &= p
        }
    }

    return all_visited
}

get_valid_next_steps :: proc(topo: ^[dynamic][dynamic]rune, visited: ^[dynamic][dynamic]bool, source: ^[2]int) -> [dynamic][2]int {
    steps : [dynamic][2]int
    // Up
    if source[0] > 0 {
        s := topo[source[0]][source[1]]
        p := [2]int{source[0]-1, source[1]}
        n := topo[p[0]][p[1]]
        if !visited[p[0]][p[1]] && n <= s + 1{
            append(&steps, p)
        }
    }

    // Down
    if source[0] < len(topo)-1 {
        s := topo[source[0]][source[1]]
        p := [2]int{source[0]+1, source[1]}
        n := topo[p[0]][p[1]]
        if !visited[p[0]][p[1]] && n <= s + 1{
            append(&steps, p)
        }
    }

    // Right
    if source[1] < len(topo[source[0]]) - 1 {
        s := topo[source[0]][source[1]]
        p := [2]int{source[0], source[1]+1}
        n := topo[p[0]][p[1]]
        if !visited[p[0]][p[1]] && n <= s + 1{
            append(&steps, p)
        }
    }

    // Left
    if source[1] > 0 {
        s := topo[source[0]][source[1]]
        p := [2]int{source[0], source[1]-1}
        n := topo[p[0]][p[1]]
        if !visited[p[0]][p[1]] && n <= s + 1{
            append(&steps, p)
        }
    }

    return steps
}

main :: proc() {
    data := #load("input.txt")
    parse_input(data)
}