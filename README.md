1. Introduction

As the NFL makes strides to improve special teams performances, one of the initial areas impacted will be the punt return game. Gone are the days of Devin Hester and Dante Hall making defenders' knees buckle. This does not mean that the impact of the punter and returner is diminishing. It means we need new tools to assess the performance of special team units and players.

Hidden Yards (HY) is an attempt to quantify the impact of a returner's decision to field or not field a punt. While punt return yards can quantify what happens after the returner possesses the ball, HY aims to quanitfy decision-making and positioning, leading up to the catch, and adjusts for the catchability of punts.

HY can be measured as an individual and team statistic. It also takes the form of HY_generated and HY_allowed. HY_allowed can be used to assess the punters' ability to decrease the amount of HY gained by a returner catching their punt. Additionally, it can be used as a tool to measure gunners and other special teams coverage units.

1.1. Building the Hidden Yards Quantification Model

Calculating HY requires multiple steps and models. The first is a random forest probability model meant to calculate the likelihood of a clean catch for any given punt. This is critical as punts that are deemed non-catchable or with low catch probability lead to less opportunities for Hidden Yards. Punts that are more likely to be caught are our best opportunities to evaluate the decision to catch or to let the ball drop.

Once a catch probability is established, a linear model is built to attempt to estimate the bounce of any punt for yards gained or lost. When we add or subtract the bounce yardage from the yard line where the catch was due to be made, we get the expected downed yard line.

The difference between where the ball was fielded and where the ball was expected to be downed is Hidden Yards.

Hidden Yards takes a few forms and is applicable to a representative, yet not conclusive, set of situations described below:

Positive Hidden Yards

The punt is fielded when it would have bounced away from the punter and resulted in a loss of yards.
The punt is not fielded when it would have bounced towards the punting team for positive yardage.
The punt is not fielded inside the 20 yard line when it would have bounced into the end zone for a touchback.
Negative Hidden Yards

The punt is not fielded when it would have bounced away from the punter and resulted in a loss of yards.
The punt is fielded when it would have bounced towards the punting team for positive yardage.
The punt is fielded within the 20 yard line when it would have bounced into the end zone for touchback.
2. Model Buidling

As mentioned previously, the Hidden Yards metric is reliant on two primary models and computation between the resulting data.

2.1. The Punt Catch Probablity

The Punt Catch Probability is a decision-tree model that has been altered to provide a probability of a Clean Catch based on the data provided by PFF, rather than a classification. The model takes into account punt metrics such as hangTime, operationTime, KickLength, as well as the type of punt, direction of punt. The data was filtered to remove uncatchable punts, as these will not be a part of the final data set for analysis.

2.1.1. Punt Probability Results

In the dataset, a majority of punts we are evaluating are very catchable, as this is a pre-requisite for Hidden Yards analysis. However there is, on average a 6% difference in clean catch probablity for punts that are fielded versus not fielded.

Overall the factors that impact catchability the most are HangTime and KickLength. Generally speaking, catchability goes up as these metrics go up.

Additionally, Normal and Aussie kicks are much more catcahble than Rugby Style Kicks, and punts directed to the center increases chances for a catch.

2.2. Punt Trajectory Modeling

Once we have punt catch probability, we can proceed with modeling where the ball will be downed if not fielded based on a few added metrics. In order to more accurately model this, we need to understand the speed of each punt. Assuming the max ball speed in the initial frames is the speed right after kick helps us get this figure for all punts. Additionally, factors such as field position, punt landing zone, hang time, kick length and kick type, we can model where the ball will be downed.

The initial creation of a linear regression based on the factors mentioned above gives us the metric: bounce_length. This indicates how far the ball will travel in either direction.

In order to build this model, we utilized data from all available downed punts to try to measure the impact of each of these factors on the final resting place of the football once downed.

2.2.1. Punt Trajectory Modeling Results

Results for the punt trajectory models gives us the tools to find where the ball will be downed. These results tended to fall between the 15 and -15 yards and are highly dependent on the factors above.

Increases in Hang Time and Punt Speed lead to a higher likelihood that the ball will roll away from the punter. These are the two most influential factors, with Hang Time being most important.

Kick Length also impacted how far the punt will roll. As the Kick Length decreases, the likelihood that the ball will bounce back towards the punter increases. This is likely due to punters attempting to pin recieving teams inside the 20. These kicks are naturally shorter and punters are attempting to bring the ball back.

Additionally, nose-down or Aussie style kicks lead to a higher change of the ball bouncing back towards the punter.



2.3. Model Results and Accuracy

While models were built with Accuracy in mind, there is room for improvement to make results for useful and accurate. Below are accuracy metrics for each model. At this state, results be considered directional, rather than predictive. Work will be done to improve on results.

Punt Catch Probability Model - Accuracy : 0.7083

Punt Trajectory Model - Multiple R-squared: 0.6027

3. Hidden Yards Analysis and Results

With the two components above, we are able to calculate the hidden yards for all punts that were in the field of play. Starting with the yard-line at which the catch could have been made and adding or subtracting the expected bounce length gives us the expected downed yard line on that particular punt. We need to multiply by catch probability to ensure that likelihood of catch is accounted for. Any punt with an expected downed yard-line in the endzone will be transformed to be an expected downed yard line of 20. From there, the actual result of play, or catch yard line, is subtracted from the expected downed yard and the result is Hidden Yards. Positive Hidden Yards indicated the ball is further forward than it would have been if a different decision was made.

3.1. Returner Results

Based on this, we sum and average hidden yards generated by punt returners over the course of the 2018-2020 seaons. Minimum punt returns applied. This group of returners varies greatly from perception around the league as to whom are the best returners in the league. These returners get it done a different way.


3.2. Punter Results

Inversely, we look at punters with the least hidden yards allowed to measure punter quality. Minimum punts applied. The punters are adept at controlling catch likelihood and ball bounce, minimizing the impact of returners' decisions.


3.3. Results by Team

Finally, we can sum up hidden yards by team to see which teams made the best decisions in the punting game or benefited from the luck of a bounce.

4. Future Analysis and Improvements

Enhancements can be made to the modeling and factors used to increase the predictive power of the Hidden Yard metric.

Additionally, there are a number of other considerations and thoughts for future iterations of this analysis. They are listed below.

Add in weather factors to modeling of both catch and bounce_length
Evaluate other special teams' positions to see how they impact hidden yardage
Sync hidden yardage gained or lost to EPA data to understand how starting field position impacted by hidden yardage affects expected points added.
5. Appendix

All code can be found in this GitHub Repository.
