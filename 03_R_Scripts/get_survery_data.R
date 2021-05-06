# Make sure survey data is up-to date

library(googlesheets4)

answers <- read_sheet("https://docs.google.com/spreadsheets/d/1mV_wZWb4desjdzUWHALIB-uFRCauSTOGSvENsnkiAhI/edit#gid=1189808333")

old_names <- names(answers)

new_names <- c("time", "position", "usage_freq", "expertise", "major_topic",
               "important_tasks", "data_model", "r_packages", "own_package",
               "own_package_location", "missing_methods", "usefulness", "comments")

names(answers) <-  new_names

results <- list(answers = answers, old_names = old_names, new_names = new_names)

saveRDS(object = results, file = "01_Manuscript/data/results.rds")
