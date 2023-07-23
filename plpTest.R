library(visitGbsSrom)
outputFolder <- "<absolute_path_of_directory>/outputs"
outputPath <- "<absolute_path_of_directory>/outputs/multiple_plp"

# Details for connecting to the server:
dbms <- "postgresql"
user <- '<user_name>'
pw <- '<password>'
server <- '<server_address>/Hadassah'
jdbcDriverPath <- "<absolute_path_of_directory>/jdbcDrivers"
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                pathToDriver = jdbcDriverPath)


# Add the database containing the OMOP CDM data
cdmDatabaseSchema <- 'omop_demo'
# Add a sharebale name for the database containing the OMOP CDM data
cdmDatabaseName <- 'Hadassah'
# Add a database with read/write access as this is where the cohorts will be generated
cohortDatabaseSchema <- 'omop_demo'
tempEmulationSchema <- NULL

# table name where the cohorts will be generated
cohortTable <- 'new_cohort_PlpSromGbs_visit_v2'
targetId <- 29
outcomeIds <- 19
cdmVersion <- 5
sampleSize <- 100000
testFraction <- 0.3
trainFraction <- 0.7
seed <- 42
nfold <- 10

databaseDetails <- PatientLevelPrediction::createDatabaseDetails(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cdmDatabaseName = cdmDatabaseName,
  cdmDatabaseId = 'omop_demo_v2',
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTable = cohortTable,
  tempEmulationSchema=tempEmulationSchema,
  outcomeDatabaseSchema = cohortDatabaseSchema,
  outcomeTable = cohortTable,
  targetId=targetId,
  outcomeIds = outcomeIds,
  cdmVersion=cdmVersion
)

visitGbsSrom::execute(
  databaseDetails = databaseDetails,
  outputFolder = outputFolder,
  createCohorts = T
)


model_Xgboost <- PatientLevelPrediction::createModelDesign(
  targetId = targetId,
  outcomeId = outcomeIds,
  covariateSettings = FeatureExtraction::createCovariateSettings( useDemographicsAgeGroup = T,
                                                                  useDemographicsPriorObservationTime = T,
                                                                  useConditionOccurrenceAnyTimePrior = T,
                                                                  useConditionOccurrencePrimaryInpatientAnyTimePrior = T,
                                                                  useConditionEraAnyTimePrior = T,
                                                                  useDeviceExposureShortTerm = T,
                                                                  useMeasurementValueAnyTimePrior = T,
                                                                  useObservationAnyTimePrior = T,
                                                                  useDistinctConditionCountShortTerm = T,
                                                                  useVisitConceptCountShortTerm = T,
                                                                  useDemographicsGender = T,
                                                                  useConditionGroupEraAnyTimePrior = T,
                                                                  useDemographicsAge = T,
                                                                  useDemographicsEthnicity = T,
                                                                  useDrugEraAnyTimePrior = T,
                                                                  useDemographicsRace = T,
                                                                  useMeasurementAnyTimePrior = T,
                                                                  useDrugGroupEraAnyTimePrior = T,
  ),
  restrictPlpDataSettings = PatientLevelPrediction::createRestrictPlpDataSettings(
    sampleSize = sampleSize
  ),
  splitSettings = PatientLevelPrediction::createDefaultSplitSetting(nfold=nfold,  testFraction = testFraction, trainFraction = trainFraction),
  populationSettings = PatientLevelPrediction::createStudyPopulationSettings(),
  featureEngineeringSettings = PatientLevelPrediction::createFeatureEngineeringSettings(),
  preprocessSettings = PatientLevelPrediction::createPreprocessSettings(),
  sampleSettings =  PatientLevelPrediction::createSampleSettings(),
  modelSettings = PatientLevelPrediction::setGradientBoostingMachine(seed=seed,
                                                                     lambda=1,
                                                                     alpha=0,
                                                                     learnRate =0.05,
                                                                     maxDepth = 4),
  runCovariateSummary = T
)


model_KNN <- PatientLevelPrediction::createModelDesign(
  targetId = targetId,
  outcomeId = outcomeIds,
  covariateSettings = FeatureExtraction::createDefaultCovariateSettings(),
  restrictPlpDataSettings = PatientLevelPrediction::createRestrictPlpDataSettings(
    sampleSize = sampleSize
  ),
  splitSettings = PatientLevelPrediction::createDefaultSplitSetting(nfold=nfold, testFraction = testFraction, trainFraction = trainFraction),
  populationSettings = PatientLevelPrediction::createStudyPopulationSettings(),
  featureEngineeringSettings = PatientLevelPrediction::createFeatureEngineeringSettings(),
  preprocessSettings = PatientLevelPrediction::createPreprocessSettings(),
  sampleSettings =  PatientLevelPrediction::createSampleSettings(),
  modelSettings = PatientLevelPrediction::setKNN()
)


