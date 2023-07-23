The Effect of GBS on Infection After Spontaneous Rupture of Membranes
=============


- Analytics use case(s): Patient-Level Prediction
- Study type: Clinical Application
- Tags: GBS, SROM
- Study lead: Dr. Nadav Rappoport 
- Study start date: October 1st, 2022
- Study end date: July 5th, 2023

Description
----------------

In this study we used Atlas (Version 2.12.0) to extract the cohort. Afterwards we used Patient Level Prediction to extract a package for our study.
We used Jennas code to create a working PLP model.

How To Run?
--------------
To use the visitGbsSrom package in R and connect to a server with specific details, follow these instructions:
1. Install visitGbsSrom, please follow the instructions at the following [link](https://www.r-bloggers.com/2022/09/the-package-learning-how-to-build-an-r-package/) on how to build local package: 
```
# Load the package
library(visitGbsSrom)
```
2. Open `visitGbsSrom.Rproj` file, once R project is loaded, open `plpTest.R` file.\
At `plpTest.R` fill your absolute path and connections details folder and output path:
```
# Replace "<absolute_path_of_directory>" with the absolute path to your desired output folder
# Replace the placeholders '<user_name>', '<password>', and '<server_address>' with your actual credentials and server information

outputFolder <- "<absolute_path_of_directory>/outputs"
outputPath <- file.path(outputFolder, "multiple_plp")
dbms <- "postgresql"
user <- '<user_name>'
pw <- '<password>'
server <- '<server_address>/Hadassah'
jdbcDriverPath <- "<absolute_path_of_directory>/jdbcDrivers"
```
3. Please make sure to install the required packages use:
```
install.packages("renv")
renv::activate()
renv::restore()
```

The cohort target was defined using the configurations in Target.json file, and the outcome cohort was created using the Outcome.json.

We extracted the json of the PLP package for use with `Strategus` in the future.

## Troubleshoot:
1. If you encounter an error in R stating that a package is not installed, you can take the following steps to resolve the issue\
Install the Missing Package: The first step is to install the package that R is complaining about. 
You can use the `install.packages(<"package_name">)` function to install the package from CRAN. 

2. Issues with install packages hosted on GitHub \
Refer to the instructions on how to insatll package from git - [link](https://cran.r-project.org/web/packages/githubinstall/vignettes/githubinstall.html

