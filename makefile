### Diretories
INPUTS := inputs
OUTPUTS := outputs
SCRIPTS := scripts
LOGS := logs
PLOTS_DIR := r_plots
# Files extencions
CIF_EXT := cif
PDB_EXT := pdb
OUT_EXT := tsv
ID_FILES := id
### FIles
PDB_IDS_FILE := rcsb_pdb_ids_20240603055320.txt
IDS := $(shell cat ${PDB_IDS_FILE} | tr ',' '\n')
DATA_PDB := $(addprefix ${INPUTS}/,$(addsuffix .${PDB_EXT},$(IDS)))
DATA_FILES := $(DATA_PDB)
OUT_PDB = $(patsubst ${INPUTS}/%.${PDB_EXT}, ${OUTPUTS}/%.${PDB_EXT}.${OUT_EXT}, ${DATA_PDB})
OUT_FILES := $(OUT_CIF) $(OUT_PDB)
FIRST_FILE := $(word 1, ${OUT_FILES})
TTSV_FILE := merged_output.${OUT_EXT}
PLOTS = ${PLOTS_DIR}/gamma_histogram.png ${PLOTS_DIR}/chi_histogram.png ${PLOTS_DIR}/ramachandran_plot.png
# Scripts
DOWNLOAD_PDB =  ${SCRIPTS}/downloadPDB
CALCULATE_DEHIDRAL =  ${SCRIPTS}/pdbx-NA-torison-GX
GENERATE_PLOTS = ${SCRIPTS}/generate_plots.R
# Links
DOWNLOAD_LINK = http://www.rcsb.org/pdb/files

.PRECIOUS: inputs/%.pdb inputs/%.cif
.PHONY: all clean distclean

all: ${TTSV_FILE} ${PLOTS}
	
${PLOTS}: ${TTSV_FILE}
	Rscript ${GENERATE_PLOTS} ${TTSV_FILE} ${PLOTS_DIR}
	
${INPUTS}/%.${PDB_EXT}:
	./${DOWNLOAD_PDB} ${INPUTS} ${DOWNLOAD_LINK} $*.${PDB_EXT} ${LOGS}

	
${OUTPUTS}/%.${PDB_EXT}.${OUT_EXT}: ${INPUTS}/%.${PDB_EXT}
	./${CALCULATE_DEHIDRAL} $< > $@

${TTSV_FILE}: ${OUT_FILES}
	@echo '#$$Id: makefile 33 2024-06-03 20:26:57Z wolchear $ ' >$@;
	@cat ${FIRST_FILE} | head -n 1 >>$@;
	@echo "keyword\tangle1\tangle2\tDATAID\tchain\tresname\tresnum\tfile" >> $@;
	@for file in ${OUT_FILES}; do\
		 cat $$file | tail -n +3 >> $@; \
	done
	@echo "Merget file is done";
clean:
	rm -f ${INPUTS}/*.${PDB_EXT};

distclean: clean
	rm -f ${OUTPUTS}/*.${OUT_EXT};
	rm -f ${TTSV_FILE};
	rm -f ${PLOTS_DIR}/*.png;
	
