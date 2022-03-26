using Test

struct SeaFloor
    height::Int16
    width::Int16
    east::Set{Tuple{Int16,Int16}}
    south::Set{Tuple{Int16,Int16}}
end

function Base.:(==)(a::SeaFloor, b::SeaFloor)
    (a.height == b.height) & (a.width == b.width) & (a.east == b.east) & (a.south == b.south)
end

function parseinp(fn)
    # return SeaFloor
    m = readlines(fn)
    c = hcat([[c for c in l] for l in m]...)

    east = Set{Tuple{Int16,Int16}}()
    south = Set{Tuple{Int16,Int16}}()

    for (ic, col) in enumerate(eachcol(c))
        for (ir, val) in enumerate(col)
            if val == '>'
                push!(east, (ic, ir))
            elseif val == 'v'
                push!(south, (ic, ir))
            end
        end
    end

    width, height = size(c)

    SeaFloor(height, width, east, south)
end

test = parseinp("test")

function Base.show(io::IO, sea::SeaFloor)
    for row in 1:sea.height
        for column in 1:sea.width
            if (row, column) in sea.east
                print('>')
            elseif (row, column) in sea.south
                print('v')
            else
                print('.')
            end
        end
        print('\n')
    end
end


function step(sea::SeaFloor)
    new_east = Set{Tuple{Int16, Int16}}()
    new_south = Set{Tuple{Int16, Int16}}()
    # east moves
    occupied = union(sea.east, sea.south)
    for (row, column) in sea.east
        tgt = (row, column % sea.width + 1)
        if tgt in occupied
            push!(new_east, (row, column))
        else
            push!(new_east, tgt)
        end
    end
    # south moves
    occupied = union(new_east, sea.south)
    for (row, column) in sea.south
        tgt = (row % sea.height + 1, column)
        if tgt in occupied
            push!(new_south, (row, column))
        else
            push!(new_south, (tgt))
        end
    end
    SeaFloor(sea.height, sea.width, new_east, new_south)
end

function untilstatic(sea::SeaFloor)
    current = sea
    next = step(sea)
    i = 1
    while next != current
        i += 1
        current = next
        next = step(next)
    end
    i, current
end

n, final = untilstatic(test)

@test n == 58

inp = parseinp("input")

n, final = untilstatic(inp)

println("Part A: ", n)
