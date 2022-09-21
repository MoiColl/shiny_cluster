library(shiny)
args = commandArgs(trailingOnly=TRUE)
p = as.numeric(args[1])
runApp("/faststorage/project/GenerationInterval/people/moi/app", launch.browser = F, port = p, host = getOption("shiny.host", "0.0.0.0"))