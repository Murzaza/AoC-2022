package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

RPS :: enum {
    ROCK,
    PAPER,
    SCISSOR,
};

Match :: struct {
    opp: RPS,
    you: RPS,
};

get_rps :: proc(first, second: string) -> (RPS, RPS) {
    opp := RPS.ROCK
    you := RPS.ROCK
    if strings.compare(first, "A") == 0 {
        opp = .ROCK
    }
    if strings.compare(first, "B") == 0 {
        opp = .PAPER
    }
    if strings.compare(first, "C") == 0 {
        opp = .SCISSOR
    }

    if strings.compare(second, "Y") == 0 {
       you = opp 
    }
    if strings.compare(second, "X") == 0 {
        switch opp {
            case .ROCK: you = .SCISSOR
            case .PAPER: you = .ROCK
            case .SCISSOR: you = .PAPER
        }
    }
    if strings.compare(second, "Z") == 0 {
        switch opp {
            case .ROCK: you = .PAPER
            case .PAPER: you = .SCISSOR
            case .SCISSOR: you = .ROCK
        }
    }

    return opp, you
}

get_input :: proc(filepath: string) -> [dynamic]Match {
    input : [dynamic]Match
    data, ok := os.read_entire_file(filepath, context.allocator)    
    if !ok {
        fmt.printf("Unable to read file: %s\n", filepath)
        return input
    }
    defer delete(data, context.allocator)

    it := string(data)
    for line in strings.split_lines_iterator(&it) {
        parts := strings.split(line, " ") 
        opp, you := get_rps(parts[0], parts[1])
        append(&input, Match{opp, you})
    }

    return input
}

calculate_points :: proc(match: Match) -> int {
    points := 0
    switch match.you {
        case .ROCK: points += 1
        case .PAPER: points += 2
        case .SCISSOR: points += 3
    }

    if match.you == match.opp {
        points += 3
    }

    if match.you == .ROCK && match.opp == .SCISSOR || 
        match.you == .PAPER && match.opp == .ROCK ||
        match.you == .SCISSOR && match.opp == .PAPER {
        points +=6
    }

    return points
}

main :: proc() {
    matches := get_input("input.txt")
    acc := 0
    for match in matches {
        acc += calculate_points(match)
    }

    fmt.println(acc)
}