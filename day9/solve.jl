using Test
using DataStructures

function parseinp(fn)
    hcat([parse.(Int, split(r, "")) for r in readlines(fn)]...)'
end

mat = parseinp("test")

function tod(mat)
    d = DefaultDict{Tuple{Int, Int}, Int}(10)
    nr, nc = size(mat)
    for r in 1:nr, c in 1:nc
        d[(r, c)] = mat[r, c]
    end
    d
end

dd = tod(mat)
@test dd[(1, 1)] == 2
@test dd[(2, 1)] == 3

function nbs(coord)
    x, y = coord
    [(x-1, y), (x+1, y), (x,y-1), (x,y+1)]
end

function lowest(dd, coord)
    nb_heights = [dd[c...] for c in nbs(coord)]
    all(dd[c...] > dd[coord...] for c in nbs(coord))
end

@test lowest(dd, (1, 2))

function findlows(dd)
    res::Array{Int} = []
    for (coord, height) in dd
        if lowest(dd, coord)
            push!(res, height)
        end
    end
    res
end

@test sum(findlows(tod(mat)) .+ 1) == 15

mat = parseinp("input")
res = sum(findlows(tod(mat)) .+ 1)
println("Part A: ", res)

# part II
# I think basins are always surrounded by nines

points = Set([(1, 1)])

function expand(points, dd)
    Set(p for p in vcat(nbs.(points)...) if dd[p] < 9)
end

expand(points, dd)

function basin(coord, dd)
    points = Set{Tuple{Int, Int}}()
    expansion = Set([coord])
    while !issubset(expansion, points)
        points = union(points, expansion)
        expansion = expand(points, dd)
    end
    points
end

function findlowcoords(dd)
    res::Array{Tuple{Int, Int}} = []
    for (coord, height) in dd
        if lowest(dd, coord)
            push!(res, coord)
        end
    end
    res
end

function solve(fn)
    mat = parseinp(fn)
    dd = tod(mat)
    lens = length.(basin(c, dd) for c in findlowcoords(dd))
    prod(reverse(sort(lens))[1:3])
end

@test solve("test") == 1134

res = solve("input")

println("Part B: ", res)
