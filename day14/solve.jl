using Test
using StatsBase
using DataStructures

function parseinp(fn)
    lines = readlines(fn)
    start = lines[1]
    rules = split.(lines[3:end], " -> ")
    start, Dict(rules)
end

start, rules = parseinp("test")

function findallx(needle, haystack)
    pos = Vector{Int}([])
    for ix in 1:(length(haystack) - length(needle) + 1)
        curr = haystack[ix:ix + length(needle) - 1]
        if curr == needle
            push!(pos, ix)
        end
    end
    pos
end

@test findallx("BB", "BBB") == [1, 2]        
@test findallx("BB", "ABBBA") == [2, 3]

function inserts(poly, rules)
    # find positions where to insert a letter
    res = Vector{Tuple{Int, String}}([])
    for (sub, add) in rules
        for pos in findallx(sub, poly)
            push!(res, (pos, add))
        end
    end
    res
end

inserts(start, rules)

function apply(poly, insertsl)
    polyl = [c for c in poly]  # vector of chars
    for (ix, (pos, ins)) in enumerate(sort(insertsl))
        real_pos = pos + ix
        insert!(polyl, real_pos, ins[1])
    end
    join(polyl)
end

@test apply(start, inserts(start, rules)) == "NCNBCHB"

function apply(poly, rules, n)
    for _ in 1:n
        poly = apply(poly, inserts(poly, rules))
    end
    poly
end

@test apply(start, rules, 1) == "NCNBCHB"
@test apply(start, rules, 2) == "NBCCNBBBCBHCB"
@test apply(start, rules, 3) == "NBBBCNCCNBBNBNBBCHBHHBCHB"


function xsolve(start, rules)
    poly = apply(start, rules, 10)
    counts = values(countmap(poly))
    maximum(counts) - minimum(counts)
end


@test xsolve(start, rules) == 1588

start, rules = parseinp("input")
res = xsolve(start, rules)
println("Part A ", res)

# part B .. crap

function polyc(poly)
    # break into pairs
    res = DefaultDict{String, Int}(0)
    for ix in 1:(length(poly) - 1)
        res[poly[ix:ix+1]] += 1
    end
    res
end


polyc(start)

function results(pair, insert)
    a = join([pair[1], insert])
    b = join([insert, pair[2]])
    [a, b]
end

@test results("CB", "A") == ["CA", "AB"]

function apply(poly, rules)
    res = DefaultDict{String, Int}(0)
    for (pair, count) in poly
        if pair in keys(rules)
            for spl in results(pair, rules[pair])
                res[spl] += count
            end
        else
            res[pair] += count
        end
    end
    res
end

poly = polyc(start)
apply(poly, rules)

function apply(poly, rules, n)
    for _ in 1:n
        poly = apply(poly, rules)
    end
    poly
end

function xcount(poly, start)
    counts = DefaultDict{Char, Int}(0)
    for (pair, count) in poly
        for c in pair
            counts[c] += count
        end
    end
    counts[start[1]] += 1
    counts[start[end]] += 1
    vals = values(counts) .// 2
    maximum(vals) - minimum(vals)
end


start, rules = parseinp("test")
poly = polyc(start)
res = apply(poly, rules, 10)
@test xcount(res, start) == 1588

start, rules = parseinp("input")
poly = polyc(start)
res = apply(poly, rules, 40)
c = xcount(res, start)
println("Part B: ", c)
