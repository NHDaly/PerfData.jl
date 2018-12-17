#module PerfData
#
#struct perf_file_section
#	offset :: UInt64            #  /* offset from start of file */
#	size :: UInt64              #  /* size of the section */
#end
#
#struct perf_header_string{LEN}
#    len :: UInt32
#    string :: NTuple{LEN,Char}  #  /* zero terminated */
#end
#
#struct perf_header
#	magic :: NTuple{8,Char}     #  /* PERFILE2 */
#	size :: UInt64              #  /* size of the header */
#	attr_size :: UInt64         #  /* size of an attribute in attrs */
#	attrs :: perf_file_section
#	data :: perf_file_section
#	event_types :: perf_file_section
#	flags :: UInt64
#	flags1 :: NTuple{3,UInt64}
#end
#
#struct perf_header_string_list{NR}
#     nr :: UInt32
#     strings :: NTuple{NR, perf_header_string}  # /* variable length records */
#end
#
#end
#
#
#


module PerfData

cd(@__DIR__)
using Clang.cindex
using Clang.wrap_c
using Printf

# Set these to correspond to your local filesystem's curl and clang include paths
const CLANG_INCLUDES = String[
    #"/usr/local/opt/llvm/include",
    # TODO: I _THINK_ this is failing because i'm not running on a linux, so the necessary
    # includes don't exist!! Figure out some way to run on a linux bot!
]

#const SRC_DIR = abspath(@__DIR__, "..", "src")
const OUT_DIR = abspath(@__DIR__, "..", "out")
mkpath(OUT_DIR)

headers = [abspath("../headers/linux-perf_event.h")]
context = wrap_c.init(;
    headers = headers,
    clang_args = String[],
    #common_file = joinpath(SRC_DIR, "lC_common_h.jl"),
    clang_includes = CLANG_INCLUDES,
    clang_diagnostics = true,
    header_wrapped = (top_header, cursor_header) -> in(cursor_header, headers),
    header_library = header -> "libcurl",
    #header_outputfile = header -> joinpath(SRC_DIR, "lC_") * replace(basename(header), "." => "_") * ".jl",
    header_outputfile = header -> joinpath(OUT_DIR, replace(basename(header), "." => "_") * ".jl"),
)
context.options.wrap_structs = true

function run_wrap()
    context.headers = headers
    #context.headers = [joinpath(CURL_PATH, "curl.h")]
    run(context)
end

run_wrap()

end
