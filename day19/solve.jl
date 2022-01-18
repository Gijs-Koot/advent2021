using Test
using Match
using StaticArrays

const Point = SVector{3, Int}
const Scanner = Set{Point}

function parseinp(fn)
    spl = split(read(fn, String), r"--- scanner \d+ ---\n")[2:end]
    raw = [split.(scanner, ",") for scanner in split.(strip.(spl), "\n")]
    [Set(Point(parse.(Int, tp)) for tp in scanner) for scanner in raw]
end

scanners = parseinp("test")
scanner = parseinp("test1")[1]

angles = [0, .5, 1, 1.5] .* pi

ZROT = [round.(Int, [cos(a) -sin(a) 0
                     sin(a) cos(a)  0
                     0      0       1]) for a in angles]
YROT = [round.(Int, [cos(a) 0 -sin(a)
                     0      1 0
                     sin(a) 0 cos(a)]) for a in angles]
XROT = [round.(Int, [1   0    0
                     0   cos(a) -sin(a)
                     0   sin(a) cos(a)]) for a in angles]


ORIENTATIONS = Set(reshape([(x * y * z) for z in ZROT, y in YROT, x in XROT], :))

@test length(ORIENTATIONS) == 24

function transform(sc::Scanner, mat)
    Scanner(Point(mat * p) for p in sc)
end

function translate(sc::Scanner, offs)
    Scanner(Point(p .- offs) for p in sc)
end

transform(scanner, ORIENTATIONS[1])
translate(scanner, [1, 2, 3])

function tryoffsets(sca::Scanner, scb::Scanner)
    for (pa, pb) in Iterators.product(sca, scb)
        offset = pb - pa
        translated = translate(scb, offset)
        ncommon = length(intersect(sca, translated))
        if ncommon >= 12
            return offset
        end
    end
    nothing
end

tryoffsets(scanners[1], scanners[1])
        
function trytranslations(sca::Scanner, scb::Scanner)
    for orient in ORIENTATIONS
        oriented = transform(scb, orient)
        offs = tryoffsets(sca, oriented)
        if offs != nothing
            return orient, offs
        end
    end
    nothing
end

mat, offs = trytranslations(scanners[1], scanners[2])

function relpoints(sca, scb)
    res = trytranslations(sca, scb)
    if res == nothing
        return nothing
    end
    (orient, offs) = res
    return translate(transform(scb, orient), offs)
end

relpoints(scanners[1], scanners[2])

function findshifts(scanners)
    # return all translations

    base = scanners[1]
    shifts = Dict{Int, Tuple{Array{Int, 2}, Point}}()

    for (ix, sc) in enumerate(scanners)
        if (res = trytranslations(base, sc)) != nothing
            shifts[ix] = res
        end
    end

    tried = Set([1])

    while length(setdiff(keys(shifts), tried)) > 0
        # pick one to try others with
        pick = first(setdiff(keys(shifts), tried))
        for left in setdiff(1:length(scanners), keys(shifts))
            pick == left && continue # dont try the same
            if (res = trytranslations(scanners[pick], scanners[left])) != nothing
                orienta, offseta = shifts[pick]
                orientb, offsetb = res
                realoffset = orienta * offsetb
                shifts[left] = (orienta * orientb, offseta .+ realoffset)
            end
        end
        push!(tried, pick)
    end
    shifts
end

findshifts(scanners)

# part I

function solve(scanners)
    shifts = findshifts(scanners)
    points = Set{Point}()

    for (ix, scanner) in enumerate(scanners)
        orient, offset = shifts[ix]
        new = translate(transform(scanner, orient), offset)
        points = union(points, new)
    end
    length(points)
end

@test solve(scanners) == 79

scanners = parseinp("input")
println("Part A ", solve(scanners))
             
# part II

shifts = findshifts(scanners)
offsets = [o for (i, (m, o)) in shifts]    
dists = [sum(abs.(a .- b)) for (a, b) in Iterators.product(offsets, offsets)]

println("Part B ", maximum(dists))
