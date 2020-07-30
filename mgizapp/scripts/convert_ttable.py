#! /usr/bin/env python
#
# Convert x.t3.final file into ttable with actual words instead of
# vocab indices.

import argparse
import glob
import os


def read_vocab(path):
    index_to_word = {}
    with open(path, encoding='utf8') as f:
        for line in f:
            index, word, _ = line.rstrip().split(' ')
            index = int(index)
            index_to_word[index] = word
    return index_to_word


def find_unique_path(glob_pat):
    paths = glob.glob(glob_pat)
    if len(paths) != 1:
        raise RuntimeError(f'{glob_pat} file missing or ambiguous')
    return paths[0]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('ttable_dir')
    args = parser.parse_args()

    outdir = args.ttable_dir
    t3_path = find_unique_path(f'{args.ttable_dir}/*.t3.final')
    ttable_name = os.path.basename(t3_path).replace('.t3.final', '')

    # the src/trg conventions here are very confusing, but i believe
    # this is correct regardless of the confusing names
    tgt_vocab = read_vocab(find_unique_path(f'{outdir}/*trn.src.vcb'))
    src_vocab = read_vocab(find_unique_path(f'{outdir}/*trn.trg.vcb'))

    with open(t3_path) as f:
        for line in f:
            line = line.rstrip()
            tgt_index, src_index, prob = line.split(' ')
            tgt_index = int(tgt_index)
            src_index = int(src_index)
            if tgt_index == 0:
                continue
            src_word = src_vocab[src_index]
            tgt_word = tgt_vocab[tgt_index]
            prob = float(prob)
            print(src_word, tgt_word, prob, sep=' ')


if __name__ == '__main__':
    main()
