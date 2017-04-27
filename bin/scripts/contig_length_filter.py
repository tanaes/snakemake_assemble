#!/usr/bin/env python
import sys
from Bio import SeqIO
from Bio.SeqRecord import SeqRecord

if len(sys.argv) < 5: 
    print("Usage: %s <length threshold> <contigs_file> <suffix> <output>" % sys.argv[0])
    sys.exit(1) 

f_n = sys.argv[2]
suffix = sys.argv[3]
input_seq_iterator = SeqIO.parse(open(f_n, "r"), "fasta")

output_handle = open(sys.argv[4], "w")
SeqIO.write((SeqRecord(record.seq, (record.name + "_" + suffix).replace(".", "_"), "","") for record in input_seq_iterator \
                if len(record.seq) > int(sys.argv[1])), output_handle, "fasta")
output_handle.close()
