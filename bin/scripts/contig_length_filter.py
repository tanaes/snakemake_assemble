#!/usr/bin/env python
import sys
from Bio import SeqIO
from Bio.SeqRecord import SeqRecord

if len(sys.argv) < 4: 
    print("Usage: %s <length threshold> <contigs_file> <output> [suffix]" % sys.argv[0])
    print("Will filter records shorter than <length threshold> and optionally add [suffix] to the names")
    sys.exit(1) 

f_n = sys.argv[2]
suffix = ""
if len(sys.argv) >= 5:
    suffix = "_" + sys.argv[4]

input_seq_iterator = SeqIO.parse(open(f_n, "r"), "fasta")

output_handle = open(sys.argv[3], "w")
#(record.name + suffix).replace(".", "_")
SeqIO.write((SeqRecord(record.seq, record.name + suffix, "","") for record in input_seq_iterator \
                if len(record.seq) >= int(sys.argv[1])), output_handle, "fasta")
output_handle.close()
