
module Encrypt
using Random, Logging
include("./Matrix.jl")
include("./Keys.jl")
include("./Cypher.jl")
using .Matrix, .Keys, .Cypher
export encrypt

#-- Full encryption algorithm
function encrypt(msg::String, condense::Bool, charset)
    msg = sanitize(msg)

    # Primary Key
    key1 = primarykey(msg, condense)
    keystring1 = join(key1)
    @info("Primary key: $keystring1")

    emsg = primary_encryption(msg, key1)        # Encrypted msg

    # Secondary Key
    key2 = secondarykey(charset)
    keystring2 = join(key2[1:length(emsg) + 1])
    @info("Secondary key: $keystring2")

    dims = mtxdims(emsg)
    mtx = newmtx(dims)                          # Encryption matrix

    # Populate encryption matrix
    ox, oy = rand(1:dims[1]), rand(1:dims[2])   # Random origin
    mtx[ox, oy] = key2[1]
    placement(mtx, ox, oy, emsg, key2, 2)
    salt(mtx, key2, length(emsg) + 1)

    printmtx(mtx)
    @debug("Encryption ok")
    return mtx
end

# Cleans up input text to ensure only supported characters are included
function sanitize(str::String)
    clean_str = []
    for char in str
        if isdigit(char) || ( isascii(char) && isuppercase(char) )
            push!(clean_str, char)
        elseif isascii(char)
            push!(clean_str, uppercase(char))
        else
            @warn("Omitting '$char': Not supported by encryption method")
        end
    end
    return join(clean_str)
end

end # module Encrypt
