# TODO
# remove types to support image formats (add generics)


#-- Configure logging
using Logging
log_config = ConsoleLogger(stderr, LogLevel(Debug))
global_logger(log_config)

#-- Handle command line arguments
using Base.Filesystem
include("./Keys.jl")
include("./Help.jl")
using .Keys, .Help

command = ARGS[1]
subargs = ARGS[2:end]

global savedir = pwd()  # Current working directory
global condense = false
global verbose = false
global quiet = false
global incognito = false

global key1 = ""
global key2 = ""

include("./Encrypt.jl")
using .Encrypt
if command == "encrypt"
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
    elseif sarg == "--save"
        if length(subargs) >= i + 1
            global savedir = subargs[i + 1]
            @debug("'savedir' set to $savedir")
            deleteat!(subargs, i + 1)
        end
    end
end # for loop
subargs = [item for item in subargs if first(item) != '-']
@debug("Subargs remaining: $subargs")
for sarg in subargs
    key1match = match(r"^key1=(.*)", sarg)
    if key1match !== nothing
        global key1 = key1match[1]
        @debug("'key1' set to \"$key1\"")
    end
    key2match = match(r"^key2=(.*)", sarg)
    if key2match !== nothing
        global key2 = key2match[1]
        @debug("'key2' set to \"$key2\"")
    end
end # for loop
subargs = [item for item in subargs if !occursin(r"^key\d=.*", item)]
@debug("Subargs remaining: $subargs")

if length(subargs) != 1
    encrypthelp()
else
    char_range = 0x2200, 0x22FF
    # TODO generate this based on matrix size & a supplied start point?
    # as part of secondary key, use mtx size and emsg length

    encrypt("Hello", true, charset(char_range))
end # encrypt execution

elseif command == "decrypt"
    # TODO handle decrypt command
    decrypthelp()
else
    nazcahelp()
end # Handle commands



