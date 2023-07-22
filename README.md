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
To run the package you need to first open the project: visitGbsSrom.Rproj , then open plpTest.R , which contains the updated use of PLP.

To install the requiered packages use:
```
install.packages("renv")
renv::activate()
renv::restore()
```

The tagert cohort was defined using the configurations in Target.json file, and the outcome cohort was created using the Outcome.json.

We extracted the json of the PLP package for use with Strategus in the future.

