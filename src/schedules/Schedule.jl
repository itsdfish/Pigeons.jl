"""
A partition of [0, 1] encoded by monotonically increasing grid points 
starting at zero and ending at one.
"""
struct Schedule
    """Monotone increasing with end points at zero and one."""
    grids::Vector{Float64} 
    """
    $TYPEDSIGNATURES
    """
    function Schedule(grids) 
        @assert issorted(grids)
        @assert first(grids) == 0.0
        @assert last(grids) == 1.0
        new(convert(Vector{Float64}, grids))
    end
end

n_chains(schedule::Schedule) = length(schedule.grids)

"""
$TYPEDSIGNATURES
Create a [`Schedule`](@ref) with `n_chains` equally spaced grid points.
"""
function equally_spaced_schedule(n_chains::Int) 
    @assert n_chains ≥ 2
    grids = 0.0:(1.0/(n_chains-1)):1.0
    @assert length(grids) == n_chains
    return Schedule(grids)
end

"""
$TYPEDSIGNATURES
Create a [`Schedule`](@ref) with `n_chains` grid points computed using Algorithm 2 in 
Syed et al, 2021. 
"""
adapted_schedule(n_chains::Int, cumulativebarrier) = Schedule(updateschedule(cumulativebarrier, n_chains - 1))
