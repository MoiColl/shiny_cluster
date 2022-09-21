#!/bin/sh
#BATCH --mem-per-cpu 6g
#SBATCH -t 02:00:00
#SBATCH -o /faststorage/project/GenerationInterval/people/moi/app/shiny_cluster.out
#SBATCH -e /faststorage/project/GenerationInterval/people/moi/app/shiny_cluster.err
#SBATCH -J shiny_cluster
#SBATCH -A GenerationInterval

source ~/.bashrc
conda activate GenerationInterval
Rscript /faststorage/project/GenerationInterval/people/moi/scripts/run_app.R 4444
