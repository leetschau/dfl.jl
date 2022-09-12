function add_disk(callsign::String;
        organization::String="personal",
        uri::String="",
        description::String="")::Nothing
    diskset = load_disks(diskspath)
    push!(diskset, DiskRec(callsign, organization, uri, description))
    save_disks(diskset, diskspath)
end

function list_disks()::Nothing
    diskset = load_disks(diskspath)
    println(diskset)
end

function remove_disk(id::String)::Nothing
    diskset = load_disks(diskspath)
    deleteat!(diskset, findfirst(x -> x.callsign == id, diskset))
    save_disks(diskset, diskspath)
end

function edit_disk(id::String)::Nothing
    diskset = load_disks(diskspath)
    target_inds = findall(x -> x.callsign == id, diskset)
    targets = getindex(diskset, target_inds)
    tmpfn = tempname()
    save_disks(targets, tmpfn)
    run(pipeline(`nvim $tmpfn`, stdin=stdin))
    newdisks = load_disks(tmpfn)
    deleteat!(diskset, target_inds)
    append!(diskset, newdisks)
    save_disks(diskset, diskspath)
end

function set_current_disk(id::String)::Nothing
    confs = load_confs(confspath)
    newconfs = setproperties(confs, current_disk=id)
    println(typeof(newconfs))
    save_confs(newconfs, confspath)
end
