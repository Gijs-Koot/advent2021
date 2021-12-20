using DataStructures
using Strings
using Test

function parseinp(fn)
    roads = split.(readlines(fn), "-")
    paths = DefaultDict{String, Vector{String}}(Vector{String})
    for (a, b) in roads
        push!(paths[a], b)
        push!(paths[b], a)
    end
    paths
end

paths = parseinp("test")

function isbig(cave)
    all(isuppercase.(c for c in cave))
end


function poss(seg, paths)
    # return possible next steps for seg
    curr = seg[end]

    if !(haskey(paths, curr)) | (curr == "end")
        return []
    end
    
    [c for c in paths[curr] if !(c in seg) | isbig(c)]
end

@test poss(["start"], paths) == ["A", "b"]
@test "A" in poss(["start", "A", "b"], paths)

function grow(seg, paths)
    # return all possible continuations of seg via paths
    continuations = Vector{Vector{String}}([])

    for next in poss(seg, paths)
        if next == "end"
            push!(continuations, vcat(seg, next))
        else
            for continuation in grow(vcat(seg, next), paths)
                push!(continuations, continuation)
            end
        end
    end

    continuations
end

paths = parseinp("test")
@test length(grow(["start"], paths)) == 10

paths = parseinp("input")
res = length(grow(["start"], paths))

# part B

function hasdoublevisit(seg)
    small = filter(!isbig, seg)
    length(Set(small)) < length(small)
end

@test hasdoublevisit(["start", "a", "b", "c", "C", "C"]) == false
@test hasdoublevisit(["start", "A", "b", "b"])

function poss(seg, paths)
    # return possible next steps for seg
    curr = seg[end]

    if !(haskey(paths, curr)) | (curr == "end")
        return []
    end

    doubleok = !hasdoublevisit(seg)

    [c for c in paths[curr] if (c != "start") & (doubleok | !(c in seg) | isbig(c))]
end

paths = parseinp("test")
start = ["start"]
@test length(grow(start, paths)) == 36

paths = parseinp("input")
res = length(grow(start, paths))
println("Part B, ", res)
