#R script for ball tracking exploration
#library(DataExplorer) #create report library function loaded

football_punts<-filter(punts,punts$team == "football")
football_punts$game_play_ID<-paste(football_punts$gameId,football_punts$playId)
max_s_by_play<-football_punts %>% group_by(game_play_ID) %>% top_n(1, s)
max_a_by_play<-football_punts %>% group_by(game_play_ID) %>% top_n(1, a)
punts_land<-filter(football_punts, event == "punt_land"|event == "punt_recieved"|event == "fair_catch")
punts_snap<-filter(football_punts, event == "ball_snap")
punts_downed<-filter(football_punts, event == "Downed")

#create_report(football_punts)

football_at_kick<-filter(football_punts,football_punts$event == "punt")

#plot(football_at_kick$x,football_at_kick$kickLength)

#write.csv(football_punts,file = "football_punts.csv")

#need to figure out a way to uncover the kick moment - 

#option 1 - speed delta is big? post 
#option 2 - figure out duration of frame id and map to snap time - could be fairly inconsistent

#after figuring out kick moment - using all downed punts create equation for kick length based on those factors

downed_punts_land<-filter(football_punts, event == "punt_land" &specialTeamsResult == "Downed")
downed_punts_downed<-filter(football_punts, event == "punt_downed" &specialTeamsResult == "Downed")
downed_punts_snap<-filter(football_punts, event == "ball_snap" & specialTeamsResult == "Downed")

downed_punts_snap$x.snap<-downed_punts_snap$x

downed_punts_land$x.land<-downed_punts_land$x
downed_punts_land$s.land<-downed_punts_land$s
downed_punts_land$y.land<-downed_punts_land$y

downed_punts_downed$x.downed<-downed_punts_downed$x

downed_punts_land$match<-paste(downed_punts_land$gameId,downed_punts_land$playId)
downed_punts_downed$match<-paste(downed_punts_downed$gameId,downed_punts_downed$playId)
downed_punts_snap$match<-paste(downed_punts_snap$gameId,downed_punts_snap$playId)
                                                              
snap_land_downed<-downed_punts_snap %>% right_join(downed_punts_land, by = "match")  %>% 
  right_join(downed_punts_downed, by = "match")

snap_land_downed<-filter(snap_land_downed, event.x == "ball_snap" & event.y == "punt_land" & event == "punt_downed")

snap_land_downed$bounce_length<-ifelse(snap_land_downed$playDirection == "left",-1*(snap_land_downed$x.land - snap_land_downed$x.downed),snap_land_downed$x.land - snap_land_downed$x.downed)
snap_land_downed$puntLOS<-ifelse(snap_land_downed$playDirection =="left",(100-snap_land_downed$x.snap),(100-snap_land_downed$x.snap))
snap_land_downed$puntHash<-(snap_land_downed$y.x-26.65)
snap_land_downed$catch_yard_line<-if_else(snap_land_downed$playDirection == "left",snap_land_downed$x.land,100-snap_land_downed$x.land)
snap_land_downed$catch_field_width<-(snap_land_downed$y.land-26.65)
snap_land_downed$punt_speed<-max_s_by_play$s[match(snap_land_downed$match,max_s_by_play$game_play_ID)]
snap_land_downed$punt_acc<-max_a_by_play$a[match(snap_land_downed$match,max_a_by_play$game_play_ID)]

snap_land_downed$good_snap<-ifelse(snap_land_downed$snapDetail == "OK",1,0)
snap_land_downed$kick_towards_sideline<-ifelse(snap_land_downed$kickDirectionActual == "C",0,1)
snap_land_downed$rugby_kick<-ifelse(snap_land_downed$kickType == "R",1,0)
snap_land_downed$aussie_kick<-ifelse(snap_land_downed$kickType == "A",1,0)

df_punt_trajectory <- snap_land_downed %>% select(c(bounce_length,puntLOS,catch_yard_line,
                                                    punt_speed,kickLength,hangTime,
                                                    aussie_kick))

df_punt_trajectory_reg <- lm(bounce_length~.,data = df_punt_trajectory)


summary(df_punt_trajectory_reg)





