plot(analysis_df$hangTime,analysis_df$`prediction$CC`,xlab = "Hang Time", ylab = "Clean Catch Probability")
plot(analysis_df$kickLength,analysis_df$`prediction$CC`)

ggplot(recieving_team_hy_high, aes(x = reorder(recieving_team_hy_high$team_season_rec, +net_hidden_yards), y = net_hidden_yards))  +
  geom_col(fill = "#0099f9")+
  geom_text(aes(label = net_hidden_yards), vjust = 2, size = 5, color = "#000000")+
  labs(
    x = "Team and Season Name",
    y = "Best Net Hidden Yards"
  )

ggplot(recieving_team_hy_high, aes(x = reorder(recieving_team_hy_high$team_season_rec, -net_hidden_yards), y = net_hidden_yards))  +
  geom_col(fill = "#0099f9")+
  geom_text(aes(label = net_hidden_yards), vjust = 2, size = 3, color = "#000000")+
  labs(
    x = "Team and Season Name",
    y = "Worst Net Hidden Yards"
  )

ggplot(returner_hy, aes(reorder(returner, +hidden_yards), hidden_yards)) +
  geom_col(fill = "#0099f9")+
  geom_text(aes(label = hidden_yards), vjust = 2, size = 5, color = "#000000")+
  labs(
    x = "Returner Name",
    y = "Hidden Yards Gained Per Punt"
  )

ggplot(punter_hy, aes(reorder(punter, -hidden_yards), hidden_yards)) +
  geom_col(fill = "#0099f9")+
  geom_text(aes(label = hidden_yards), vjust = 2, size = 5, color = "#000000")+
  labs(
    x = "Punter Name",
    y = "Hidden Yards Allowed Per Punt"
  )

visreg(df_punt_trajectory_reg, "hangTime",  xlab = "Hang Time of Punt", ylab = "Length of Bounce After Punt Lands")
visreg(df_punt_trajectory_reg, "punt_speed",xlab = "Max Speed of Football After Punt", ylab = "Length of Bounce After Punt Lands")
