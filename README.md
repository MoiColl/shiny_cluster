# Shiny Cluster

This is a bash script to run a R shiny app on a slurm cluster (GenomeDK) and connect to the node where it is running from your local computer and open it on the Chrome browser. 

In more detail, the script `shiny_cluster.sh` will submit to `slurm` a job `job.sh` on the cluster. The job submitted will run an R script `run_app.R` which will run the shiny app `app.R`. Then, `shiny_cluster` will check periodically if the job started running. Once it does, it creates a shh tunnel which connects to the node in which the job is running on the cluster. Finally, it opens the shiny app to the Chrome browser of your local machine.

This script might be interesting to you if you are:
  - running a shiny app which handles a lot of data stored in a cluster and downloading the data is tedious or not feasible
  - you need to run a shiny app that uses a lot of resources (memory) that your local computer doesn't have
  - mounting the cluster on your local computer makes the app run very slow when running it on your local machine Rstudio
  - sharing the app with other people collaborating with you

In order to run the script you need to have [access to the cluster with a public key authentication](https://genome.au.dk/docs/getting-started/#public-key-authentication), Chrome installed on your local machine and have an environment that has all what is needed to run shiny app on the cluster.

Let's start with the specifics of each file in this repository!

## 1. `job.sh`

This file contains the code to submit a job to slurm queue system with `sbatch` command. This file will be located on the cluster. It's location (path) will be indicated to `shiny_cluster.sh`. It is important that the following parameters are manually edited/modified by you before using the default file:

  1. **Standard output path**: Defined with `#SBATCH -o <PATH>` this will be where R will write the standard output of the shiny app. It is needed because `shiny_cluster` allows you to check the standard output while the app runs or if the job fails.
  2. **Standard error path**: Defined with `#SBATCH -e <PATH>` this will be where R will write the standard error of the shiny app. It is needed because `shiny_cluster` allows you to check the standard error if the job fails.
  3. **Job name**: Defined with `#SBATCH -J <NAME>` this is the name that will be given to the job and that the app uses to find the job on the slurm queue and also to cancel old jobs with the same name
  4. **`run_app.R` path**: you need to change the path to this file.
  
Other considerations you must have:
  1. The environment the script will run needs all the necessary packages intalled (`R`, `shiny`, `tidyverse`...). In my case, I use the `GenerationInterval` environment.
  2. I source my `~/.bashrc` file, but you might not be interested on doing it (or you might not even have this file). You can remove this command although I don't think it would bug the process to have it there.
  3. The port I run the shiny app on is specified at the end of the command `Rscript ...` as an argument for the R script `run_app.R`. In the default file it is `4444` but it might be problematic if multiple cluster users use the same port. Thus, be creative and change the port to the 4 digit number that you prefer :) .
  
## 2. `run_app.R`

This R script contains just the bare commands to run the shiny app, such as loading the library `shiny` and using `runApp(...)` to ... you guessed correctly... run the app. This script has to be in the cluster and the path will be indicated to `job.sh`. The only thing you need to change from this file is the path to your app in `runApp(...)`.

## 3. `shiny_cluster.sh`

This bash script will submit remotely from your local computer `job.sh` to the cluster queue system `slurm`. Then, once the job runs, the script will open a ssh tunnel to the node in which the shiny app runs and open it on your local computer's Chrome browser. 

In order to learn which parameters you can change, you can run `bash shiny_cluster.sh -h`. If you want to change the defaults permanently, I suggest you open the script with an editor and modify away the different variables (specially `s` (path to `job.sh` in the cluster) and `u` (your cluster username)).

The script has different steps that are reported on your terminal. Here I'm going to explain what `shiny_cluster` does in each step.

  1. Checking if the port is free to use

This step checks if the port defined by the user is already on use in your local machine. This might happen if there is another application that is using it (very unlikely) or if last time you run `shiny_cluster` you did not kill the port and is still active. If the port is not already active, the script will carry on to the next step. Otherwise, I will ask you if you want to kill the process that uses it. By typing "Y" and pressing enter (or just pressing enter) it will kill the process and the port will be free for the app to use. If not, the script will exit. In case you don't want to kill the process using the port, you will need to change port. This can be achieved specifying a new port with the command `bash shiny_cluster -l 1234`, for example.

  2. Checking if there is already a shiny app job

In case there is a (or many) job with the same job name running by you on the cluster (probably because you run `shiny_cluster` like 10 seconds ago) it will directly cancel the job.

  3. Submitting the job to the slurm queue
  
The script will carry on and submit the job to the cluster from your local computer. Then, it will wait until it runs or it gets cancelled. It will check periodically after 10 seconds (default, but can be modified with `bash shiny_cluster -w 20`, for example) and tell you with a count down the time until it checks again. Then, it will report back the status of the job. 

  - 3.1. Job gets cancelled
  
It will let you know that the job got cancelled and ask you if you want to check the standard error outputed by the job in order to know what happened.

  - 3.2. Job runs
  
The script will notify that the job runs and tell you the node in which it has been allocated.

  4. Open a shh tunnel to the cluster and open the browser
  
As the title says, it will open a shh tunnel to the cluster and open the shiny app on your Chrome browser. Because sometimes the ssh tunnel connection has some delay, I added a waiting time of 10 seconds (default but can be modified with `bash shiny_cluster -w 20`, for example). If you get an error message, try to refresh the opened browser tab. Finally, `shiny_cluster` will ask you if you want to see the standard output produced by the job on the terminal.


Hope it helps you as much as it has helped me! Let me know on the issues of the repo if you have any problems with the script or if you think `shiny_cluster` can be improved in any way!


# For collaborators using GenerationInterval shiny app

These are the instructions to be able to run the GenerationInterval shiny app from your local computer.

### A. ON CLUSTER

1. copy the file `job_moicoll.sh` 

```
cp /faststorage/project/GenerationInterval/people/moi/app_run/job_moicoll.sh /faststorage/project/GenerationInterval/people/moi/app_run/job_<USER>.sh
```

2. Modify the newly generated `job_<USER>.sh`
  - 2.1. the username "moicoll" to your user name in lines 4, 5 and 6
  - 2.2. change the conda environment name which has all the necessary r packages installed. These are `r`, `r-tidyverse`, `r-shiny`, `r-shinyWidgets`, `r-tidyverse`, `r-leaflet`, `r-viridis`, `r-dt`, `r-ggiraph`, `r-data.tree`, `r-shinytree`. It is possible that the list is not completed, but R should complain about laking a library.
  
  Alternatively, you can copy the environment I'm using with:
  
  ```
  conda env create -f /faststorage/project/GenerationInterval/people/moi/backup/environment_shiny_cluster.yml
  ```
  
  - 2.3. change the port "4444" by another 4-digit number
  
3. Download the `shiny_cluster.sh` file from this repo

4. Modify the variables at the beginnging of the `shiny_cluster.sh`
  - 4.1. the `u` variable for you GenomeDK user 
  - 4.2. the `c` and `l` variables for two 4-digit ports. `c` must be the same as the one used in step 2.3.
  - 4.3. the `s` path for the name of the job you used in step 1.
  
5. From the directory where `shiny_cluster.sh` is located run it with 

```
$ bash shiny_cluster.sh
```

You can provide `shiny_cluster.sh` with some inputs that can be checked with 


```
$ bash shiny_cluster.sh -h
```
