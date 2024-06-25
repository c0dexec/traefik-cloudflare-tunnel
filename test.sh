#!/bin/bash

fruit=("apple", "banana", "mango")
IFS=", "

for x in "${fruit[@]}"
do
    echo $x
done