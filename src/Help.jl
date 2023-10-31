
module Help
export nazcahelp, encrypthelp, decrypthelp

function nazcahelp()
    println("""
Nazca 2023 0.0.1
Run 'julia Nazca.jl encrypt' or 'decrypt' to view usage.
    """)
end

function encrypthelp()
    println("""
Usage: julia Nazca.jl encrypt [-c] [-v|-q] [key1=Path/to/Key1] [key2=Path/To/Key2] [PLAINTEXT|Path/To/Text.txt] [--save Path/To/SaveDirectory]

Options:
    --condense, -c
        Minimizes matrix size by generating a key from the set of
        characters that are used in the plaintext message.
    --verbose, -v
        Prints all log info to the standard output.
    --quiet, -q
        Prints nothing to the standard output.

    --save Path/To/SaveDirectory
        Use this option to specify a directory to hold generated
        key and ciphertext files.
        (Default is current working directory.)
    """)
end

function decrypthelp()
    println("""
Usage: julia Nazca.jl decrypt [-v|-q] [-i] key1=[Path/to/Key1] key2=[Path/to/Key2] [Path/To/CipherText.txt] [--save Path/To/SaveDirectory]

Options:
    --verbose, -v
        Prints all log info to the standard output.
    --quiet, -q
        Prints nothing to the standard output.
    --incognito, -i
        Prints decrypted plaintext to the standard output
        but does not save to a file.

    --save Path/To/SaveDirectory
        Use this option to specify a directory to hold decrypted
        plaintext files.
        (Default is current working directory.)
    """)
end

end # module Help
