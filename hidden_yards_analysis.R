#hidden yards evaluation starts here

final_df<-punts %>% select(game_play_ID) %>% unique()

#is_catch_RF<-randomForest(kickContactType ~ hangTime+bin_snap+snapTime+operationTime+kickLength+absoluteYardlineNumber+
#bin_normal_kick+bin_Rugby_kick+bin_NoseDown_kick+
#bin_kickdir_C+bin_kickdir_L+bin_kickdir_R+intended_dir
                           
final_df$hangTime<-punts$hangTime[match(final_df$game_play_ID,punts$game_play_ID)]

final_df$snap_detail<-punts$snapDetail[match(final_df$game_play_ID,punts$game_play_ID)]
final_df$bin_snap<-ifelse(final_df$snap_detail == "OK",1,0)

final_df$snapTime<-punts$snapTime[match(final_df$game_play_ID,punts$game_play_ID)]
final_df$operationTime<-punts$operationTime[match(final_df$game_play_ID,punts$game_play_ID)]
final_df$kickLength<-punts$kickLength[match(final_df$game_play_ID,punts$game_play_ID)]
final_df$absoluteYardlineNumber<-punts$absoluteYardlineNumber[match(final_df$game_play_ID,punts$game_play_ID)]

final_df$kick_normal<-punts$kickType[match(final_df$game_play_ID,punts$game_play_ID)]
final_df$bin_normal_kick<-ifelse(final_df$kick_normal == "N",1,0)
final_df$bin_Rugby_kick<-ifelse(final_df$kick_normal == "R",1,0)
final_df$bin_NoseDown_kick<-ifelse(final_df$kick_normal == "A",1,0)

final_df$kick_dir<-punts$kickDirectionActual[match(final_df$game_play_ID,punts$game_play_ID)]
final_df$int_kick_dir<-punts$kickDirectionIntended[match(final_df$game_play_ID,punts$game_play_ID)]
final_df$bin_kickdir_C<-ifelse(final_df$kick_normal == "C",1,0)
final_df$bin_kickdir_L<-ifelse(final_df$kick_normal == "L",1,0)
final_df$bin_kickdir_R<-ifelse(final_df$kick_normal == "R",1,0)
final_df$intended_dir<-ifelse(final_df$kick_dir == final_df$int_kick_dir,1,0)

prediction <-as.data.frame(predict(is_catch_RF, final_df, type = "prob"))

final_df_catchPred<-cbind(final_df,prediction$CC)

#df_punt_trajectory <- snap_land_downed %>% select(c(bounce_length,puntLOS,puntHash,catch_yard_line,catch_field_width,
                                                    #punt_speed,punt_acc,kickLength,snapTime,operationTime,hangTime,
                                                    #good_snap,kick_towards_sideline,rugby_kick,aussie_kick))
final_df_catchPred$playDirection<-punts$playDirection[match(final_df_catchPred$game_play_ID,punts$game_play_ID)]

final_df_catchPred$puntLOS<-punts_snap$x[match(final_df_catchPred$game_play_ID,punts_snap$game_play_ID)]
final_df_catchPred$puntHash<-punts_snap$y[match(final_df_catchPred$game_play_ID,punts_snap$game_play_ID)]
final_df_catchPred$land<-punts_land$x[match(final_df_catchPred$game_play_ID,punts_land$game_play_ID)]
final_df_catchPred$down<-punts_downed$x[match(final_df_catchPred$game_play_ID,punts_downed$game_play_ID)]
final_df_catchPred$catch_yard_line<-if_else(final_df_catchPred$playDirection == "left",final_df_catchPred$land,100-final_df_catchPred$land)
final_df_catchPred$down_yard_line<-if_else(final_df_catchPred$playDirection == "left",final_df_catchPred$down,100-final_df_catchPred$down)
final_df_catchPred$catch_field_width<-punts_land$y[match(final_df_catchPred$game_play_ID,punts_snap$game_play_ID)]
final_df_catchPred$punt_speed<-max_s_by_play$s[match(final_df_catchPred$game_play_ID,max_s_by_play$game_play_ID)]
final_df_catchPred$punt_acc<-max_a_by_play$a[match(final_df_catchPred$game_play_ID,max_a_by_play$game_play_ID)]
final_df_catchPred$good_snap<-final_df_catchPred$bin_snap
final_df_catchPred$kick_towards_sideline<-ifelse(final_df_catchPred$kick_dir == "C",0,1)
final_df_catchPred$rugby_kick<-final_df_catchPred$bin_Rugby_kick
final_df_catchPred$aussie_kick<-final_df_catchPred$bin_NoseDown_kick

