# use SVector(2, 3) for a point
using StaticArrays
using Test
using DataStructures

struct line
    s::SVector{2, Int}
    e::SVector{2, Int}
end

function normal(l::line)
    a, b = (l.e .- l.s)
    SVector(-b, a)
end

l = line([0, 1], [2, 3])
n = normal(l)
@test n'l.s == n'l.e

function between(x, a, b)
    (a <= x <= b) | (b <= x <= a)
end

function on(l::line, p::SVector{2, Int})
    n = normal(l)
    direction = n' * (p .- l.s) == 0
    direction & between(p[1], l.s[1], l.e[1]) & between(p[2], l.s[2], l.e[2])
end

p = SVector(1, 2)
@test on(l, p)

function is_straight(l::line)
    (l.s[1] == l.e[1]) | (l.e[2] == l.s[2])
end

k = line(SVector(0, 4), SVector(0, 10))
@test is_straight(k)
@test !(is_straight(l))

function grange(a, b)
    if a == b
        return Set(a)
    end
    Set(range(a, b, step=sign(b - a)))
end

@test grange(1, -1) == Set([-1, 0, 1])

function box(l::line)
    # return all points on the box of the line
    Set([SVector(x, y) for x in grange(l.s[1], l.e[1]) for y in grange(l.s[2], l.e[2])])
end

box(l)

function gridpoints(l::line)
    [p for p in box(l) if on(l, p)]
end

@test length(gridpoints(l)) == 3

k = line([0, 9], [5, 9])
box(k)

m = line([8, 0], [0, 8])
box(m)

## part A


function parsep(s)
    SVector{2, Int}(parse.(Int, split(s, ",")))
end

@test parsep("2,3") == [2, 3]

function parseinp(fn)
    [line(parsep(s), parsep(e)) for (s, e) in split.(readlines(fn), "->")]
end

function countpoints(lines)
    points = DefaultDict{SVector{2, Int}, Int}(0)
    for line in lines
        for point in gridpoints(line)
            points[point] += 1
        end
    end
    points
end

lines = parseinp("test")
straight_lines = [l for l in lines if is_straight(l)]
counts = countpoints(straight_lines)

@test sum(values(counts) .> 1) == 5

lines = parseinp("input")
straight_lines = [l for l in lines if is_straight(l)]
counts = countpoints(straight_lines)
res = sum(values(counts) .> 1)

println("Part A: ", res)

# part 2

lines = parseinp("test")
counts = countpoints(lines)
res = sum(values(counts) .> 1)

@test res == 12

lines = parseinp("input")
counts = countpoints(lines)
res = sum(values(counts) .> 1)

println("Part B: ", res)

    





