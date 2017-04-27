#!/usr/bin/env python
import sys
from Bio import SeqIO

if len(sys.argv) < 4: 
    print("Usage: %s <length threshold> <contigs_file> <output>" % sys.argv[0])
    sys.exit(1) 

f_n = sys.argv[2]
input_seq_iterator = SeqIO.parse(open(f_n, "r"), "fasta")
filtered_iterator = (record for record in input_seq_iterator \
                      if len(record.seq) > int(sys.argv[1]))
 
output_handle = open(sys.argv[3], "w")
SeqIO.write(filtered_iterator, output_handle, "fasta")
output_handle.close()
