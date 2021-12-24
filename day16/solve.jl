using Test

hexstr = strip(read("input", String))

function tobin(hexstr)
    join([bitstring(parse(Int8, c; base=16))[end-3:end] for c in hexstr])
end

@test tobin("D2FE28") == "110100101111111000101000"

function eatliteral(bin)
end

bin = "110100101111111000101000"

struct Literal
    version::Int
    type_id::Int
    value::Int 
end

struct Operator
    version::Int
    type_id::Int
    subpackages::Vector{Union{Literal, Operator}}
end

function parsebin(str)
    parse(Int, str; base=2)
end

function parseheader(bin)
    parsebin(bin[1:3]), parsebin(bin[4:6]), bin[7:end]
end

@test parseheader(bin)[1:2] == (6, 4)

function parseliteral(bin)
    fours = Vector{String}([])
    ix = 1
    lead = '1'
   
    while lead == '1'
        lead = bin[ix]
        bits = bin[ix+1:ix+4]
        push!(fours, bits)
        ix += 5
    end

    parsebin(join(fours)), bin[ix: end]
end

v, t, res = parseheader(bin)
@test parseliteral(res)[1] == 2021

function parsepacket(bin)
    version, type, body = parseheader(bin)
    if type == 4
        value, res = parseliteral(body)
        return Literal(version, type, value), res
    end
    sub, res = parseoperator(body)
    Operator(version, type, sub), res
end

hx = tobin("D2FE28")
parseheader(hx)
parsepacket(hx)

function parselength(bin)
    is_bit_length = bin[1] == '0'
    last_length_bit = is_bit_length ? 15 : 11
    len = parsebin(bin[2:last_length_bit+1])
    is_bit_length, len, bin[last_length_bit+2:end]
end

hx = tobin("38006F45291200")
header, type, res = parseheader(hx)
is_bit_length, len, res = parselength(res)
@test is_bit_length == true
@test len == 27

hx = tobin("EE00D40C823060")
header, type, res= parseheader(hx)
is_bl, len, res = parselength(res)
@test is_bl == false
@test len == 3

function parseoperator(bin)
    is_bl, len, res = parselength(bin)
    sub = Vector{Union{Literal, Operator}}([])

    if is_bl
        orig_len = length(res)
        while orig_len - length(res) < len
            packet, res = parsepacket(res)
            push!(sub, packet)
        end
    else
        for _ in 1:len
            packet, res = parsepacket(res)
            push!(sub, packet)
        end
    end
    sub, res
end

hx = tobin("EE00D40C823060")
sub, res = parseoperator(hx[7:end])
@test length(sub) == 3

op, altres = parsepacket(hx)
@test sub == op.subpackages
@test altres == res

hx = tobin("8A004A801A8002F478")
parsepacket(hx)

# part A

function sumversion(pkt::Literal)
    pkt.version
end

function sumversion(pkt::Operator)
    sum(sumversion(sub) for sub in pkt.subpackages) + pkt.version
end

hx = tobin("8A004A801A8002F478")
parsed, res = parsepacket(hx)

@test sumversion(parsed) == 16

hx = tobin("A0016C880162017C3686B18A3D4780")
parsed, res = parsepacket(hx)
@test sumversion(parsed) == 31

inp = strip(read("input", String))
hx = tobin(inp)
parsed, res = parsepacket(hx)

sumversion(parsed)

# part B

function value(pkt::Literal)
    pkt.value
end

using Match

function value(pkt::Operator)
    subvals = [value(sub) for sub in pkt.subpackages]
    res = @match pkt.type_id begin
        0 => sum(subvals)
        1 => prod(subvals)
        2 => minimum(subvals)
        3 => maximum(subvals)
        5 => (subvals[1] > subvals[2]) ? 1 : 0
        6 => (subvals[1] < subvals[2]) ? 1 : 0
        7 => (subvals[1] == subvals[2]) ? 1 : 0
    end
    res
end

function value(hx::AbstractString)
    bin = tobin(hx)
    parsed, _ = parsepacket(bin)
    value(parsed)
end

@test value("C200B40A82") == 3
@test value("04005AC33890") == 54
@test value("880086C3E88112") == 7
@test value("CE00C43D881120") == 9
@test value("D8005AC2A8F0") == 1
@test value("F600BC2D8F") == 0
@test value("9C005AC2F8F0") == 0
@test value("9C0141080250320F1802104A08") == 1

res = value(strip(read("input", String)))
println("Part B: ", res)
