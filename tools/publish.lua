function main(...)
    local root = path.absolute(path.join(os.scriptdir(), ".."))
    os.cd(root)
    local argv = {...}

    for i = 1, #argv do
        local deb = argv[i]
        if not os.isfile(deb) then
            io.stderr:write("no such file: " .. deb .. "\n")
            os.exit(1)
        end
        local name = path.filename(deb)
        os.cp(deb, path.join("debs", name))
        print("added " .. name)
    end

    os.runv("dpkg-scanpackages", {"-m", "debs", "/dev/null"}, {stdout = "Packages", stderr = os.nuldev()})
    os.runv("gzip", {"-nkf", "Packages"})
    os.runv("bzip2", {"-kf", "Packages"})

    local header = {}
    for line in io.lines("Release") do
        if line:find("^MD5Sum:") or line:find("^SHA1:") or line:find("^SHA256:") then
            break
        end
        header[#header + 1] = line
    end

    local out = assert(io.open("Release", "wb"))
    for i = 1, #header do
        out:write(header[i], "\n")
    end

    local function block(label, hashfn)
        out:write(label, ":\n")
        for _, name in ipairs({"Packages", "Packages.gz", "Packages.bz2"}) do
            out:write(" ", hashfn(name), " ", tostring(os.filesize(name)), " ", name, "\n")
        end
    end

    block("MD5Sum", hash.md5)
    block("SHA1", hash.sha1)
    block("SHA256", hash.sha256)
    out:close()

    print("")
    local count = 0
    local versions = {}
    local current
    for line in io.lines("Packages") do
        if line:find("^Package:") then
            count = count + 1
            current = line:match("^Package:%s*(%S+)")
        end
        local version = line:match("^Version:%s*(%S+)")
        if version then
            versions[#versions + 1] = "  " .. current .. " " .. version
        end
    end
    print("indexed " .. count .. " package(s):")
    for i = 1, #versions do
        print(versions[i])
    end
end
