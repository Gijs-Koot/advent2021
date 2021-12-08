using Test
using StatsBase

function parseinp(fn)
    parse.(Int, split(read(fn, String), ","))
end



function grow(lf)
    next = lf .- 1
    done = next .== -1
    next[done] .= 6
    vcat(next, [8 for _ in range(1, length=sum(done))])
end

function num_after(lf, ndays)
    for _ in range(1, length=ndays)
        lf = grow(lf)
    end
    length(lf)
end

lf = parseinp("test")
grow(grow(lf))

@test num_after(lf, 18) == 26
@test num_after(lf, 80) == 5934

lf = parseinp("input")
res = num_after(lf, 80)
println("Part A: ", res)

lfc = countmap(lf)

function next(n)
    if n == 0
        return 8
    end
    n - 1
end

function grow(lfc::Dict{Int64, Int64})
    new = Dict(next(k) => v for (k, v) in lfc)
    new[6] = get(new, 6, 0) + get(new, 8, 0)
    new
end

grow(lfc)

function num_after(lfc::Dict{Int, Int}, ndays)
    for _ in range(1, length=ndays)
        lfc = grow(lfc)
    end
    sum(values(lfc))
end

lf = parseinp("test")
lfc = countmap(lf)
num_after(lfc, 20)
@test num_after(lfc, 256) == 26984457539

lfc = countmap(parseinp("input"))
res = num_after(lfc, 256)
println("Part B: ", res)
