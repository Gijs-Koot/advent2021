using Statistics
using Test

function parseinp(fn)
    parse.(Int, split(read(fn, String), ","))
end

inp = parseinp("test")

med = round(Int, median(inp))
@test med == 2
@test sum(abs.(inp .- med)) == 37

inp = parseinp("input")
med = round(Int, median(inp))
res = sum(abs.(inp .- med))
print("Part A: ", res)


function costs(n)
    sum(i for i in range(1, length = abs(n)))
end

@test costs(0) == 0
@test costs(2) == 3
@test costs(-3) == 6

function cost(inp, a)
    sum(costs.(inp .- a))
end

inp = parseinp("test")
cost(inp, 2)

function best(inp)
    poss = [cost(inp, a) for a in range(minimum(inp), stop=maximum(inp))]
    minimum(poss)
end

@test best(inp) == 168

inp = parseinp("input")
best(inp)

