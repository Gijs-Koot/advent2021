using Test
using StaticArrays

mutable struct Card
    nums::SMatrix{5, 5, Int}
    marked::SMatrix{5, 5, Bool}
end

function parsecard(lines::Array{String, 1})
    Card(
        SMatrix{5, 5}(hcat([parse.(Int, l) for l in split.(lines)]...)),
        SMatrix{5, 5}(zeros(Bool, 5, 5))
    )
end

function score(card::Card)
    sum(.!card.marked .* card.nums)
end

function wins(card::Card)
    for r in 1:5
        if all(card.marked[r, :])
            return score(card)
        end
    end
    for c in 1:5
        if all(card.marked[:, c])
            return score(card)
        end
    end
    0
end

blck = ["22 13 17 11  0", " 8  2 23  4 24", "21  9 14 16  7", " 6 10  3 18  5", " 1 12 20 15 19"]
card = parsecard(blck)

@test size(card.nums) == (5, 5)

function mark!(card::Card, n)
    card.marked = card.marked .| (card.nums .== n)
end

begin_score = sum(card.nums)

mark!(card, 5)
mark!(card, 7)

@test sum(card.marked) == 2
@test score(card) == begin_score - 12

@test wins(card) == 0
card.marked = ones(Bool, 5) * [true false false false false]
@test wins(card) == sum(card.nums[:, 2:end])

function parseinp(fn)

    lines = readlines(fn)

    rnd_line = lines[1]
    rnd = parse.(Int, split(rnd_line, ","))

    cards::Array{Card, 1} = []
    maxl = length(lines)
    
    for i in 3:6:maxl
        blck = lines[i:i+4]
        card = parsecard(blck)
        push!(cards, card)
    end
            
    rnd, cards
end

(rnd, cards) = parseinp("test")

@test length(cards) == 3

function play(rnd, cards)
    for bingo in rnd
        for card in cards
            mark!(card, bingo)
            score = wins(card)
            if score > 0
                return score * bingo
            end
        end
    end
end

@test play(rnd, cards) == 4512

# part A

rnd, cards = parseinp("input")
res = play(rnd, cards)
println("Part A: ", res)

# part B

function playloser(rnd, cards)
    for bingo in rnd
        for card in cards
            mark!(card, bingo)
        end

        next = [card for card in cards if (wins(card) == 0)]

        if length(next) == 0
            winner = cards[end]
            return bingo * score(winner)
        end

        cards = next

    end

end

rnd, cards = parseinp("test")
@test playloser(rnd, cards) == 1924

rnd, cards = parseinp("input")
res = playloser(rnd, cards)
println("Part B: ", res)
