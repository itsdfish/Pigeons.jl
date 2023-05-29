# Use this to debug tests, e.g. calling a single test_xxx.jl file. 

# Add the parent project by path to the test project. 
# If we do not do this, we will end up testing the 
# latest released version instead of the one checked out.

# We have to do this because ChildProcess/MPI depend on  
# a single toml file to know how to load Pigeons and other 
# dependencies. 

using Pkg
test_dir = @__DIR__
@assert basename(test_dir) == "test"
Pkg.activate(test_dir)
project_root_dir = dirname(test_dir)
Pkg.develop(PackageSpec(path=project_root_dir))

# import/using statements
include("common_includes.jl")

@info   """
        next time you call `test` from the parent project 
        to run all tests, you may get the error message 

            "ERROR: can not merge projects"

        to address this, simply delete the 
        generated file "test/Manifest.toml"
        """