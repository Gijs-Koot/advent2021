using Match

inp = open("input") do f
    [(x, parse(Int, y)) for (x, y) in split.(readlines(f))]
end

function partA()
    
    depth = 0
    pos = 0

    for (direction, amount) in inp
        @match direction begin
            "up" => (depth -= amount)
            "down" => (depth += amount)
            "forward" => (pos += amount)
        end
    end

    println("Part A: ", depth * pos)
end

partA()

function partB()
        
    depth = 0
    pos = 0
    aim = 0
    
    for (direction, amount) in inp
        @match direction begin
            "up" => (aim -= amount)
            "down" => (aim += amount)
            "forward" => ((pos += amount) & (depth += aim * amount))
        end
    end

    println("Part B: ", depth * pos)

end

partB()
