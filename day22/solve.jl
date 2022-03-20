using Test
using DataStructures

struct CubRule
    val::Bool
    xmin::Int
    xmax::Int
    ymin::Int
    ymax::Int
    zmin::Int
    zmax::Int
end

function parseln(line)
    m = match(r"(on|off) x=(-?\d+)\.\.(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)", line)

    val, bounds... = [m[i] for i in 1:7]
    CubRule(val == "on", parse.(Int, bounds)...)
end

function parseinp(fn)
    parseln.(readlines(fn))
end

rules = parseinp("test")

function coords(cubr, minv, maxv)
    xmin = max(minv, cubr.xmin)
    ymin = max(minv, cubr.ymin)
    zmin = max(minv, cubr.zmin)
    xmax = min(maxv, cubr.xmax)
    ymax = min(maxv, cubr.ymax)
    zmax = min(maxv, cubr.zmax)
    [(x, y, z) for x in xmin:xmax,
     y in ymin:ymax,
     z in zmin:zmax]
end

@test length(coords(rules[1], -50, 50)) == 27

function apply!(cube, cubr)
    for cr in coords(cubr, -50, 50)
        cube[cr] = cubr.val
    end
end

function solve(cubrules)
    cube = DefaultDict{Tuple{Int, Int, Int}, Bool}(false)
    for cubr in cubrules
        apply!(cube, cubr)
    end
    sum(values(cube))
end

rules = parseinp("test2")

@test solve(rules) == 590784

rules = parseinp("input")
ans = solve(rules)

println("Part A: ", ans)

# part B .. okok

struct Cube
    xmin::Int
    xmax::Int
    ymin::Int
    ymax::Int
    zmin::Int
    zmax::Int
end
    

function intersect(cuba::Cube, cubb::Cube)
    # calculate overlap, left and right
    