final_df_catchPred$bounce_length<-predict(df_punt_trajectory_reg, newdata = final_df_catchPred )
summary(final_df_catchPred$bounce_length)
summary(final_df_catchPred$catch_yard_line)

final_df_catchPred$expected_downed<-ifelse(final_df_catchPred$playDirection == "left",final_df_catchPred$catch_yard_line + final_df_catchPred$bounce_length,final_df_catchPred$catch_yard_line -final_df_catchPred$bounce_length)
final_df_catchPred$expected_downed<-ifelse(final_df_catchPred$playDirection == "left",final_df_catchPred$catch_yard_line + final_df_catchPred$bounce_length,final_df_catchPred$catch_yard_line -final_df_catchPred$bounce_length)
summary(final_df_catchPred$expected_downed)

final_df_catchPred$specialTeamsResult<-punts$specialTeamsResult[match(final_df_catchPred$game_play_ID,punts$game_play_ID)]

analysis_df<-filter(final_df_catchPred,final_df_catchPred$specialTeamsResult == "Downed"|final_df_catchPred$specialTeamsResult =="Return"|final_df_catchPred$specialTeamsResult =="Touchback"|final_df_catchPred$specialTeamsResult =="Fair Catch"
                    &final_df_catchPred$punt_speed>5&final_df_catchPred$kickLength>40)
library(tidyverse)
analysis_df<-analysis_df %>% drop_na(expected_downed)

analysis_df$final_x_line<-ifelse(analysis_df$specialTeamsResult == "Touchback",20,ifelse(analysis_df$specialTeamsResult == "Downed",analysis_df$down_yard_line,analysis_df$catch_yard_line))
analysis_df$final_yard_line<-ifelse(analysis_df$final_x_line<40,analysis_df$final_x_line+10,analysis_df$final_x_line-10)

analysis_df$final_expected_downed<-ifelse(analysis_df$expected_downed<0,20,analysis_df$expected_downed)

analysis_df$hidden_yards<-(analysis_df$final_yard_line-analysis_df$final_expected_downed)*analysis_df$`prediction$CC`

analysis_df$kicking_team<-plays$possessionTeam[match(analysis_df$game_play_ID,plays$game_play_id)]
analysis_df$recieving_team<-plays$recieving_team[match(analysis_df$game_play_ID,plays$game_play_id)]

analysis_df$season<-plays$season[match(analysis_df$game_play_ID,plays$game_play_id)]

analysis_df$team_season_kick<-paste(analysis_df$kicking_team,analysis_df$season)
analysis_df$team_season_rec<-paste(analysis_df$recieving_team,analysis_df$season)

kickteam_hy<-aggregate(hidden_yards~team_season_kick,data = analysis_df, sum)
recievingteam_hy<-aggregate(hidden_yards~team_season_rec,data = analysis_df, sum)

recievingteam_hy$hidden_yards_allowed<-kickteam_hy$hidden_yards[match(recievingteam_hy$team_season_rec,kickteam_hy$team_season_kick)]

recievingteam_hy$net_hidden_yards<-recievingteam_hy$hidden_yards - recievingteam_hy$hidden_yards_allowed
recievingteam_hy<-recievingteam_hy[order(recievingteam_hy$net_hidden_yards),]

analysis_df$punter<-plays$punter[match(analysis_df$game_play_ID,plays$game_play_id)]
analysis_df$returner<-plays$returner[match(analysis_df$game_play_ID,plays$game_play_id)]

punter_hy<-aggregate(hidden_yards~punter, data = analysis_df, mean)
punter_hy_count<-aggregate(hidden_yards~punter, data = analysis_df, length)
punter_hy$count<-punter_hy_count$hidden_yards[match(punter_hy$punter,punter_hy_count$punter)]
summary(punter_hy$count)
punter_hy<-filter(punter_hy,punter_hy$count>41)

returner_hy<-aggregate(hidden_yards~returner, data = analysis_df, mean)
returner_hy_count<-aggregate(hidden_yards~returner, data = analysis_df, length)
returner_hy$count<-returner_hy_count$hidden_yards[match(returner_hy$returner,returner_hy_count$returner)]
summary(returner_hy$count)
returner_hy<-filter(returner_hy,returner_hy$count>4)


plot(recievingteam_hy$hidden_yards)