model_LassoLogisticRegression <- PatientLevelPrediction::createModelDesign(
  targetId = targetId,
  outcomeId = outcomeIds,
  covariateSettings = FeatureExtraction::createDefaultCovariateSettings(),
  restrictPlpDataSettings = PatientLevelPrediction::createRestrictPlpDataSettings(
    sampleSize = sampleSize
  ),
  splitSettings = PatientLevelPrediction::createDefaultSplitSetting(nfold=nfold, testFraction = testFraction, trainFraction = trainFraction),
  populationSettings = PatientLevelPrediction::createStudyPopulationSettings(),
  featureEngineeringSettings = PatientLevelPrediction::createFeatureEngineeringSettings(),
  preprocessSettings = PatientLevelPrediction::createPreprocessSettings(),
  sampleSettings =  PatientLevelPrediction::createSampleSettings(),
  modelSettings = PatientLevelPrediction::setLassoLogisticRegression(seed = seed),
  runCovariateSummary = T
)


modelDesignList <- list(
  model_Xgboost
  )

plpResult <- PatientLevelPrediction::runMultiplePlp(
  databaseDetails = databaseDetails,
  modelDesignList = modelDesignList,
  saveDirectory = outputPath
)

PatientLevelPrediction::viewMultiplePlp(outputPath)



# --------------- PFI Start------------------ #
restrictPlpDataSettings <- PatientLevelPrediction::createRestrictPlpDataSettings(sampleSize = sampleSize)
covariateSettings <- FeatureExtraction::createDefaultCovariateSettings()

populationSettings <- PatientLevelPrediction::createStudyPopulationSettings()

plpData <- PatientLevelPrediction::getPlpData(databaseDetails = databaseDetails,
                                              covariateSettings =covariateSettings,
                                              restrictPlpDataSettings = restrictPlpDataSettings)
population <- PatientLevelPrediction::createStudyPopulation(
  plpData=plpData,
  outcomeId=outcomeIds,
  populationSettings=populationSettings,
  population = NULL
)
plpResult_1 <- PatientLevelPrediction::runPlp(
  plpData = plpData,
  outcomeId = outcomeIds,
  analysisId = 'bdikaPFI',
  analysisName = 'testing PFI',
  splitSettings = PatientLevelPrediction::createDefaultSplitSetting(nfold=nfold, testFraction = testFraction, trainFraction = trainFraction),
  populationSettings = PatientLevelPrediction::createStudyPopulationSettings(),
  featureEngineeringSettings = PatientLevelPrediction::createFeatureEngineeringSettings(),
  preprocessSettings = PatientLevelPrediction::createPreprocessSettings(),
  sampleSettings =  PatientLevelPrediction::createSampleSettings(),
  modelSettings = PatientLevelPrediction::setLassoLogisticRegression(seed = seed),
  logSettings = PatientLevelPrediction::createLogSettings(),
  executeSettings = PatientLevelPrediction::createExecuteSettings(
    runSplitData = T,
    runSampleData = T,
    runfeatureEngineering = T,
    runPreprocessData = T,
    runModelDevelopment = T,
    runCovariateSummary = T
  )
)
covariateData <-FeatureExtraction::getDbCovariateData(connectionDetails = connectionDetails,
                                                      cdmDatabaseSchema = cdmDatabaseSchema,
                                                      cohortDatabaseSchema = cohortDatabaseSchema,
                                                      cohortTable = 'new_cohort_PlpSromGbs_visit_v2',
                                                      cohortId = 29,
                                                      rowIdField = "subject_id",
                                                      covariateSettings = covariateSettings)

pfiResults <- PatientLevelPrediction::pfi(plpResult=plpResult_1,
                                          plpData = plpData,
                                          population = population,
                                          repeats=400)

covariate_information <- covariateData$covariateRef %>%
  filter(covariateId %in% !!pfiResults$covariateId, )%>%
  collect()

merged_results<-merge(pfiResults, covariate_information, by = "covariateId")

#--------------- PFI End------------------#
