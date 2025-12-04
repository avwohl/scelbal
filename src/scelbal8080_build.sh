#!/bin/bash
# Build script for SCELBAL 8080

um80 scelbal8080.asm -l scelbal8080.prn
ul80 scelbal8080.rel -o scelbal8080.bin -s
