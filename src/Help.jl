
module Help
export nazcahelp, encrypthelp, decrypthelp

function nazcahelp()
    println("""
Nazca 2023 0.0.1 by J. Stach.
Run 'julia Nazca.jl encrypt' or 'decrypt' to view command usage.
""")
end

function encrypthelp()
    println("""
Usage:
    julia Nazca.jl encrypt [-c] [-v|q] \
    [--key Path/To/Keys.yaml] "PLAIN TEXT" [--save Path/To/Save.yaml]

"PLAIN TEXT" is the message to encrypt and can be a string of
any characters from a-Z, 0-9, or space.

Options & flags:
    --condense, -c
        Minimizes matrix size by generating a key using only
        the set of characters present in the plaintext message.
    --verbose, -v
        Prints debug-level logs to the standard output.
        (Default behavior is to print "Info" logs and above.)
    --quiet, -q
        Turns off non-"Error" logging to the standard output.

    --key Path/To/Keys.yaml
        Specify the filepath of the encryption keys to use.
        (Default is to generate new random keys and save them separately.)

    --save Path/To/Save.yaml
        Set the save filepath for the generated ciphertext;
        keys will be generated in the same directory.
        (Default is to use arbitrary names and the current directory.)
    """)
end

function decrypthelp()
    println("""
Usage:
julia Nazca.jl decrypt [-v|q] --key Path/To/Keys.yaml Path/To/Cyphertext.yaml

"PLAIN TEXT" is the message to encrypt and can be a string of
any characters from a-Z, 0-9, or space.

Options & flags:
    --verbose, -v
        Prints debug-level logs to the standard output.
        (Default behavior is to print "Info" logs and above.)
    --quiet, -q
        Turns off non-"Error" logging to the standard output.

    --key Path/To/Keys.yaml
        Specify the filepath of the encryption keys to use.
""")
end

end # module Help
