#!/usr/bin/env nextflow

params.cutoff = 10

process filterExp{
	input:
	path expData
	val cutoff

	output:
	path "expression_filtered.txt"

	script:
	"""
	#!/usr/bin/env Rscript
	table <- read.table("$expData", header=T, as.is=T, row.names=1, sep="\\t")
	means <- rowMeans(table)
	table <- table[means>=$cutoff,]
	write.table(table,"expression_filtered.txt", sep="\\t")
	"""
}

process boxplot{
	input:
	path expData
	
	output:
	path "boxplot.pdf"

	script:
	"""
	#!/usr/bin/env Rscript
	table <- read.table("$expData", header=T, as.is=T, row.names=1, sep="\\t")
	pdf("boxplot.pdf")
	par(mar = c(10, 4, 2, 2))
	boxplot(table,las=2)
	dev.off() 
	"""
}

workflow {
	inputFile = Channel.fromPath(params.input)
	filteredData = filterExp(inputFile, params.cutoff)
	boxplot(filteredData)
}
