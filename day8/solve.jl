using StatsBase
using Test

digits = Dict(k - 1 => v for (k, v) in enumerate(split.(readlines("data"), "")))

lengths = Dict(k => length(v) for (k, v) in digits)
unique_lengths = [k for (k, v) in countmap(values(lengths)) if v == 1]


function parseinp(fn)
    lines = split.(readlines(fn), "|")
    [Tuple([split(strip(a), " "), split(strip(b))]) for (a, b) in lines]
end

inp = parseinp("test")

function countuniques(inp)
    count = 0
    for (a, b) in inp
        for word in b
            if length(word) in unique_lengths
                count += 1
            end
        end
    end
    count
end

@test countuniques(inp) == 26

inp = parseinp("input")
res = countuniques(inp)

println("part A: ", res)

# so we always have all the letters
@test all(length.(Set(a) for (a, b) in inp) .== 10)

# we just need one system for deriving

sets = Dict(k => Set(v) for (k, v) in digits)

relations = [(a, b) for (a, aw) in digits for (b, bw) in digits if issubset(aw, bw)]

n_contains = countmap(b for (a, b) in relations)
n_is_contained = countmap(a for (a, b) in relations)
lengths = Dict(a => length(b) for (a, b) in sets)

fingerprints = Dict(Tuple([get(n_contains, i, 0), get(n_is_contained, i, 0), lenghts[i]]) => i for i in 0:9)

@test length(fingerprints) == 10

function solve(words)
    # given a set of words derive their values
    # by comparing fingerprints
    prints = Dict(
        w => (sum(issubset.(words, w)), sum(issubset.(w, words)), length(w)) for w in words
    )
    return Dict(Set(k) => fingerprints[v] for (k, v) in prints)
end

function scorepair(a, b)
    dict = solve(a)
    vals = [dict[Set(w)] for w in b]
    parse(Int, join(vals))
end

inp = parseinp("test")

@test sum(scorepair(a, b) for (a, b) in inp) == 61229

inp = parseinp("input")
res = sum(scorepair(a, b) for (a, b) in inp)

print("Part B: ", res)
