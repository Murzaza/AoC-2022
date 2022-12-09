package main

import "core:fmt"
import "core:strings"
import "core:strconv"

parse_input :: proc(data: []u8) {
    forest : [dynamic][dynamic]rune
    defer delete(forest)

    it := string(data)
    for line in strings.split_lines_iterator(&it) {
        tree_line : [dynamic]rune
        for r in line {
            append(&tree_line, r)
        }
        append(&forest, tree_line)
    }

    size := len(forest)
    visible := size * 4 - 4
    for i := 1; i < size - 1; i += 1 {
        for j := 1; j < size - 1; j += 1{
            if is_visible(&forest, i, j) {
                visible += 1
            }
        }
    }

    fmt.printf("Part 1: %d\n", visible)

    max_score := 0
    for i := 0; i < size; i += 1 {
        for j := 0; j < size; j += 1 {
            score := calculate_score(&forest, i, j)
            if score > max_score {
                max_score = score
            }
        }
    }

    fmt.printf("Part 2: %d\n", max_score)
}

is_visible :: proc(forest: ^[dynamic][dynamic]rune, row, column : int) -> bool {
    tree_height := forest[row][column]
    east := true
    for i := column + 1; i < len(forest[row]); i += 1 {
        if forest[row][i] >= tree_height {
            east = false
            break
        } 
    } 

    west := true
    for i := column - 1; i >= 0; i -= 1 {
        if forest[row][i] >= tree_height {
            west = false
            break
        }
    }

    south := true
    for i := row + 1; i < len(forest); i += 1 {
        if forest[i][column] >= tree_height {
            south = false
            break
        }
    }

    north := true
    for i := row - 1; i >= 0; i -= 1 {
        if forest[i][column] >= tree_height {
            north = false
            break
        }
    }
    return north || south || west || east
}

calculate_score :: proc(forest: ^[dynamic][dynamic]rune, row, column : int) -> int {
    tree_height := forest[row][column]
    east := 0
    for i := column + 1; i < len(forest[row]); i += 1 {
        east += 1
        if forest[row][i] >= tree_height {
            break
        } 
    } 

    west := 0 
    for i := column - 1; i >= 0; i -= 1 {
        west += 1
        if forest[row][i] >= tree_height {
            break
        }
    }

    south := 0 
    for i := row + 1; i < len(forest); i += 1 {
        south += 1
        if forest[i][column] >= tree_height {
            break
        }
    }

    north := 0 
    for i := row - 1; i >= 0; i -= 1 {
        north += 1
        if forest[i][column] >= tree_height {
            break
        }
    }
    return north * south * west * east
}

main :: proc() {
    data := #load("input.txt")
    parse_input(data)
}