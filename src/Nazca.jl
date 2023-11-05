# TODO
# remove types to support image formats (add generics)
# config file or args?

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

# Default global variables
global savepath = ""

global keypath = ""
    global key1::Vector{Char} = []
    global key2::Vector{Char} = []

# Flags
global condense = false
global verbose = false
global quiet = false

# Parse top level commands
include("./Encrypt.jl")
include("./Decrypt.jl")
using .Encrypt, .Decrypt
if command == "encrypt"                     # ENCRYPT command
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
                    @warn("Incorrect file format detected: Nazca uses YAML (.yaml or .yml)")
                end
            end
        elseif sarg == "--save"
            if length(subargs) >= i + 1
                if okpath(subargs[i + 1])
                global savepath = subargs[i + 1]
                @debug("'savepath' set to $savepath")
                deleteat!(subargs, i + 1)
                else
                    @warn("Incorrect file format detected: Nazca uses YAML (.yaml or .yml)")
                end
            end
        end
    end

    # Check remaining arguments
    subargs = [item for item in subargs if first(item) != '-'] # TODO debug
    @debug("Subargs remaining: $subargs")
    if length(subargs) != 1
        @error("Requires exactly one plaintext message argument.")
        encrypthelp()
    else
        msg = subargs[1]
        newkey = false

        # Load keyfile, extract key1 and key2
        if !isempty(keypath) loadkeys(keypath)
        else
            @debug("No keyfile provided... Generating new key.")
        end
        if isempty(key1) || isempty(key2)
            newkey = true
        end

        # Encrypt the message to product ciphertext
        cyphertext = encrypt(msg, condense)

        # Save the cyphertext to a new file
        if !isempty(savepath)
            savecyphertext(savepath, cyphertext)
            @info("Ciphertext saved to $savepath")
        else
            global savepath = newfile()
            savecyphertext(savepath, cyphertext)
            @info("Ciphertext saved to $savepath")
        end

        # If new keys were generated, save them alongside the ciphertext
        if newkey == true
            savepathregex = r"(.*/)?([^/]+)\.yaml$"      # Kate IDE hl breaks on "$" in regex.
            regexmatch = match(savepathregex, savepath)
            if regexmatch !== nothing
                savedir = regexmatch.captures[1]
                keysave = regexmatch.captures[2] * "_keys.yaml"
                savekeys(keysave)
                @info("Keys saved to $keysave")
            else
                @error("Failed to parse save path. New keyfile was not saved.")
            end
        end
    end

# TODO DECRYPT
elseif command == "decrypt"                     # DECRYPT command
    # Parse arguments
    for (i, sarg) in enumerate(subargs)
        if sarg == "--quiet" || sarg == "-q"
            global quiet = true
            @debug("'quiet' set to true")
        elseif sarg == "--verbose" || sarg == "-v"
            global verbose = true
            @debug("'verbose' set to true")
        elseif sarg == "--key"
            if length(subargs) >= i + 1
                if okpath(subargs[i + 1])
                global keypath = subargs[i + 1]
                @debug("'keypath' set to $keypath")
                deleteat!(subargs, i + 1)
                else
                    @warn("Incorrect file format detected: Nazca uses YAML (.yaml or .yml)")
                end
            end
        end
    end

    # Check remaining arguments
    subargs = [item for item in subargs if first(item) != '-'] # TODO debug
    @debug("Subargs remaining: $subargs")
    if length(subargs) != 1
        @error("Requires exactly one cyphertext path argument.")
        decrypthelp()
    else
        ct = subargs[1]
        cyphertext = loadcyphertext(ct)

        # Load keyfile, extract key1 and key2
        if !isempty(keypath) loadkeys(keypath)
        else
            @error("No keyfile provided... Unable to decrypt.")
        end

        # Decrypt the cyphertext to product plaintext
        plaintext = decrypt(cyphertext)

        # Save the decrypted message
        ctpathregex = r"(.*/)?([^/]+)\.yaml$"      # Kate IDE hl breaks on "$" in regex.
        regexmatch = match(ctpathregex, ct)
        if regexmatch !== nothing
            savedir = regexmatch.captures[1]
            decryptsave = regexmatch.captures[2] * "_decrypted.yaml"
            saveplaintext(decryptsave, plaintext)
            @info("Message saved to $decryptsave")
        else
            @error("Failed to parse file path. Message was not saved.")
        end
    end

# TODO DISPLAY
end # command argument parsing

end # module Nazca


