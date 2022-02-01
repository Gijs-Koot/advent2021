using Test
using IterTools

mutable struct Game
    pos::Vector{Int}
    score::Vector{Int}
    turn::Int
end

game = Game([4, 8], [0, 0], 1)

function switch!(game::Game)
    # switch player
    game.turn = game.turn % 2 + 1
end

switch!(game)
@test game.turn == 2
switch!(game)
@test game.turn == 1

function stepf(pos, steps)
    # move modulo
    (pos - 1 + steps) % 10 + 1
end

@test stepf(7, 5) == 2
@test stepf(8, 2) == 10

function move!(game::Game, steps)
    # move the current player steps step up
    # return score
    game.pos[game.turn] = stepf(game.pos[game.turn], steps)
    game.score[game.turn] = game.score[game.turn] + game.pos[game.turn]
    score = game.score[game.turn]
    switch!(game)
    score
end

function play!(game::Game, die)
    ix = 0
    for throw in partition(die, 3)
        score = move!(game, sum(throw))
        ix += 3
        if score >= 1000
            break
        end
    end
    minimum(game.score) * ix
end

game = Game([4, 8], [0, 0], 1)
die = 1:1000
@test play!(game, die) == 739785

# part A
game = Game([3, 10], [0, 0], 1)
die = 1:1000
ans = play!(game, die)
println("Part A ", ans)

# part B

# all possible steps to take for different universes
splits = [sum([x, y, z]) for x in 1:3, y in 1:3, z in 1:3]

# for sanity lets make game immutable
struct DGame
    pos::Tuple{Int, Int}
    score::Tuple{Int, Int}
    turn::Bool  # true: player one
end

function move(game::DGame, steps)
    # return new game position
    p, q = game.pos
    s, t = game.score

    if game.turn
        p = stepf(p, steps)
        s += p 
    else
        q = stepf(q, steps)
        t += q
    end

    DGame((p, q), (s, t), !game.turn)
end

game = DGame((4, 8), (0, 0), true)

known_scores = Dict{DGame, Tuple{Int, Int}}()

function score(game)
    if game in keys(known_scores)
        return known_scores[game]
    end
    p = 0
    q = 0
    for throw in splits
        universe = move(game, throw)
        if maximum(universe.score) >= 21
            if universe.score[1] >= 21
                p += 1
            else
                q += 1
            end
        else
            s, t = score(universe)
            p += s
            q += t
        end
    end
    known_scores[game] = (p, q)
    p, q
end

@test score(game)

# part B

game = DGame((3, 10), (0, 0), true)

ans = maximum(score(game))

println("Part B: ", ans)
