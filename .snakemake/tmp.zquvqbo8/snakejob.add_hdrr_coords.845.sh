#!/bin/sh
# properties = {"type": "single", "rule": "add_hdrr_coords", "local": false, "input": ["../introgression/release-102/segmented/5_1/5_14991435_15147508_1.data.txt"], "output": ["../introgression/release-102/cleaned/5_1/5_14991435_15147508_1.txt"], "wildcards": {"chr": "5", "subchr": "1", "segment": "5_14991435_15147508", "strand": "1"}, "params": {"command": "Rscript --no-save --no-restore --no-environ --no-site-file code/scripts/introgression/20200908_add-hdrr-coords-to-emf-data.R $input $output"}, "log": [], "threads": 1, "resources": {}, "jobid": 845, "cluster": {"memory": "10000", "n": "1", "name": "add_hdrr_coords.chr=5,segment=5_14991435_15147508,strand=1,subchr=1", "output": "../log/add_hdrr_coords_chr=5,segment=5_14991435_15147508,strand=1,subchr=1.out", "error": "../log/add_hdrr_coords_chr=5,segment=5_14991435_15147508,strand=1,subchr=1.err"}}
 cd /hps/research1/birney/users/ian/mikk_paper/mikk_genome && \
PATH='/nfs/research1/birney/users/brettell/anaconda3/envs/snakemake/bin':$PATH /nfs/research1/birney/users/brettell/anaconda3/envs/snakemake/bin/python3.9 \
-m snakemake ../introgression/release-102/cleaned/5_1/5_14991435_15147508_1.txt --snakefile /hps/research1/birney/users/ian/mikk_paper/mikk_genome/code/snakemake/introgression/Snakefile \
--force -j --keep-target-files --keep-remote --max-inventory-time 0 \
--wait-for-files /hps/research1/birney/users/ian/mikk_paper/mikk_genome/.snakemake/tmp.zquvqbo8 ../introgression/release-102/segmented/5_1/5_14991435_15147508_1.data.txt --latency-wait 100 \
 --attempt 1 --force-use-threads --scheduler ilp \
--wrapper-prefix https://github.com/snakemake/snakemake-wrappers/raw/ \
  -p --allowed-rules add_hdrr_coords --nocolor --notemp --no-hooks --nolock \
--mode 2  --use-conda  --use-singularity  && touch /hps/research1/birney/users/ian/mikk_paper/mikk_genome/.snakemake/tmp.zquvqbo8/845.jobfinished || (touch /hps/research1/birney/users/ian/mikk_paper/mikk_genome/.snakemake/tmp.zquvqbo8/845.jobfailed; exit 1)

