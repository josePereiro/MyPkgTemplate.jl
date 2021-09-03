module MyPkgTemplate

    using PkgTemplates
    import Pkg
    import LibGit2

    export mygenerate

    const ROOT = dirname(@__DIR__)

    load_gitignore() = read(joinpath(ROOT, ".gitignore"), String)

    default_user() = LibGit2.getconfig("user.name", "")

    function default_plugins()
        gitignore = load_gitignore()
        return [
            ProjectFile, SrcDir,
            Tests, Readme, License, 
            !CompatHelper, !TagBot, !Codecov,
            Git(ignore = [gitignore], manifest = true),
            GitHubActions(;coverage = false)
        ]
    end

    function _cp(src_, dst_; kwargs...)
        mkpath(dirname(src_))
        mkpath(dirname(dst_))
        cp(src_, dst_; kwargs...)
    end

    function mygenerate(pkgname; 
            user = default_user(), julia = v"1.5.0"
        )

        dir = Pkg.devdir()
        pkgdir = joinpath(dir, replace(pkgname, ".jl" => ""))

        plugins = default_plugins()
        t = Template(;user, julia, plugins, dir)
        generate(t, pkgname)

        # copy tagged-release.yml
        _cp(
            joinpath(ROOT, ".github/workflows/tagged-release.yml"),
            joinpath(pkgdir, ".github/workflows/tagged-release.yml");
            force = true
        )
        
        return pkgdir
    end

end
