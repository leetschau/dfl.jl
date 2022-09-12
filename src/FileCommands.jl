"""
   Usage: init [<upstream>]

Initialize a new DFL repo.

Example: init git@gitee.com:charlize/dfl.git
"""
function init(cur_disk_callsign::String; upstream::String="")::Nothing
    if occursin("-h", upstream)  # `-h` or `--help`
        println(@doc init)
    elseif isempty(upstream)
        println("New repo created.")
    else
        exec("git clone $upstream $rootpath")
    end
end

function add_file(fpath::String;
             tagline::String="",
             desc::String="",
             uri::String="",
             relations::String="",
             topic::String="generic")::Nothing
    fileset = load_files(filespath)
    local_confs = load_confs(confspath)
    if isempty(local_confs.current_disk)
        println("""Current disk not set yet.
                Please set it with `set_current_disk()` and run this command again""")
        return nothing
    end
    fullpath = local_confs.current_disk * ':' * fpath
    out, _ = exec(`md5sum $(fpath)`)
    fhash = String(split(out, ' ')[1])

    if hash_match(fhash, fileset)
        println("File $fpath is already in the fileset")
        return nothing
    end

    push!(fileset, FileRec(
        create_id(fileset),
        basename(fpath),
        [fullpath],
        filesize(fpath),
        fhash,
        split(tagline, ','),
        desc,
        uri,
        Dict(),
        topic
    ))

    save_files(fileset, filespath)
    println("File $(fpath) added to DFL.")
end

function remove_file(id::Int)::Nothing
    fileset = load_files(filespath)
    deleteat!(fileset, id)
    save_files(fileset, filespath)
    println("File #$(id) removed")
end

function list_files()::Nothing
    fileset = load_files(filespath)
    println(fileset)
end

function edit_file(id::Int)::Nothing
    fileset = load_files(filespath)
    target_inds = findall(x -> x.id == id, fileset)
    targets = getindex(fileset, target_inds)
    tmpfn = tempname()
    save_files(targets, tmpfn)
    run(pipeline(`nvim $tmpfn`, stdin=stdin))
    newfiles = load_files(tmpfn)
    deleteat!(fileset, target_inds)
    append!(fileset, newfiles)
    save_files(fileset, filespath)
end
