using Test

function parseinp(fn)
    hcat([parse.(Int, l) for l in split.(readlines(fn), "")]...)'
end

mat = parseinp("test")

function find(mat, n)
    rows, cols = size(mat)
    for r in 1:rows, c in 1:cols
        if mat[r, c] == n
            return (r, c)
        end
    end
    (0, 0)
end

@test find(mat, 5) == (1, 1)
@test isnothing(find(mat, 100))

function flash!(mat, row, column)
    for dr in -1:1, dc in -1:1
        try
            mat[row+dr, column+dc] += 1
        catch
            
        end
    end
end

mat = zeros(Int64, (5, 5))
flash!(mat, 5, 3)
@test sum(mat) == 6

function step!(mat)
    flashed = mat .< 0  # false everywhere

    mat .+= 1
    toflash = mat .== 10

    while sum(toflash) > 0
        for ix in findall(toflash)
            row, column = ix.I
            flash!(mat, row, column)
        end
        flashed .|= toflash
        toflash = (mat .>= 10) .& .!(flashed)
    end
    mat[flashed] .= 0
    sum(flashed)
end

mat = parseinp("test")
step!(mat)
step!(mat)
mat

function countflashes!(mat, steps)
    n = 0
    for _ in 1:steps
        n += step!(mat)
    end
    n
end

mat = parseinp("test")
@test countflashes!(copy(mat), 10) == 204
@test countflashes!(copy(mat), 100) == 1656

mat = parseinp("input")
res = countflashes!(copy(mat), 100)
println("Part A: ", res)


function brightflash!(mat, maxsteps)
    for step in 1:maxsteps
        n = step!(mat)
        if n == length(mat)
            return step
        end
    end
end

mat = parseinp("test")
@test brightflash!(copy(mat), 2000) == 195

mat = parseinp("input")
res = brightflash!(copy(mat), 20000)
println("Part B: ", res)
