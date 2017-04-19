#!/bin/bash

file="normal_dist"
g++ -std=c++11 -O3 $file.cpp -o $file.g++
clang++ -std=c++11 -O3 $file.cpp -o $file.clang++
