using StatsBase
using DataStructures

struct Node{width, depth, nrooms}
    hallway::NTuple{width,Char}
    siderooms::NTuple{nrooms,Tuple{Int,NTuple{depth,Char}}}
end

function isempty(c::Char)
    c == '.'
end

VALUES = ['A', 'B', 'C', 'D']

COSTS = Dict(
    'A' => 1,
    'B' => 10,
    'C' => 100,
    'D' => 1000
)

ASSIGNED = Dict(c => i for (i, c) in enumerate("ABCD"))

empty_hallway = Tuple('.' for _ in 1:11)
target_rooms = (3, ('A', 'A')), (5, ('B', 'B')), (7, ('C', 'C')), (9, ('D', 'D'))

goal = Node(empty_hallway, target_rooms)

function Base.show(io::IO, node::Node{width, depth, nrooms}) where {width, depth, nrooms}
    println(io, "#" ^ (width + 2))
    print(io, "#")
    for c in node.hallway
        print(io, c)
    end
    println(io, "#")
    for d in 1:depth
        for i in 1:(width + 2)
            found = false
            for (pos, room) in node.siderooms
                if i - 1 == pos
                    print(io, room[d])
                    found = true
                end
            end
            if !found
                print(io, '#')
            end
        end
        print(io, '\n')
    end
    println(io, "#" ^ (width + 2))
end

function available(node, loc)
    # return available locations in hallway from loc
    # up

    hallway = node.hallway
    locs = Set(r[1] for r in node.siderooms)
    av = Set{Int64}()

    if !isempty(hallway[loc])
        # cannot escape
        return av
    end

    for i in 1:(length(hallway)-loc)
        if isempty(hallway[loc+i])
            push!(av, loc + i)
        else
            break
        end
    end

    # down
    for i in 1:(loc-1)
        if isempty(hallway[loc-i])
            push!(av, loc - i)
        else
            break
        end
    end

    setdiff(av, locs)

end

function between(pos, tgt)
    if pos > tgt
        return tgt:(pos - 1)
    end
    (pos + 1):tgt
end

collect(between(20, 1))

function calcdepth(room)
    for i in length(room):-1:1
        if isempty(room[i])
            return i
        end
    end
end

function neighbors(node::Node{width, depth, nrooms}) where {width, depth, nrooms}
    # return set of cost, node tuples
    nb = Set{Tuple{Int, Node}}()
    # move into hallway
    for (loc, room) in node.siderooms
        for (d, char) in enumerate(room)
            if !isempty(char)
                for spot in available(node, loc)
                    # make new node with setindex
                    cost = COSTS[char] * (d + (abs(spot - loc)))
                    nh = Base.setindex(node.hallway, char, spot)
                    nr = (loc, Base.setindex(room, '.', d))
                    nrs = Tuple(room[1] == loc ? nr : room for room in node.siderooms)
                    push!(nb, (cost, Node(nh, nrs)))
                end
                break
            end
        end
    end

    # move into room
    for (pos, char) in enumerate(node.hallway)
        if char == '.' continue end
        (tgt, room) = node.siderooms[ASSIGNED[char]]  # needs to go here
        # test if path is empty
        if all(isempty(node.hallway[i]) for i in between(pos, tgt))
            # test if room has spot
            if all(c in ('.', char) for c in room) & any(isempty(c) for c in room)
                # construct new node
                nd = calcdepth(room)
                cost = COSTS[char] * (nd + abs(pos - tgt))
                nh = Base.setindex(node.hallway, '.', pos)
                nr = (tgt, Base.setindex(room, char, nd))
                nrs = Tuple(room[1] == tgt ? nr : room for room in node.siderooms)
                push!(nb, (cost, Node(nh, nrs)))
            end
        end
    end
    nb
end

function heuristic(node::Node{width, depth, nrooms}) where {width, depth, nrooms}
    # return minimum cost
    cost = 0
    # hallway nodes
    for (loc, char) in enumerate(node.hallway)
        if !isempty(char)
            tgtloc = node.siderooms[ASSIGNED[char]][1]
            cost += COSTS[char] * (2 * abs(tgtloc - loc) + depth + 1)
        end
    end
    # room nodes
    for ((loc, room), assigned) in zip(node.siderooms, VALUES)
        for (d, char) in enumerate(room)
            if !isempty(char)
                if char == assigned
                    cost += COSTS[char] * (-d * 2 + depth + 1)  # cheaper when on deep level
                else
                    tgtloc = node.siderooms[ASSIGNED[char]][1]
                    moves = (d + abs(loc - tgtloc)) * 2 + depth + 1
                    cost += moves * COSTS[char]
                end
            end
        end
    end
    cost ÷ 2
end

heuristic(goal)

start_rooms = (3, ('B', 'A')), (5, ('C', 'D')), (7, ('B', 'C')), (9, ('D', 'A'))
start = Node(empty_hallway, start_rooms)

heuristic(start)

function a_star(start, goal)

    gscore = Dict{typeof(start), Int64}()
    queue = PriorityQueue{typeof(start), Int64}()

    camefrom = Dict{typeof(start), typeof(start)}()

    gscore[start] = 0
    enqueue!(queue, start, heuristic(start))

    visited = Set{typeof(start)}()

    while true
        current, cost = dequeue_pair!(queue)
        if current == goal
            return cost, camefrom, gscore
        end
        for (extra, nb) in neighbors(current)
            if !(nb in visited)
                gscore[nb] = extra + gscore[current]
                total = gscore[nb] + heuristic(nb)
                queue[nb] = total
                camefrom[nb] = current
            end
        end
        push!(visited, current)
    end
end

cost, camefrom, gscore = a_star(start, goal);

# reconstruct path
function reconstruct(start, goal, camefrom)
    path = Vector{Node}()
    current = goal
    while current != start
        prepend!(path, [current])
        current = camefrom[current]
    end
    
    for step in path
        println("== ", gscore[step])
        show(step)
    end
end

th = Tuple(c for c in ".........A.")
rooms = (3, ('B', 'A')), (5, ('.', 'B')), (7, ('C', 'C')), (9, ('D', 'D'))
test = Node(th, rooms)

for (cost, nb) in neighbors(test)
    println("== ", cost, " ", heuristic(nb))
    show(nb)
end


th = Tuple(c for c in "BC.B.D...CA")
rooms = (3, ('.', '.')), (5, ('.', '.')), (7, ('.', '.')), (9, ('D', 'A'))
test = Node(th, rooms)

show(test)

for (cost, nb) in neighbors(test)
    show(nb)
end

part1rms = (3, ('B', 'C')), (5, ('B', 'A')), (7, ('D', 'D')), (9, ('A', 'C'))
part1 = Node(empty_hallway, part1rms)
cost, camefrom, gscore = a_star(part1, goal);
println("part I ", cost)

# part II

rooms = (3, ('B', 'D', 'D', 'C')), (5, ('B', 'C', 'B', 'A')), (7, ('D', 'B', 'A', 'D')), (9, ('A', 'A', 'C', 'C'))
goal2rms = (3, ('A', 'A', 'A', 'A')), (5, ('B', 'B', 'B', 'B')), (7, ('C', 'C', 'C', 'C')), (9, ('D', 'D', 'D', 'D'))
goal2 = Node(empty_hallway, goal2rms)
part2 = Node(empty_hallway, rooms)

cost, camefrom, gscore = a_star(part2, goal2)
