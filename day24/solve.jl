using Test
using Printf
using DataStructures
using StaticArrays
using Random
using Base
using Match

POSITIONS = Dict(
    'w' => 1,
    'x' => 2,
    'y' => 3,
    'z' => 4
)

struct State{memsize}
    mem::MVector{memsize, Int}
    tape::Queue{Int}
end

function pos(var::Char)
    # return memory position of variable name
    POSITIONS[var]
end

pos(var::AbstractString) = pos(String(var))
function pos(var::String)
    pos(var[1])
end

@test pos("w") == 1

# instructions

function input!(state::State, pos)
    # add tape entry to mem
    state.mem[pos] = dequeue!(state.tape)
end

function operm!(state, tgt, src, op)
    state.mem[tgt] = op(state.mem[tgt], state.mem[src])
end

function operv!(state, tgt, val, op)
    state.mem[tgt] = op(state.mem[tgt], val)
end

function parsev(val::AbstractString)
    # true if uses mem input, then index or input value
    @match val begin
        "w" || "x" || "y" || "z" => (true, POSITIONS[val[1]])
        _ => (false, Base.parse(Int, val))
    end
end

function parseop(word::AbstractString)
    @match word begin
	      "add" => +
        "mul" => *
        "div" => ÷
        "mod" => %
        "eql" => (a, b) -> Int64(a == b)
    end
end

@test parseop("eql")(2, 3) == 0
@test parseop("eql")(2, 2) == 1
@test parseop("div")(20, 3) == 6
@test parseop("mul")(5, 6) == 30
@test parseop("mod")(5, 2) == 1
@test parseop("add")(12, 12) == 24

@test parsev("x") == (true, 2)
@test parsev("10") == (false, 10)

function parse(line::String)
    args = split(line)
    if length(args) == 2
        return state -> input!(state, pos(args[2]))
    end

    tgt = pos(args[2])
    mem, val = parsev(args[3])
    op = parseop(args[1])
    base = mem ? operm! : operv!
    state -> base(state, tgt, val, op)
end

parse("inp x")
parse("add w 23")

function init(tape)
    st = State(
        MVector{4}([0, 0, 0, 0]),
        Queue{Int64}()
    )
    for i in tape
        enqueue!(st.tape, i)
    end
    st
end

st = init([2, 3, 4, 5])

parse("inp x")(st)
@test st.mem[2] == 2
inp1 = parse("inp x")

parse("eql x w")(st)
@test st.mem[2] == 0

function parseinp(fn)
    # return vector of instructions
    parse.(readlines(fn))
end

program = parseinp("test")

function apply(program, tape)
    st = init(tape)
    for instr! in program
        instr!(st)
    end
    st
end

# test if this does binary stuff
@test apply(program, [13]).mem == [1, 1, 0, 1]

function isvalid(program, modelno)
    if '0' in modelno return false end
    tape = [Base.parse(Int64, c) for c in modelno]
    apply(program, tape).mem[4] == 0
end

program = parseinp("input")
isvalid(program, "13579246899999")

function part1(program)
    max = 9999_9999_9999_99
    for modelno in max:-1:1
        if (modelno % 1_000_000) == 0
            println("at ", modelno)
        end
        if isvalid(program, @sprintf("%014d", modelno))
            println(modelno)
        end
    end
end

# MUHAHAHAHAHAHA

function applyno(program, modelno)
    no = @sprintf("%014d", modelno)
    tape = [Base.parse(Int, c) for c in no]
    apply(program, tape)
end

function infer(program, rangee)
    for modelno in rangee
        pretty = @sprintf("%014d", modelno)
        mem = applyno(program, modelno).mem
        println(pretty, " -- ", mem)
    end
end

function totape(v::Int)
    pretty = @sprintf("%014d", v)
    [Base.parse(Int, c) for c in pretty]
end

infer(program, 1111_1111_1111_11:1111_1111_1111_11:9999_9999_9999_99)

function showmem(program, modelno)
    tape = totape(modelno)
    st = init(tape)
    for (ix, instr!) in enumerate(program)
        instr!(st)
        if (ix % 18) == 0
            println(st.mem[4])
        end
    end
end

# highest
 
#      abcd_efgh_ijkl_mn
code = 9129_7395_9199_93
showmem(program, code)

(a + 0)
(a + 0) (b + 12)
(a + 0) (b + 12) (c + 14)
(a + 0) (b + 12) (c + 14) (d + 0)

e = d + 0 - 2

(a + 0) (b + 12) (c + 14)
(a + 0) (b + 12) (c + 14) (f + 15)
(a + 0) (b + 12) (c + 14) (f + 15) (g + 11)

h = g + 11 - 15 = g - 4

(a + 0) (b + 12) (c + 14) (f + 15) (i + 1)

j = i + 1 - 9 = i - 8
k = f + 15 - 9 = f + 6
l = c + 14 - 7 = c + 7
m = b + 12 - 4 = b + 8
n = a + 0 - 6 = a - 6

# lowest

#      abcd_efgh_ijkl_mn
code = 7113_1151_9178_91
showmem(program, code)
