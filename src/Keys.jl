
module Keys
using Random
export primarykey, secondarykey, charset

# Generates a standard distance key for the plaintext message
function primarykey(msg::String, condense::Bool)
    if condense == false
        valid_chars = collect("ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789")
    else
        valid_chars = collect(Set(msg))
    end

    primary_key = shuffle(valid_chars)
    return primary_key
end

# Shuffles the provided charset to create a random marker + salt order
function secondarykey(charset)
    charset = collect(charset)
    secondary_key = shuffle!(charset)
    return secondary_key
end

# Generates a charset from a unicode range, to be randomized as a secondary key
function charset((first, last))
    charset = []
    for codepoint in first:last
        push!(charset, Char(codepoint))
    end
    return charset
end

# TODO create unicode range from starting point and length

# TODO save keys to file, read keys from file

end # module Keys
