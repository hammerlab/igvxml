## Generate IGV Session Files from the Command Line

Install the library and the binary with `opam install igvxml`.

To build from source:

```sh
make deps  # If you don't have them yet
           # sosa nonstd cmdliner xmlm
make       # Results in a ./igvxml binary.
```

You can use it like so:

```shell
igvxml --help

NAME
       igvxml - Create an IGV session file.

SYNOPSIS
       igvxml [OPTION]...

OPTIONS
       -G VAL, --genome=VAL
           Genome used. b37decoy or mm10.

       --help[=FMT] (default=pager)
           Show this help in format FMT (pager, plain or groff).

       -N VAL, --normal-bam=VAL
           Path to Normal BAM.

       -O VAL, --output=VAL
           XML session file to be written.

       -R VAL, --rna-bam=VAL
           Path to RNA BAM. (optional)

       --run-id=VAL
           Patient/Run ID.

       -T VAL, --tumor-bam=VAL
           Path to Tumor BAM.

       -V VAL, --vcfs=VAL
           List (comma-separated) of name=path VCFs.

       --version
           Show version information.

Description
       Create an IGV.xml session file from the specified arguments.
```

`igvxml` is built for somatic paired BAMs and multiple VCFs, with optional RNA
seq data. 

Contributions welcome for making this more general.
