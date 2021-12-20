using Test

function parseinp(fn)
    parse.(Int, hcat(split.(readlines(fn), "")...))
end

mat = parseinp(fn)

# starting solution
start = ones(Int, size(mat)) * sum(mat)
start[1, 1] = 0

function neighbors(row, column, size)
    # find valid neighboring coordinates
    h, w = size
    s = [[row - 1, column], [row + 1, column], [row, column - 1], [row, column + 1]]
    [(r, c) for (r, c) in s if (0 < r <= h) & (0 < c <= w)]
end

@test neighbors(1, 1, size(mat)) == [(2, 1), (1, 2)]
@test length(neighbors(10, 3, size(mat))) == 3

function bellman(dist, cost)
    # update dist by cost
    dist = copy(dist)
    h, w = size(dist)
    for row in 1:h, column in 1:w
        for (nr, nc) in neighbors(row, column, size(dist))
            route = dist[nr, nc] + cost[row, column]
            dist[row, column] = minimum([dist[row, column], route])
        end
    end
    dist
end

bellman(start, mat)

function shortest(cost)
    dist = ones(Int, size(cost)) * sum(cost)
    dist[1, 1] = 0
    
    while true
        next = bellman(dist, cost)
        if all(next .== dist)
            break
        end
        dist = next
    end
    dist
end

@test shortest(mat)[end,end] == 40

cost = parseinp("input")
res = shortest(cost)[end, end]
println("Part A: ", res)


# part B

function expand(mat, n)
    row = hcat([mat .+ i for i in 0:(n-1)]...)
    vcat([row .+ i for i in 0:(n-1)]...)
end

test = expand(ones(Int, (2, 2)), 2)
@test size(test) == (4, 4)
@test test[end, end] == 3

function wrap(n)
    (n % 10) + div(n, 10)
end

@test wrap(10) == 1
@test wrap(4) == 4
@test wrap(20) == 2

cost = expand(parseinp("input"), 5)
res = shortest(wrap.(cost))[end, end]
println("Part B: ", res)
