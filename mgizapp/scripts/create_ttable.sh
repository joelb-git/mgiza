#!/bin/bash
#
# Copied and modified from
#   https://github.com/lilt/alignment-scripts/blob/master/scripts/giza.sh

set -ex

SCRIPT_DIR=$(realpath ${0%/create_ttable.sh})

MGIZA_DIR=$(realpath ${SCRIPT_DIR}/../..)
if [ ! -f ${MGIZA_DIR}/mgizapp/bin/mgiza ]; then
  echo "Install mgiza, file ${MGIZA_DIR}/mgizapp/bin/mgiza not found"
  exit 1
fi

# check parameter count and write usage instruction
if (( $# != 3 )); then
  echo "Usage: $0 source_file_path target_file_path outdir"
  exit 1
fi

source_path=`realpath $1`
target_path=`realpath $2`
source_name=${1##*/}
target_name=${2##*/}
outdir=$(realpath $3)

mkdir -p ${outdir}
lower=${SCRIPT_DIR}/lowercase.perl
$lower <${source_path} >${outdir}/${source_name}
$lower <${target_path} >${outdir}/${target_name}

source_path=$(realpath ${outdir}/${source_name})
target_path=$(realpath ${outdir}/${target_name})

cd ${outdir}

# creates vcb and snt files
${MGIZA_DIR}/mgizapp/bin/plain2snt ${source_path} ${target_path}

mkcls_iters=10
${MGIZA_DIR}/mgizapp/bin/mkcls -n${mkcls_iters} -p${source_path} -V${source_name}.class &
${MGIZA_DIR}/mgizapp/bin/mkcls -n${mkcls_iters} -p${target_path} -V${target_name}.class &
wait

${MGIZA_DIR}/mgizapp/bin/snt2cooc ${source_name}_${target_name}.cooc ${source_path}.vcb ${target_path}.vcb ${source_path}_${target_name}.snt &
${MGIZA_DIR}/mgizapp/bin/snt2cooc ${target_name}_${source_name}.cooc ${target_path}.vcb ${target_path}.vcb ${target_path}_${source_name}.snt &
wait


mkdir -p Forward && cd $_
echo "corpusfile ${source_path}_${target_name}.snt" > config.txt
echo "sourcevocabularyfile ${source_path}.vcb" >> config.txt
echo "targetvocabularyfile ${target_path}.vcb" >> config.txt
echo "coocurrencefile ../${source_name}_${target_name}.cooc" >> config.txt
echo "sourcevocabularyclasses ../${source_name}.class" >> config.txt
echo "targetvocabularyclasses ../${target_name}.class" >> config.txt
echo "dumpcount 1" >> config.txt
echo "dumpcountusingwordstring 1" >> config.txt

cd ..

mkdir -p Backward && cd $_
echo "corpusfile ${target_path}_${source_name}.snt" > config.txt
echo "sourcevocabularyfile ${target_path}.vcb" >> config.txt
echo "targetvocabularyfile ${source_path}.vcb" >> config.txt
echo "coocurrencefile ../${target_name}_${source_name}.cooc" >> config.txt
echo "sourcevocabularyclasses ../${target_name}.class" >> config.txt
echo "targetvocabularyclasses ../${source_name}.class" >> config.txt
echo "dumpcount 1" >> config.txt
echo "dumpcountusingwordstring 1" >> config.txt

cd ..

for name in "Forward" "Backward"; do
    cd $name
    ${MGIZA_DIR}/mgizapp/bin/mgiza config.txt 2>&1 | tee mgiza.log
    cat *A3.final.part* > allA3.txt
    # TODO: counts below - can we configure to get a real prefix to
    # avoid treating as hidden files?
    if [ "$name" == "Forward" ]; then
	${SCRIPT_DIR}/convert_ttable.py . >e_f.ttable
	cp .t.count e_f.counts
    else
	${SCRIPT_DIR}/convert_ttable.py . >f_e.ttable
	cp .t.count f_e.counts
    fi
    cd ..
done

# convert alignments
${SCRIPT_DIR}/a3ToTalp.py < ${outdir}/Forward/allA3.txt > ${outdir}/Forward/talp
${SCRIPT_DIR}/a3ToTalp.py < ${outdir}/Backward/allA3.txt > ${outdir}/Backward/talp
