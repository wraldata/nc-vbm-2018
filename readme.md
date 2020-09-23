
# 2018 NC vote by mail analysis

ProPublica and WRAL News partnered in the summer of 2020 to analyze data on absentee by-mail ballots cast in the 2018 general election in North Carolina. The analysis used absentee data published by the [North Carolina State Board of Elections](https://s3.amazonaws.com/dl.ncsbe.gov/ENRS/2018_11_06/absentee_20181106.zip).

Analysis was performed in SQL and Python by [Sophie Chou](https://twitter.com/mpetitchou), of ProPublica, and [Tyler Dukes](https://twitter.com/mtdukes), of WRAL News. ProPublica data reporter [Haru Coryne](https://twitter.com/harucoryne) reviewed the code and analysis.

## Basic statistics
In North Carolina, absentee ballots include both ballots cast at early voting locations (also called "one-stop" voting) well as those cast by mail. Both types of ballots are included in the state's absentee data, which details all ballot *requests* by North Carolina voters. [Click here for the full SQL queries generating the results below.](https://github.com/wraldata/nc-vbm-2018/blob/8badea41d19adbfa1c4a2c1251f021d0960ee0e6/vbm-analysis.sql#L9) 

This analysis focuses solely on absentee by-mail ballots in 2018 *returned* to county election officials, since some ballots sent to voters go unreturned or unreturned ballots are automatically spoiled if a voter casts a ballot in person or submits a duplicate ballot by mail. Per the suggestion of the State Board of Elections, we define returned ballots in the data as ballot requests with valid return dates.

That narrows the data down to 104,091 individual mail-in ballots returned in 2018. Because voters can submit new ballots if previous ones are rejected, this total includes duplicate ballots if a voter returned more than one.

### Returned mail-in ballots, by race
Race|Count|Percent
---|---|---
WHITE|78,161|75.1
BLACK or AFRICAN AMERICAN|14,915|14.3
UNDESIGNATED|5,011|4.8
ASIAN|2,516|2.4
OTHER|2,161|2.1
TWO or MORE RACES|756|0.7
INDIAN AMERICAN or ALASKA NATIVE|571|0.5

Absentee data includes cases where voters submit multiple requests for absentee ballots and return multiple ballots to county election officials in cases where previous attempts have been rejected. Based on `ncid`, there are 2,284 voters (with a total of 4,638 requests) who have submitted multiple requests for mail-in ballots and returned them, with a maximum of 4 returns. For the vast majority of these duplicates, the number of returns is two.

### Duplicate detail for returned mail-in ballots
Request count|Voter count
---|---
2|2,217
3|64
4|3

## Rejection rate analysis

Overall, 6,520 out of 104,091 ballots returned during the 2018 election were rejected, a 6.3% rejection rate. [Click here for the full SQL queries generating the results below.](https://github.com/wraldata/nc-vbm-2018/blob/8badea41d19adbfa1c4a2c1251f021d0960ee0e6/vbm-analysis.sql#L88) 

### Returned mail-in ballots by status
Ballot return status|count|percent
---|---|---
ACCEPTED|97,571|93.7
VOTER SIGNATURE MISSING|2,825|2.7
WITNESS INFO INCOMPLETE|1,678|1.6
RETURNED AFTER DEADLINE|878|0.8
SPOILED|771|0.7
NOT PROPERLY NOTARIZED|159|0.2
RETURNED UNDELIVERABLE|134|0.1
SIGNATURE DIFFERENT|33|0.0
PENDING|27|0.0
DUPLICATE|10|0.0
CONFLICT|5|0.0

We can use the `race`  field to further break these rates down by demographics, both in raw numbers and percentages.

### 2018 mail-in ballot rejections by race, raw
Ballot return status|White|Black|Undesignated|Two or more races|Other|Asian|Indian American
---|---|---|---|---|---|---|---
ACCEPTED|74,388|12,893|4,730|699|1,997|2,338|526
VOTER SIGNATURE MISSING|1,718|819|104|28|68|71|17
WITNESS INFO INCOMPLETE|759|735|68|10|39|55|12
RETURNED AFTER DEADLINE|585|158|51|15|30|33|6
SPOILED|455|235|40|1|18|12|10
NOT PROPERLY NOTARIZED|117|28|5|2|4|3|NULL
RETURNED UNDELIVERABLE|91|30|8|1|1|3|NULL
PENDING|22|1|2|NULL|1|1|NULL
SIGNATURE DIFFERENT|19|10|1|NULL|3|NULL|NULL
DUPLICATE|6|3|1|NULL|NULL|NULL|NULL
CONFLICT|1|3|1|NULL|NULL|NULL|NULL

### 2018 mail-in ballot rejections by race, percent
Ballot return status|White|Black|Undesignated|Two or more races|Other|Asian|Indian American
---|---|---|---|---|---|---|---
ACCEPTED|95.17|86.44|94.39|92.46|92.41|92.93|92.12
VOTER SIGNATURE MISSING|2.20|5.49|2.08|3.70|3.15|2.82|2.98
WITNESS INFO INCOMPLETE|0.97|4.93|1.36|1.32|1.80|2.19|2.10
RETURNED AFTER DEADLINE|0.75|1.06|1.02|1.98|1.39|1.31|1.05
SPOILED|0.58|1.58|0.80|0.13|0.83|0.48|1.75
NOT PROPERLY NOTARIZED|0.15|0.19|0.10|0.26|0.19|0.12|NULL
RETURNED UNDELIVERABLE|0.12|0.20|0.16|0.13|0.05|0.12|NULL
PENDING|0.03|0.01|0.04|NULL|0.05|0.04|NULL
SIGNATURE DIFFERENT|0.02|0.07|0.02|NULL|0.14|NULL|NULL
DUPLICATE|0.01|0.02|0.02|NULL|NULL|NULL|NULL
CONFLICT|0.00|0.02|0.02|NULL|NULL|NULL|NULL

Comparing the rejection rates gives us more detail on potential disparities between demographic groups. Ratios here are calculated by dividing the rejection rate of each racial group by the rejection rate for white voters.

### Ratio of rejection rates, not including unreceived ballots
Racial group|Ratio
---|---
BLACK or AFRICAN AMERICAN|2.81
ASIAN|1.46
INDIAN AMERICAN or ALASKA NATIVE|1.63

By this measure, ballots case by Black voters are rejected at almost three times the rate of white voters.

## Analysis of voting by other methods

Even if a mail-in ballot is rejected, there are still options for people who want to get their votes counted. We requested a [voter history snapshot](https://s3.amazonaws.com/dl.ncsbe.gov/ENRS/Request/2020-08-16%20vh_from_snapshot.zip) from the State Board of Elections as of Jan. 1, 2019, (the closest available to the 2018 election) to see how many of the rejected mail-in ballots were eventually counted some other way. [Click here for the full SQL queries generating the results below.](https://github.com/wraldata/nc-vbm-2018/blob/8badea41d19adbfa1c4a2c1251f021d0960ee0e6/vbm-analysis.sql#L297) 

The 6,520 rejected ballots from 2018 were returned by 6,383 unique voters. That's out of a total of 103,072 unique voters with returned ballots.

### Unique voters with rejected, returned ballots, by race
Racial group|Voters rejected at least once|Mail-in voters|Percent rejected by racial group
---|---|---|---
WHITE|3,721|77,545|4.80
BLACK or AFRICAN AMERICAN|1,945|14,588|13.33
UNDESIGNATED|274|4,978|5.50
ASIAN|178|2,500|7.12
OTHER|163|2,143|7.61
TWO or MORE RACES|57|754|7.56
INDIAN AMERICAN or ALASKA NATIVE|45|564|7.98

Of the 6,383 unique voters whose ballots were rejected at least once, 882 eventually had their mail-in ballots accepted (14%). That leaves 5,501 voters whose mail-in ballots were ultimately received and rejected, or about 5.3% of all mail-in voters.

But even accounting for the multiple requests and eventual acceptances, Black voters have their mail-in ballots rejected at almost three times the rate of white voters, and more than twice the overall rate.

### Rejected absentee by mail voters by race
Race|Count of voters ultimately rejected|Percent of rejected voters|Total voters| Percent of total voters
---|---|---|---|---
WHITE|3,157|57.39|77,545|4.07
BLACK or AFRICAN AMERICAN|1,695|30.81|14,588|11.62
UNDESIGNATED|248|4.51|4,978|4.98
ASIAN|162|2.94|2,500|6.48
OTHER|146|2.65|2,143|6.81
TWO or MORE RACES|55|1.00|754|7.29
INDIAN AMERICAN or ALASKA NATIVE|38|0.69|564|6.74

Of those 5,501 voters whose mail-in ballots were returned and ultimately rejected, 4,690 (85%) never had their ballots counted by some other means in 2018.

### Rejected mail-in voters by final voting method
Voting method|Count|Percent of total
---|---|---
UNCOUNTED|4,690|85.26
ABSENTEE ONESTOP|441|8.02
IN-PERSON|272|4.94
ABSENTEE CURBSIDE|51|0.93
CURBSIDE|33|0.60
ABSENTEE BY MAIL|8|0.15
PROVISIONAL|6|0.11

### Rejected mail-in voters by final voting method and race, raw
Voting method|Overall count|White count|Black count|Undesignated count|Asian count|Other count| Indian American count|Multi-racial count
---|---|---|---|---|---|---|---|---
UNCOUNTED | 4,689 | 2,789 | 1,353 | 210 | 127 | 123 | 35 | 52
ABSENTEE ONESTOP | 441 | 222 | 156 | 24 | 18 | 17 | 2 | 2
IN-PERSON | 271 | 97 | 137 | 12 | 17 | 6 | 1 | 1
ABSENTEE CURBSIDE | 51 | 22 | 29 | NULL | NULL | NULL | NULL | NULL
CURBSIDE | 33 | 16 | 16 | 1 | NULL | NULL | NULL | NULL
ABSENTEE BY MAIL | 8 | 8 | NULL | NULL | NULL | NULL | NULL | NULL
PROVISIONAL | 6 | 2 | 4 | NULL | NULL | NULL | NULL | NULL

### Rejected mail-in voters by final voting method and race, percent
Voting method|Overall count|White count|Black count|Undesignated count|Asian count|Other count| Indian American count|Multi-racial count
---|---|---|---|---|---|---|---|---
UNCOUNTED | 85.24 | 88.37 | 79.82 | 85.02 | 78.40 | 84.25 | 92.11 | 94.55
ABSENTEE ONESTOP | 8.02 | 7.03 | 9.20 | 9.72 | 11.11 | 11.64 | 5.26 | 3.64
IN-PERSON | 4.93 | 3.07 | 8.08 | 4.86 | 10.49 | 4.11 | 2.63 | 1.82
ABSENTEE CURBSIDE | 0.93 | 0.70 | 1.71 | NULL | NULL | NULL | NULL | NULL
CURBSIDE | 0.60 | 0.51 | 0.94 | 0.40 | NULL | NULL | NULL | NULL
ABSENTEE BY MAIL | 0.15 | 0.25 | NULL | NULL | NULL | NULL | NULL | NULL
PROVISIONAL | 0.11 | 0.06 | 0.24 | NULL | NULL | NULL | NULL | NULL

About 88% of white voters with returned and rejected ballots never had their ballots counted by some other means other than mail-in. That number is about 80% for Black voters. 

But 1,353 Black people who returned a mail-in ballot ultimately never had their votes counted. That's about 9% of the Black voters who returned a mail-in ballot. That rate is twice that of overall mail-in voters and almost three times that of white voters.

### Rejected mail-in ballot voters
Ballot status|Overall %|White %|Black %|Undesignated %|Asian %|Other %|Indian-American %|Multiracial %
---|---|---|---|---|---|---|---|---
Ultimately uncounted | 4.55 | 3.60 | 9.27 | 4.22 | 5.08 | 5.74 | 6.21 | 6.90

 *NOTE: A significant caveat here is that the `ncid` field, which we're using to match voters from our absentee data to the voter history data, can in some cases change for voters. To account for this, we ran a similar analysis for the "snapshot" voter history file as of Jan. 1, 2019, as well as the voter history file pulled in the summer of 2020. The results were nearly identical.*

## Risk ratio analysis

To compare rejection rates between ballots cast by minority voters and white voters, we used a risk ratio analysis, dividing the rate of ballot rejections in the minority group by the rate of ballot rejections among white voters. The resulting ratio, commonly used in epidemiology, gives an estimate for how much more at risk ballots cast by voters in the minority group were to be rejected. [Click here for the full Python notebooks generating the results below.](https://github.com/wraldata/nc-vbm-2018/blob/master/notebooks/RaceRiskRatios.ipynb)

All minority racial groups were more likely to have their ballots rejected. Black voters were more than twice as likely as white voters to have their ballots rejected.

Race | Risk ratio compared to ballots cast by white voters | Total rejected ballots | Lower limit, 95% confidence interval | Upper limit, 95% confidence interval
--- | --- | --- | --- | ---
Black | 2.3621 | 2022 | 2.2726 | 2.4551
Indian American or Alaska Native | 1.6786 | 45 | 1.2402 | 2.272
Two or More Races | 1.5987 | 57 | 1.2228 | 2.0901
Other | 1.5933 | 164 | 1.3633 | 1.8622
Asian | 1.4785 | 178 | 1.2738 | 1.716
Undesignated | 1.1594 | 281 | 1.0323 | 1.3022
All minorities (excluding undesignated) | 1.9886 | 2466 | 1.9235 | 2.056

## County-level analysis

Elections are administered by different boards in each of North Carolina's 100 counties, so we can examine the differences in acceptance rates for each. [Click here for the full SQL queries generating the results below.](https://github.com/wraldata/nc-vbm-2018/blob/8badea41d19adbfa1c4a2c1251f021d0960ee0e6/vbm-analysis.sql#L1247)

### County-by-county acceptance rates by race, returned ballots
County|Overall rate|White rate|Black rate|Undesignated rate|Multi-racial rate|Other rate|Asian rate|American Indian rate
---|---|---|---|---|---|---|---|---
NORTHAMPTON|74.7|82.7|69.7|80.0|NULL|NULL|NULL|NULL
HALIFAX|75.4|81.3|71.1|100.0|33.3|100.0|66.7|71.4
GRANVILLE|76.7|81.8|65.4|93.3|33.3|77.8|100.0|100.0
PASQUOTANK|81.1|83.6|73.0|81.8|100.0|100.0|100.0|NULL
TYRRELL|81.3|100.0|40.0|NULL|NULL|NULL|NULL|NULL
PITT|82.4|84.2|79.9|85.7|75.0|78.6|86.4|75.0
SAMPSON|82.6|89.7|72.5|66.7|100.0|100.0|NULL|75.0
BEAUFORT|83.6|90.8|70.1|87.5|100.0|NULL|NULL|NULL
VANCE|83.7|95.1|73.6|75.0|100.0|NULL|NULL|NULL
DAVIDSON|85.1|86.2|73.4|92.1|60.0|79.2|84.6|80.0
ROCKINGHAM|85.7|90.1|62.8|100.0|80.0|100.0|100.0|NULL
PERSON|86.2|87.8|83.3|71.4|NULL|100.0|NULL|100.0
HOKE|86.3|92.2|80.5|100.0|100.0|76.5|83.3|84.0
WAYNE|86.4|93.0|74.2|90.7|80.0|90.9|62.5|NULL
HERTFORD|87.0|96.3|84.1|100.0|NULL|100.0|NULL|100.0
STANLY|87.6|90.3|66.7|84.2|NULL|100.0|83.3|NULL
WILSON|87.8|94.3|74.1|79.2|75.0|81.8|33.3|NULL
CUMBERLAND|88.6|91.9|82.0|93.5|97.1|91.3|93.6|90.3
BERTIE|88.6|95.2|83.3|100.0|100.0|NULL|100.0|NULL
MOORE|89.1|91.7|70.5|94.0|100.0|72.5|80.0|83.3
MADISON|89.1|88.2|NULL|100.0|100.0|100.0|NULL|100.0
RICHMOND|89.2|94.8|80.7|83.3|100.0|71.4|100.0|100.0
EDGECOMBE|89.4|94.8|86.3|75.0|NULL|NULL|NULL|NULL
NEW HANOVER|89.4|90.1|80.5|92.7|100.0|85.7|83.3|100.0
ALLEGHANY|89.4|90.2|NULL|50.0|NULL|NULL|NULL|NULL
GATES|89.5|100.0|83.3|100.0|NULL|50.0|NULL|NULL
SURRY|90.1|90.2|84.6|82.4|100.0|100.0|100.0|100.0
CRAVEN|90.4|91.7|86.4|96.7|85.7|88.9|77.8|100.0
DARE|90.5|91.7|55.6|75.0|NULL|66.7|100.0|NULL
LINCOLN|90.8|91.3|91.2|90.0|50.0|66.7|100.0|100.0
BLADEN|90.8|90.7|92.2|75.0|NULL|66.7|NULL|72.7
RUTHERFORD|90.8|91.5|68.2|100.0|100.0|75.0|100.0|100.0
BRUNSWICK|90.8|91.7|72.7|93.5|100.0|91.7|100.0|100.0
FRANKLIN|91.1|89.0|94.7|87.5|100.0|90.0|100.0|100.0
CALDWELL|91.2|91.0|87.5|100.0|100.0|100.0|NULL|NULL
DUPLIN|91.4|92.0|89.5|100.0|NULL|100.0|NULL|NULL
FORSYTH|91.6|93.7|83.9|91.9|87.1|88.2|85.3|85.7
HYDE|91.8|95.0|75.0|NULL|NULL|100.0|NULL|NULL
DURHAM|91.9|93.7|82.4|94.5|98.1|92.6|88.5|88.9
ROBESON|92.0|96.1|84.5|75.0|75.0|100.0|100.0|95.7
BUNCOMBE|92.1|92.7|80.6|90.7|87.0|94.8|94.6|80.0
HARNETT|92.1|94.4|82.6|92.6|100.0|87.8|100.0|80.0
GUILFORD|92.1|94.5|83.5|95.0|95.0|88.5|82.7|84.6
GREENE|92.2|97.7|90.5|100.0|NULL|100.0|NULL|NULL
CHATHAM|92.4|93.2|78.7|95.1|83.3|100.0|90.6|100.0
MCDOWELL|92.5|92.1|100.0|NULL|100.0|100.0|100.0|100.0
LEE|92.7|95.6|83.7|100.0|100.0|85.7|100.0|100.0
MARTIN|92.7|97.3|84.4|100.0|NULL|100.0|NULL|NULL
NASH|92.9|94.0|91.2|87.5|100.0|100.0|87.5|100.0
JACKSON|93.0|94.0|NULL|77.8|NULL|75.0|NULL|100.0
CATAWBA|93.6|94.0|87.0|100.0|75.0|94.1|83.3|100.0
CLAY|93.6|94.1|NULL|100.0|NULL|100.0|NULL|NULL
CHOWAN|94.0|96.4|85.7|100.0|NULL|100.0|NULL|NULL
YADKIN|94.1|95.6|66.7|100.0|NULL|100.0|100.0|100.0
LENOIR|94.2|96.7|91.7|100.0|NULL|NULL|100.0|NULL
CABARRUS|94.3|95.8|86.8|95.5|94.7|96.6|84.7|100.0
MONTGOMERY|94.3|94.6|96.8|100.0|100.0|80.0|66.7|NULL
BURKE|94.5|96.5|77.8|85.7|100.0|88.9|83.3|100.0
HAYWOOD|94.5|94.2|100.0|100.0|100.0|100.0|100.0|100.0
UNION|94.7|95.2|89.5|97.6|100.0|93.0|96.7|100.0
CLEVELAND|94.8|97.2|82.5|100.0|75.0|100.0|100.0|50.0
CURRITUCK|94.8|94.7|100.0|100.0|100.0|66.7|NULL|100.0
WASHINGTON|95.2|97.4|93.3|NULL|NULL|NULL|NULL|NULL
GASTON|95.3|96.2|90.6|97.1|100.0|83.3|94.1|100.0
CAMDEN|95.3|95.0|94.4|100.0|100.0|100.0|NULL|100.0
ROWAN|95.6|97.6|86.0|96.7|80.0|83.3|95.2|66.7
WARREN|95.8|95.9|96.7|100.0|NULL|100.0|NULL|100.0
WAKE|95.9|96.5|90.9|95.3|93.7|95.1|96.3|95.5
ANSON|95.9|97.0|97.3|89.3|NULL|100.0|100.0|NULL
MECKLENBURG|96.0|97.2|92.3|93.2|90.0|94.6|95.5|89.6
ALEXANDER|96.1|96.0|92.9|100.0|100.0|100.0|100.0|NULL
YANCEY|96.4|96.2|100.0|100.0|NULL|100.0|100.0|NULL
MACON|96.4|96.9|83.3|100.0|100.0|100.0|50.0|50.0
AVERY|96.5|97.0|NULL|88.9|NULL|NULL|NULL|NULL
POLK|96.7|97.1|77.8|100.0|100.0|NULL|100.0|NULL
DAVIE|96.7|97.8|96.8|91.3|33.3|85.7|100.0|NULL
COLUMBUS|96.8|99.3|95.6|100.0|NULL|100.0|50.0|96.3
WATAUGA|97.1|97.4|83.3|92.3|100.0|100.0|100.0|100.0
PENDER|97.3|97.0|97.8|100.0|100.0|100.0|100.0|100.0
CASWELL|97.3|99.0|91.2|100.0|100.0|NULL|100.0|100.0
CARTERET|97.4|97.8|91.7|100.0|33.3|100.0|100.0|NULL
MITCHELL|97.5|97.4|NULL|100.0|NULL|NULL|NULL|NULL
JOHNSTON|97.6|98.7|94.2|98.6|100.0|88.6|93.8|100.0
RANDOLPH|97.6|98.3|92.9|100.0|87.5|88.9|85.7|NULL
ASHE|97.8|98.1|NULL|80.0|NULL|100.0|NULL|NULL
SWAIN|98.0|97.8|100.0|100.0|NULL|100.0|NULL|100.0
SCOTLAND|98.1|98.5|97.4|100.0|100.0|100.0|100.0|96.3
PAMLICO|98.4|100.0|96.1|100.0|NULL|NULL|NULL|100.0
ONSLOW|98.6|99.3|94.8|100.0|75.0|100.0|100.0|100.0
HENDERSON|98.7|98.8|96.9|97.8|87.5|100.0|100.0|100.0
WILKES|98.7|98.6|100.0|100.0|100.0|100.0|100.0|NULL
STOKES|98.8|98.8|100.0|100.0|100.0|NULL|100.0|NULL
ORANGE|99.2|99.3|97.0|99.6|100.0|100.0|97.8|100.0
TRANSYLVANIA|99.4|99.3|100.0|100.0|NULL|100.0|100.0|NULL
ALAMANCE|99.7|99.7|100.0|97.8|100.0|100.0|100.0|100.0
GRAHAM|100.0|100.0|NULL|100.0|NULL|NULL|100.0|NULL
IREDELL|100.0|100.0|100.0|100.0|100.0|100.0|100.0|100.0
CHEROKEE|100.0|100.0|100.0|100.0|NULL|NULL|100.0|100.0
JONES|100.0|100.0|100.0|100.0|NULL|NULL|100.0|NULL
PERQUIMANS|100.0|100.0|100.0|NULL|100.0|NULL|NULL|NULL

### Accepted mail-in ballots for black and white voters by county, excluding unreceived ballots
County|Overall accepted ballots|Overall total ballots|Overall rate|White accepted ballots|White total ballots|White rate|Black accepted ballots|Black total ballots|Black rate
---|---|---|---|---|---|---|---|---|---
MECKLENBURG | 13,226 | 13,772 | 96.0 | 9,651 | 9,927 | 97.2 | 2,038 | 2,207 | 92.3
WAKE | 16,416 | 17,126 | 95.9 | 12,782 | 13,249 | 96.5 | 1,356 | 1,492 | 90.9
GUILFORD | 5,538 | 6,013 | 92.1 | 4,104 | 4,343 | 94.5 | 897 | 1,074 | 83.5
CUMBERLAND | 2,336 | 2,638 | 88.6 | 1,098 | 1,195 | 91.9 | 772 | 942 | 82.0
FORSYTH | 4,622 | 5,046 | 91.6 | 3,488 | 3,721 | 93.7 | 762 | 908 | 83.9
DURHAM | 2,871 | 3,125 | 91.9 | 1,992 | 2,127 | 93.7 | 380 | 461 | 82.4
PITT | 787 | 955 | 82.4 | 410 | 487 | 84.2 | 311 | 389 | 79.9
BLADEN | 840 | 925 | 90.8 | 489 | 539 | 90.7 | 332 | 360 | 92.2
CABARRUS | 2,463 | 2,612 | 94.3 | 1,902 | 1,986 | 95.8 | 295 | 340 | 86.8
NASH | 696 | 749 | 92.9 | 395 | 420 | 94.0 | 258 | 283 | 91.2
UNION | 2,468 | 2,605 | 94.7 | 1,902 | 1,998 | 95.2 | 246 | 275 | 89.5
JOHNSTON | 1,535 | 1,573 | 97.6 | 1,133 | 1,148 | 98.7 | 258 | 274 | 94.2
FRANKLIN | 632 | 694 | 91.1 | 364 | 409 | 89.0 | 214 | 226 | 94.7
HARNETT | 1,200 | 1,303 | 92.1 | 881 | 933 | 94.4 | 185 | 224 | 82.6
ROBESON | 691 | 751 | 92.0 | 294 | 306 | 96.1 | 180 | 213 | 84.5
CRAVEN | 834 | 923 | 90.4 | 598 | 652 | 91.7 | 178 | 206 | 86.4
COLUMBUS | 364 | 376 | 96.8 | 140 | 141 | 99.3 | 194 | 203 | 95.6
WAYNE | 519 | 601 | 86.4 | 320 | 344 | 93.0 | 141 | 190 | 74.2
GASTON | 1,347 | 1,413 | 95.3 | 1,077 | 1,120 | 96.2 | 164 | 181 | 90.6
ROWAN | 1,245 | 1,302 | 95.6 | 1,022 | 1,047 | 97.6 | 148 | 172 | 86.0
NEW HANOVER | 1,934 | 2,163 | 89.4 | 1,654 | 1,836 | 90.1 | 136 | 169 | 80.5
GREENE | 200 | 217 | 92.2 | 42 | 43 | 97.7 | 152 | 168 | 90.5
LENOIR | 295 | 313 | 94.2 | 146 | 151 | 96.7 | 144 | 157 | 91.7
HALIFAX | 208 | 276 | 75.4 | 87 | 107 | 81.3 | 106 | 149 | 71.1
MOORE | 1,420 | 1,593 | 89.1 | 1,209 | 1,318 | 91.7 | 105 | 149 | 70.5
ALAMANCE | 1,252 | 1,256 | 99.7 | 1,033 | 1,036 | 99.7 | 141 | 141 | 100.0
IREDELL | 2,418 | 2,418 | 100.0 | 2,084 | 2,084 | 100.0 | 139 | 139 | 100.0
BUNCOMBE | 3,074 | 3,338 | 92.1 | 2,627 | 2,833 | 92.7 | 108 | 134 | 80.6
DAVIDSON | 1,435 | 1,686 | 85.1 | 1,269 | 1,473 | 86.2 | 94 | 128 | 73.4
HOKE | 272 | 315 | 86.3 | 119 | 129 | 92.2 | 99 | 123 | 80.5
WILSON | 416 | 474 | 87.8 | 298 | 316 | 94.3 | 86 | 116 | 74.1
RICHMOND | 289 | 324 | 89.2 | 182 | 192 | 94.8 | 92 | 114 | 80.7
LINCOLN | 584 | 643 | 90.8 | 438 | 480 | 91.3 | 104 | 114 | 91.2
VANCE | 185 | 221 | 83.7 | 97 | 102 | 95.1 | 81 | 110 | 73.6
GRANVILLE | 250 | 326 | 76.7 | 157 | 192 | 81.8 | 68 | 104 | 65.4
ORANGE | 2,293 | 2,312 | 99.2 | 1,668 | 1,680 | 99.3 | 98 | 101 | 97.0
LEE | 367 | 396 | 92.7 | 259 | 271 | 95.6 | 82 | 98 | 83.7
BEAUFORT | 250 | 299 | 83.6 | 167 | 184 | 90.8 | 68 | 97 | 70.1
ONSLOW | 617 | 626 | 98.6 | 443 | 446 | 99.3 | 92 | 97 | 94.8
NORTHAMPTON | 109 | 146 | 74.7 | 43 | 52 | 82.7 | 62 | 89 | 69.7
HERTFORD | 107 | 123 | 87.0 | 26 | 27 | 96.3 | 74 | 88 | 84.1
ROCKINGHAM | 408 | 476 | 85.7 | 319 | 354 | 90.1 | 54 | 86 | 62.8
EDGECOMBE | 127 | 142 | 89.4 | 55 | 58 | 94.8 | 69 | 80 | 86.3
CLEVELAND | 513 | 541 | 94.8 | 423 | 435 | 97.2 | 66 | 80 | 82.5
SAMPSON | 195 | 236 | 82.6 | 122 | 136 | 89.7 | 58 | 80 | 72.5
SCOTLAND | 252 | 257 | 98.1 | 132 | 134 | 98.5 | 74 | 76 | 97.4
CHATHAM | 1,087 | 1,177 | 92.4 | 899 | 965 | 93.2 | 59 | 75 | 78.7
ANSON | 163 | 170 | 95.9 | 64 | 66 | 97.0 | 72 | 74 | 97.3
BRUNSWICK | 989 | 1,089 | 90.8 | 850 | 927 | 91.7 | 48 | 66 | 72.7
PASQUOTANK | 198 | 244 | 81.1 | 138 | 165 | 83.6 | 46 | 63 | 73.0
BERTIE | 93 | 105 | 88.6 | 40 | 42 | 95.2 | 50 | 60 | 83.3
WARREN | 136 | 142 | 95.8 | 71 | 74 | 95.9 | 58 | 60 | 96.7
DUPLIN | 138 | 151 | 91.4 | 80 | 87 | 92.0 | 51 | 57 | 89.5
CATAWBA | 831 | 888 | 93.6 | 706 | 751 | 94.0 | 47 | 54 | 87.0
PAMLICO | 120 | 122 | 98.4 | 67 | 67 | 100.0 | 49 | 51 | 96.1
STANLY | 444 | 507 | 87.6 | 383 | 424 | 90.3 | 34 | 51 | 66.7
PERSON | 156 | 181 | 86.2 | 108 | 123 | 87.8 | 40 | 48 | 83.3
WASHINGTON | 79 | 83 | 95.2 | 37 | 38 | 97.4 | 42 | 45 | 93.3
PENDER | 325 | 334 | 97.3 | 258 | 266 | 97.0 | 44 | 45 | 97.8
MARTIN | 115 | 124 | 92.7 | 73 | 75 | 97.3 | 38 | 45 | 84.4
GATES | 68 | 76 | 89.5 | 31 | 31 | 100.0 | 35 | 42 | 83.3
BURKE | 467 | 494 | 94.5 | 412 | 427 | 96.5 | 28 | 36 | 77.8
CASWELL | 145 | 149 | 97.3 | 97 | 98 | 99.0 | 31 | 34 | 91.2
HENDERSON | 1,852 | 1,877 | 98.7 | 1,702 | 1,723 | 98.8 | 31 | 32 | 96.9
DAVIE | 414 | 428 | 96.7 | 353 | 361 | 97.8 | 30 | 31 | 96.8
MONTGOMERY | 182 | 193 | 94.3 | 139 | 147 | 94.6 | 30 | 31 | 96.8
RANDOLPH | 686 | 703 | 97.6 | 618 | 629 | 98.3 | 26 | 28 | 92.9
PERQUIMANS | 77 | 77 | 100.0 | 50 | 50 | 100.0 | 26 | 26 | 100.0
CALDWELL | 361 | 396 | 91.2 | 323 | 355 | 91.0 | 21 | 24 | 87.5
RUTHERFORD | 393 | 433 | 90.8 | 344 | 376 | 91.5 | 15 | 22 | 68.2
CHOWAN | 79 | 84 | 94.0 | 54 | 56 | 96.4 | 18 | 21 | 85.7
CAMDEN | 81 | 85 | 95.3 | 57 | 60 | 95.0 | 17 | 18 | 94.4
WILKES | 441 | 447 | 98.7 | 411 | 417 | 98.6 | 15 | 15 | 100.0
JONES | 49 | 49 | 100.0 | 30 | 30 | 100.0 | 15 | 15 | 100.0
YADKIN | 224 | 238 | 94.1 | 197 | 206 | 95.6 | 10 | 15 | 66.7
ALEXANDER | 195 | 203 | 96.1 | 169 | 176 | 96.0 | 13 | 14 | 92.9
SURRY | 626 | 695 | 90.1 | 590 | 654 | 90.2 | 11 | 13 | 84.6
CARTERET | 478 | 491 | 97.4 | 435 | 445 | 97.8 | 11 | 12 | 91.7
WATAUGA | 673 | 693 | 97.1 | 638 | 655 | 97.4 | 10 | 12 | 83.3
TRANSYLVANIA | 461 | 464 | 99.4 | 422 | 425 | 99.3 | 11 | 11 | 100.0
STOKES | 255 | 258 | 98.8 | 237 | 240 | 98.8 | 9 | 9 | 100.0
DARE | 420 | 464 | 90.5 | 397 | 433 | 91.7 | 5 | 9 | 55.6
POLK | 320 | 331 | 96.7 | 306 | 315 | 97.1 | 7 | 9 | 77.8
HYDE | 45 | 49 | 91.8 | 38 | 40 | 95.0 | 6 | 8 | 75.0
CURRITUCK | 201 | 212 | 94.8 | 178 | 188 | 94.7 | 7 | 7 | 100.0
MACON | 461 | 478 | 96.4 | 444 | 458 | 96.9 | 5 | 6 | 83.3
TYRRELL | 13 | 16 | 81.3 | 11 | 11 | 100.0 | 2 | 5 | 40.0
MCDOWELL | 198 | 214 | 92.5 | 186 | 202 | 92.1 | 3 | 3 | 100.0
CHEROKEE | 263 | 263 | 100.0 | 248 | 248 | 100.0 | 2 | 2 | 100.0
HAYWOOD | 512 | 542 | 94.5 | 489 | 519 | 94.2 | 2 | 2 | 100.0
YANCEY | 531 | 551 | 96.4 | 505 | 525 | 96.2 | 1 | 1 | 100.0
SWAIN | 96 | 98 | 98.0 | 88 | 90 | 97.8 | 1 | 1 | 100.0
CLAY | 102 | 109 | 93.6 | 96 | 102 | 94.1 | NULL | NULL | NULL
MADISON | 155 | 174 | 89.1 | 142 | 161 | 88.2 | NULL | NULL | NULL
ASHE | 313 | 320 | 97.8 | 308 | 314 | 98.1 | NULL | NULL | NULL
MITCHELL | 158 | 162 | 97.5 | 150 | 154 | 97.4 | NULL | NULL | NULL
ALLEGHANY | 93 | 104 | 89.4 | 92 | 102 | 90.2 | NULL | NULL | NULL
AVERY | 136 | 141 | 96.5 | 128 | 132 | 97.0 | NULL | NULL | NULL
GRAHAM | 96 | 96 | 100.0 | 94 | 94 | 100.0 | NULL | NULL | NULL
JACKSON | 277 | 298 | 93.0 | 264 | 281 | 94.0 | NULL | NULL | NULL