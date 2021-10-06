## Filter VCF for non-sibling MIKK lines (N = 63)
rule keep_no_sibs:
    input:
        vcf = config["mikk_vcf"],
        samples_cram = config["samples_cram"]
    output:
        os.path.join(config["working_dir"], "vcfs/mikk_no-sibs_cram-id.vcf.gz")
    log:
        os.path.join(config["working_dir"], "logs/keep_no_sibs.log")
    container:
        config["bcftools"]
    shell:
        """
        bcftools view \
            --output-file {output[0]} \
            --samples-file {input.samples_cram} \
            {input.vcf} \
                2> {log}
        """

## Replace CRAM IDs with MIKK line IDs
rule rehead:
    input:
        vcf = os.path.join(config["working_dir"], "vcfs/mikk_no-sibs_cram-id.vcf.gz"),
        samples = config["samples"]
    output:
        os.path.join(config["working_dir"], "vcfs/mikk_no-sibs_line-id.vcf")
    log:
        os.path.join(config["working_dir"], "logs/rehead.log")
    container:
        config["bcftools"]
    shell:
        """
        bcftools reheader \
            --output {output[0]} \
            --samples {input.samples} \
            {input.vcf} \
                2> {log}
        """

## Compress
rule compress:
    input:
        os.path.join(config["working_dir"], "vcfs/mikk_no-sibs_line-id.vcf")
    output:
        os.path.join(config["working_dir"], "vcfs/mikk_no-sibs_line-id.vcf.gz")
    log:
        os.path.join(config["working_dir"], "logs/compress.log")
    container:
        config["bcftools"]
    shell:
        """
        bcftools view \
            --output-type z \
            --output-file {output[0]} \
            {input[0]} \
                2> {log}
        """

## Index
rule index:
    input:
        os.path.join(config["working_dir"], "vcfs/mikk_no-sibs_line-id.vcf.gz")
    output:
        os.path.join(config["working_dir"], "vcfs/mikk_no-sibs_line-id.vcf.gz.tbi")
    log:
        os.path.join(config["working_dir"], "logs/index.log")
    container:
        config["bcftools"]
    shell:
        """
        bcftools index \
            --tbi \
            {input[0]} \
                2> {log}
        """

## Caculate nucleotide divergence
rule nucleotide_divergence:
    input:
        vcf = os.path.join(config["working_dir"], "vcfs/mikk_no-sibs_line-id.vcf.gz"),
        index = os.path.join(config["working_dir"], "vcfs/mikk_no-sibs_line-id.vcf.gz.tbi")
    output:
        os.path.join(config["lts_dir"], "nucleotide_divergence/mikk/all/{window_size}.windowed.pi")
    log:
        os.path.join(config["working_dir"], "logs/nucleotide_divergence/{window_size}.log")
    params:
        window_size = lambda wildcards: wildcards.window_size,
        prefix = lambda wildcards: os.path.join(config["lts_dir"], "nucleotide_divergence", wildcards.window_size)
    container:
        config["vcftools"]
    shell:
        """
        vcftools \
            --gzvcf {input.vcf} \
            --window-pi {params.window_size} \
            --out {params.prefix} \
                2> {log}
        """

# Pull mapping quality
rule mapping_quality:
    input:
        vcf = os.path.join(config["working_dir"], "vcfs/mikk_no-sibs_line-id.vcf.gz"),
        index = os.path.join(config["working_dir"], "vcfs/mikk_no-sibs_line-id.vcf.gz.tbi")
    output:
        os.path.join(config["lts_dir"], "mapping_quality/mapping_quality.csv")
    log:
        os.path.join(config["working_dir"], "logs/mapping_quality.log")
    container:
        config["bcftools"]
    shell:
        """
        bcftools query \
            --format '%CHROM,%POS,%INFO/MQ\\n' \
            --output {output[0]} \
            {input.vcf} \
                2> {log}
        """

# Split VCF per-sample and exclude sites with MQ < 50
rule split_and_filter:
    input:
        vcf = os.path.join(config["working_dir"], "vcfs/mikk_no-sibs_line-id.vcf.gz"),
        index = os.path.join(config["working_dir"], "vcfs/mikk_no-sibs_line-id.vcf.gz.tbi")
    output:
        expand(os.path.join(config["working_dir"], "vcfs/per_sample/mikk/{mikk_sample}.vcf.gz"),
                mikk_sample = MIKK_SAMPLES
        )
    log:
        os.path.join(config["working_dir"], "logs/split_and_filter.log")
    params:
        out_dir = lambda wildcards: os.path.join(config["working_dir"], "vcfs/per_sample/mikk")
    container:
        config["bcftools"]
    shell:
        """
        bcftools +split \
            {input.vcf} \
            --exclude 'INFO/MQ < 50' \
            --output {params.out_dir} \
            --output-type z \
                2> {log}
        """

rule nd_per_sample_mikk:
    input:
        vcf = os.path.join(config["working_dir"], "vcfs/per_sample/mikk/{mikk_sample}.vcf.gz"),
    output:
        os.path.join(config["lts_dir"], "nucleotide_divergence/mikk/per_sample/{mikk_sample}.windowed.pi")
    log:
        os.path.join(config["working_dir"], "logs/nd_per_sample_mikk/{mikk_sample}.log")
    params:
        window_size = 500000,
        prefix = lambda wildcards, output: os.path.join(os.path.dirname(output[0]), wildcards.mikk_sample)
    container:
        config["vcftools"]
    shell:
        """
        vcftools \
            --gzvcf {input.vcf} \
            --window-pi {params.window_size} \
            --out {params.prefix} \
                2> {log}
        """

## ##INFO=<ID=QD,Number=1,Type=Float,Description="Variant Confidence/Quality by Depth">