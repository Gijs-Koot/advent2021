using DataStructures
using Test

PAIRS = [
("(", ")", 3),
("[", "]", 57),
("{", "}", 1197),
("<", ">", 25137)
]

FIT = Dict(x[2] => x[1] for x in PAIRS)
CLOSER = Dict(x[1] => x[2] for x in PAIRS)
PENALTY = Dict(x[2] => x[3] for x in PAIRS)
OPEN = Set(x[1] for x in PAIRS)
CLOSE = Set(x[2] for x in PAIRS)

s = Stack{String}()

lines = readlines("test")
chars = split(lines[1], "")

function penalty(chars)
    for c in chars
        if c in OPEN
            push!(s, c)
        else
            if FIT[c] != pop!(s)
                return PENALTY[c]
            end
        end
    end
    0
end

res = sum(penalty.(split.(lines, "")))
@test res == 26397

lines = readlines("input")
res = sum(penalty.(split.(lines, "")))
println("Part A: ", res)


function completion(chars)
    s = Stack{String}()
    for c in chars
        if c in OPEN
            push!(s, c)
        else
            if FIT[c] != pop!(s)
                return []
            end
        end
    end
    [CLOSER[c] for c in s]
end

needed = completion(split(lines[1], ""))

SCORES = Dict(x[2] => i for (i, x) in enumerate(PAIRS))

prod([SCORES[n] for n in needed])

function scorepoints(arr::Array{T}) where {T}
    sum = zero(T)
    for el in arr
        sum *= 5
        sum += el
    end
    sum
end


function score(line)
    needed = completion(split(line, ""))
    points::Array{Int64} = [SCORES[n] for n in needed]
    scorepoints(points)
end

using Statistics

function solve(fn)
    round(Int, median(filter(>(0), score.(readlines(fn)))))
end

@test solve("test") == 288957
println("Part B: ", solve("input"))    
