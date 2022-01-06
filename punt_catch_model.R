library(randomForest)

#catch probability - based on location of returner and location of punt/hang time - what is the probabiliyt the returner catches the punt
catch_df<-filter(punts,specialTeamsResult=='Return'|specialTeamsResult=='Fair Catch'|specialTeamsResult=='Downed'|
                   specialTeamsResult=='Muffed'|specialTeamsResult=='Touchback')

#create data frame for is_catch as target variable
catch_df$is_catch<-ifelse(catch_df$specialTeamsResult=='Return'|catch_df$specialTeamsResult=='Fair Catch',1,0) #maybe improved upon by using PFF data

is_catch_df<-catch_df %>% select(kickContactType,is_catch,gameId,playId,hangTime,snapDetail,snapTime,operationTime,kickLength,absoluteYardlineNumber,
                                 kickType,kickDirectionIntended,kickDirectionActual)
is_catch_df<-unique(is_catch_df) #additional factors that could be added to enhance: punter location, returner location
#returner distance from punt landing spot, returner speed/direction at given frame,weather, score differential, etc...
#ideal visualization here is a bar chat with catch probability at each frame for a given punt

#building linear regression model with categorial variables - data set up
is_catch_df$bin_snap<-ifelse(is_catch_df$snapDetail == "OK",1,0)
is_catch_df$bin_normal_kick<-ifelse(is_catch_df$kickType == "N",1,0)
is_catch_df$bin_Rugby_kick<-ifelse(is_catch_df$kickType == "R",1,0)
is_catch_df$bin_NoseDown_kick<-ifelse(is_catch_df$kickType == "A",1,0)
is_catch_df$bin_kickdir_R<-ifelse(is_catch_df$kickDirectionActual == "R",1,0)
is_catch_df$bin_kickdir_L<-ifelse(is_catch_df$kickDirectionActual == "L",1,0)
is_catch_df$bin_kickdir_C<-ifelse(is_catch_df$kickDirectionActual == "C",1,0)
is_catch_df$intended_dir<-ifelse(is_catch_df$kickDirectionActual == is_catch_df$kickDirectionIntended,1,0)
#str(is_catch_df)

#linear model is no good, very poor R-squared
#is_catch_lm<-lm(is_catch ~ hangTime+bin_snap+snapTime+operationTime+kickLength+absoluteYardlineNumber+bin_normal_kick+bin_Rugby_kick+bin_NoseDown_kick+
#bin_kickdir_C+bin_kickdir_L+bin_kickdir_R+intended_dir, data = is_catch_df)

#clean data for RF
is_catch_df_RF<-na.omit(is_catch_df)
summary(is_catch_df_RF$kickContactType)
is_catch_df_RF<-droplevels(is_catch_df_RF)


######building optimal modle with correct criteria
library(caret)

####### model tuning not needed if already ran - if so skip to final model building below
# Define the control
trControl <- trainControl(method = "cv",
                          number = 10,
                          search = "grid")
# Run the model
set.seed(1234)
rf_default <- train(kickContactType ~ hangTime+bin_snap+snapTime+operationTime+kickLength+absoluteYardlineNumber+bin_normal_kick+bin_Rugby_kick+bin_NoseDown_kick+
                      bin_kickdir_C+bin_kickdir_L+bin_kickdir_R+intended_dir, data = is_catch_df_RF,
                    method = "rf",
                    metric = "Accuracy",
                    trControl = trControl)
print(rf_default)# Print the results


#find optimal mtry
tuneGrid <- expand.grid(.mtry = c(1: 10))
rf_mtry <- train(kickContactType ~ hangTime+bin_snap+snapTime+operationTime+kickLength+absoluteYardlineNumber+bin_normal_kick+bin_Rugby_kick+bin_NoseDown_kick+
                   bin_kickdir_C+bin_kickdir_L+bin_kickdir_R+intended_dir, data = is_catch_df_RF,
                 method = "rf",
                 metric = "Accuracy",
                 tuneGrid = tuneGrid,
                 trControl = trControl,
                 importance = TRUE,
                 nodesize = 14,
                 ntree = 300)
print(rf_mtry)# Print the results

#storing opitmal results
best_mtry<-rf_mtry$bestTune$mtry #store mtry
max(rf_mtry$results$Accuracy) #store top accuracy

#search maxnodes
store_maxnode <- list()
tuneGrid <- expand.grid(.mtry = best_mtry)
for (maxnodes in c(5: 15)) {
  set.seed(1234)
  rf_maxnode <- train(kickContactType ~ hangTime+bin_snap+snapTime+operationTime+kickLength+absoluteYardlineNumber+bin_normal_kick+bin_Rugby_kick+bin_NoseDown_kick+
                        bin_kickdir_C+bin_kickdir_L+bin_kickdir_R+intended_dir, data = is_catch_df_RF,
                      method = "rf",
                      metric = "Accuracy",
                      tuneGrid = tuneGrid,
                      trControl = trControl,
                      importance = TRUE,
                      nodesize = 14,
                      maxnodes = maxnodes,
                      ntree = 300)
  current_iteration <- toString(maxnodes)
  store_maxnode[[current_iteration]] <- rf_maxnode
}

results_mtry <- resamples(store_maxnode)
summary(results_mtry) #max nodes is 9

#find optimal max trees
store_maxtrees <- list()
for (ntree in c(250, 300, 350, 400, 450, 500, 550, 600, 800, 1000, 2000)) {
  set.seed(5678)
  rf_maxtrees <- train(kickContactType ~ hangTime+bin_snap+snapTime+operationTime+kickLength+absoluteYardlineNumber+bin_normal_kick+bin_Rugby_kick+bin_NoseDown_kick+
                         bin_kickdir_C+bin_kickdir_L+bin_kickdir_R+intended_dir, data = is_catch_df_RF,
                       method = "rf",
                       metric = "Accuracy",
                       tuneGrid = tuneGrid,
                       trControl = trControl,
                       importance = TRUE,
                       nodesize = 14,
                       maxnodes = 9,
                       ntree = ntree)
  key <- toString(ntree)
  store_maxtrees[[key]] <- rf_maxtrees
}

results_tree <- resamples(store_maxtrees)
summary(results_tree)



####### Build final model
is_catch_RF<-randomForest(kickContactType ~ hangTime+bin_snap+snapTime+operationTime+kickLength+absoluteYardlineNumber+bin_normal_kick+bin_Rugby_kick+bin_NoseDown_kick+
                            bin_kickdir_C+bin_kickdir_L+bin_kickdir_R+intended_dir, data = is_catch_df_RF,
                          method = "rf",
                          metric = "Accuracy",
                          tuneGrid = tuneGrid,
                          trControl = trControl,
                          importance = TRUE,
                          nodesize = 14, 
                          ntree = 400, #input actual value instead of placeholder
                          maxnodes = 9) #input actual value instead of placeholder

prediction <-predict(is_catch_RF, is_catch_df_RF, type = "prob")
df_pred_check<-cbind(is_catch_df_RF,prediction)

df_pred_check_caught<-filter(df_pred_check,is_catch == 1)
df_pred_check_not_caught<-filter(df_pred_check,is_catch == 0)

summary(df_pred_check_caught$CC)
summary(df_pred_check_not_caught$CC)

#I now know the probability that eveyr ball should be caught. Woooohooooo!
plot(importance(is_catch_RF))


