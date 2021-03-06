#!/bin/bash
# sample_call_filter 0.0.1
# Generated by dx-app-wizard.
#
# Basic execution pattern: Your app will run on a single machine from
# beginning to end.
#
# Your job's input variables (if any) will be loaded as environment
# variables before this script runs.  Any array inputs will be loaded
# as bash arrays.
#
# Any code outside of main() (or any entry point you may add) is
# ALWAYS executed, followed by running the entry point itself.
#
# See https://wiki.dnanexus.com/Developer-Portal for tutorials on how
# to modify this file.

main() {

    pip install plinkio
    pip install ldpred

    echo "Value of bed_file: '$bed_file'"
    echo "Value of bim_file: '$bim_file'"
    echo "Value of fam_file: '$fam_file'"
    echo "Value of summary_file: '$summary_file'"	
    echo "Value of coord_args: '$coord_args'"
    echo "Value of gibbs_args: '$gibbs_args'"
	PLINK_ARGS=""

    dx download "$bed_file" -o input.bed
    dx download "$bim_file" -o input.bim
    dx download "$fam_file" -o input.fam
    dx download "$summary_file" -o summary_file

    mkdir out
    echo "Running: ldpred coord --gf input --ssf summary_file  $coord_args --out LDPred_COORD"
    ldpred coord --gf input --ssf summary_file  $coord_args --out LDPred_COORD
    echo "ldpred gibbs --cf LDPred_COORD --ldf LDPred_COORD_ld_file.gz --out out/LDPred_COORD_Gibbs"
    ldpred gibbs --cf LDPred_COORD --ldf LDPred_COORD_ld_file.gz $gibbs_args --out out/LDPred_COORD_Gibbs

    ls out
    echo "Uploadig results"

    for f in out/*; do
        up_file=$(dx upload "$f" --brief)
        dx-jobutil-add-output ldpred_out --class="array:file" "$up_file"
    done
}
