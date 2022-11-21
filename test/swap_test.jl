using Pigeons
using OnlineStats
using SplittableRandoms
using MPI
using ArgMacros

@structarguments false Args begin
    @argumentdefault Int 37 N "--N"
    @argumentdefault Int 1000 iters "--iters"
    @argumentflag single "-s" # no MPI
end

"""
For testing purpose, a simple swap model where all swaps have equal acceptance probability. 
"""
struct TestSwapper 
    constant_swap_accept_pr::Float64
end
Pigeons.swapstat(swapper::TestSwapper, replica::Replica, partner_chain::Int)::Float64 = rand(replica.rng)
function Pigeons.swap_decision(swapper::TestSwapper, chain1::Int, stat1::Float64, chain2::Int, stat2::Float64)::Bool 
    uniform = chain1 < chain2 ? stat1 : stat2
    return uniform < swapper.constant_swap_accept_pr
end

function test_swap(n_chains::Int, n_iters::Int, useMPI::Bool)
    swapper = TestSwapper(0.4)
    rng = SplittableRandom(1)
    replicas = Replicas(n_chains, ConstantInitializer(nothing), rng, useMPI)

    timing_stats = Series(Mean(), Variance())

    for iteration in 1:n_iters
        t = @elapsed swap_round!(swapper, replicas, deo(n_chains, iteration))
    
        if iteration > n_iters / 2
            fit!(timing_stats, t)
        end
    end

    if load(replicas).my_process_index == 1
        m, v = timing_stats.stats
        mean = value(m) * 10e6
        sd = sqrt(value(v)) * 10e6
        println("Timing summary: $mean μs ($sd)")
    end

    return replicas
end

function test_swap(args::Args)
    n_chains = args.N
    n_iterations = args.iters

    # run serial
    serial_replicas = test_swap(n_chains, n_iterations, false)

    # run parallel
    parallel_replicas = test_swap(n_chains, n_iterations, !args.single)
    parallel_chains = chain.(parallel_replicas.locals)

    my_globals = my_global_indices(parallel_replicas.chain_to_replica_global_indices.entangler.load)
    serial_chains = chain.(serial_replicas.locals[my_globals])

    @assert parallel_chains == serial_chains
end

test_swap(Args())