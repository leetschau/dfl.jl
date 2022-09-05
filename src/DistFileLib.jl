module DistFileLib

function add(filepath)
    print("add a new file: $(filepath)")
end

function remove(id)
    print("remove an existing file with ID $(id)")
end

function julia_main()::Cint
    if ARGS[1] == "add"
        add(ARGS[2])
    elseif ARGS[1] == "del"
        remove(ARGS[2])
    else
        print("Unknown command: $(ARGS[1])")
    end
    return 0
end

end # module
