# TODO
# remove types to support image formats (add generics)

module Nazca
export key1, key2

#-- Configure logging
using Logging
log_config = ConsoleLogger(stderr, LogLevel(Info))
global_logger(log_config)

#-- Handle command line arguments
include("./Keys.jl")
include("./Help.jl")
include("./File.jl")
using .Keys, .Help, .File

command = ARGS[1]
subargs = ARGS[2:end]

# Empty option argument variables
global savepath = ""

global keypath = ""
    global key1::Vector{Char} = []
    global key2::Vector{Char} = []

# Flags
global condense = false
global verbose = false
global quiet = false
global silent = false

include("./Encrypt.jl")
include("./Decrypt.jl")
using .Encrypt, .Decrypt

if command == "encrypt"
    # Parse arguments
    for (i, sarg) in enumerate(subargs)
        if sarg == "--quiet" || sarg == "-q"
            global quiet = true
            @debug("'quiet' set to true")
        elseif sarg == "--verbose" || sarg == "-v"
            global verbose = true
            @debug("'verbose' set to true")
        elseif sarg == "--condense" || sarg == "-c"
            global condense = true
            @debug("'condense' set to true")
        elseif sarg == "--key"
            if length(subargs) >= i + 1
                if okpath(subargs[i + 1])
                global keypath = subargs[i + 1]
                @debug("'keypath' set to $keypath")
                deleteat!(subargs, i + 1)
                else
                    @warn("Incorrect file format detected: Nazca uses .yaml")
                end
            end
        elseif sarg == "--save"
            if length(subargs) >= i + 1
                if okpath(subargs[i + 1])
                global savepath = subargs[i + 1]
                @debug("'savepath' set to $savepath")
                deleteat!(subargs, i + 1)
                else
                    @warn("Incorrect file format detected: Nazca uses .yaml")
                end
            end
        end
    end

    # Check remaining arguments
    subargs = [item for item in subargs if first(item) != '-']
    @debug("Subargs remaining: $subargs")
    if length(subargs) != 1
        @error("Requires exactly one plaintext message argument.")
        encrypthelp()
    else
        msg = subargs[1]
        newkey = false
        # TODO change file module to specific load/saves
        # Load keyfile, extract key1 and key2
        if !isempty(keypath)
            try open(keypath, "r") do io
                keys = YAML.load(io)
                if !isempty(keys["key1"]) global key1 = collect(keys["key1"]) end
                if !isempty(keys["key2"]) global key2 = collect(keys["key2"]) end
                end
            catch
                @warn("'$keypath' could not be read... Generating new key.")
            end
        else
            @debug("No keypath provided... Generating new key.")
        end
        if isempty(key1) || isempty(key2)
            newkey = true
        end
        ciphertext = encrypt(msg, condense)
        # TODO save matrix to location, and save keyfile if newkey
        if !isempty(savepath)
            try open(savepath, "w") do io
                YAML.dump(io, ciphertext) # TODO Better way to save that is readable?
                end
            catch
                @warn("Failed to save at specified location... Check your permission.")
            end
        else
            global savepath = newfile()
            #save(savepath, ciphertext)
        end
        # TODO save keys to same path with altered filename

    end

    # TODO DECRYPT
end # command argument parsing

end # module Nazca


