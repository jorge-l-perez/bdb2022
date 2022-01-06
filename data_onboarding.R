setwd("~/Desktop/Sports Analytics/nfl-big-data-bowl-2022")


# * load packages ----
library(devtools)
library(dplyr)
library(gganimate)
library(ggforce)
library(ggplot2)
library(readr)

#load all data for Big Data Bowl 2022

games<-read.csv("games.csv") #2018 game data with game ids
PFFscout<-read.csv("PFFScoutingData.csv") #additional qualitative data from PFF - operation timing, directional, and positions
players<-read.csv("players.csv") #full list of players with ids
plays<-read.csv("plays.csv") #play descriptions and ids
tracking2018<-read.csv("tracking2018.csv")
tracking2019<-read.csv("tracking2019.csv")
tracking2020<-read.csv("tracking2020.csv")
plays$home_team<-games$homeTeamAbbr[match(plays$gameId,games$gameId)]
plays$away_team<-games$visitorTeamAbbr[match(plays$gameId,games$gameId)]
plays$season<-games$season[match(plays$gameId,games$gameId)]
plays$punter<-players$displayName[match(plays$kickerId,players$nflId)]
plays$returner<-players$displayName[match(plays$returnerId,players$nflId)]

plays$recieving_team<-ifelse(plays$home_team == plays$possessionTeam,as.character(plays$away_team),as.character(plays$home_team))
plays$game_play_id<-paste(plays$gameId,plays$playId)

#combine data sets in to parent database - this will be filter down but will contain all applicable data
tracking<-rbind(tracking2018,tracking2019,tracking2020)
tracking_games<-merge(tracking,games,by=c("gameId"))
tracking_games_plays<-merge(tracking_games,plays,by=c("gameId","playId"))
tracking_games_plays_pff<-merge(tracking_games_plays, PFFscout, by=c("gameId","playId"))

#removing objects for RAM space
rm(tracking,tracking_games,tracking_games_plays,tracking2018,tracking2019,tracking2020,tracking)

#filter down to just punts
punts<-dplyr::filter(tracking_games_plays_pff, tracking_games_plays_pff$specialTeamsPlayType == "Punt")
punts$game_play_ID<-paste(punts$gameId,punts$playId)

#fix or remove ----- max_s_by_play<-punts %>% filter(punts,punts$team == "football") %>% group_by(punts$game_play_ID) %>% top_n(1, s)
#fix or remove ----- max_a_by_play<-punts %>% filter(punts,punts$team == "football") %>% group_by(punts$game_play_ID) %>% top_n(1, a)


#EPA
#Load in EPA data from NFL Fast R
#Visualization
#https://github.com/asonty/ngs_highlights






