#WRAL/ProPublican analysis of 2018 absentee data in June/July/August/September 2020
#data source is absentee voter file from the North Carolina State Board of Elections

#data from
#https://s3.amazonaws.com/dl.ncsbe.gov/ENRS/2018_11_06/absentee_20181106.zip
#imported as table absentee

####################
# Basic statistics #
####################

#run a count of all mail-in ballots
#with a valid return date
SELECT COUNT(ncid) AS count
FROM absentee
WHERE ballot_req_type = 'MAIL'
AND ballot_rtn_dt <> '';

#calculate the racial breakdown for returned ballots
SELECT race, 
	COUNT(race) AS race_group,
	ROUND(
		(((COUNT(race) / (
			SELECT COUNT(*)
			FROM absentee
			WHERE ballot_req_type = "MAIL"
			AND ballot_rtn_dt <> ''
		))) * 100), 1) AS race_pct
FROM absentee
WHERE ballot_req_type = "MAIL"
AND ballot_rtn_dt <> ''
GROUP BY race
ORDER BY race_pct desc;

#check for duplicate registration numbers
SELECT ncid, COUNT(ncid) AS reg_no_count
FROM absentee
WHERE ballot_req_type = "MAIL"
AND ballot_rtn_status <> ''
GROUP BY ncid
HAVING reg_no_count > 1
ORDER BY reg_no_count desc

#count the distinct duplicates (voters)
SELECT COUNT(ncid)
FROM (
	SELECT ncid, COUNT(ncid) AS reg_no_count
	FROM absentee
	WHERE ballot_req_type = "MAIL"
	AND ballot_rtn_status <> ''
	GROUP BY ncid
	HAVING reg_no_count > 1
	ORDER BY reg_no_count desc
) AS dupe_ids;

#sum the total number of duplicates
SELECT SUM(reg_no_count)
FROM (
	SELECT ncid, COUNT(ncid) AS reg_no_count
	FROM absentee
	WHERE ballot_req_type = "MAIL"
	AND ballot_rtn_status <> ''
	GROUP BY ncid
	HAVING reg_no_count > 1
	ORDER BY reg_no_count desc
) AS dupe_ids;

#count up our duplicates by category
SELECT
CASE WHEN reg_no_count = 2 THEN 2
WHEN reg_no_count = 3 THEN 3
WHEN reg_no_count = 4 THEN 4
WHEN reg_no_count = 5 THEN 5
END AS req_count,
COUNT(reg_no_count) AS count
FROM (
	SELECT ncid, COUNT(ncid) AS reg_no_count
	FROM absentee
	WHERE ballot_req_type = "MAIL"
	AND ballot_rtn_status <> '' 
	GROUP BY ncid
	HAVING reg_no_count > 1
	ORDER BY reg_no_count desc
) AS request_grouping
GROUP BY req_count;

###########################
# Rejection rate analysis #
###########################

#calculate the reasons for rejection
SELECT ballot_rtn_status,
	COUNT(ncid) AS count,
	ROUND((((COUNT(ncid) / (SELECT COUNT(ncid) FROM absentee WHERE ballot_req_type = "MAIL" AND ballot_rtn_dt <> ''))) * 100), 1) as pct
FROM absentee
WHERE ballot_req_type = 'MAIL'
AND ballot_rtn_dt <> ''
GROUP BY ballot_rtn_status
ORDER BY count DESC;

#breakdown by race for mail-in ballots, by raw numbers
#removing ballots never received by boards of elections
SELECT categories.ballot_rtn_status, white_table.white_raw, black_table.black_raw, undesig_table.undesig_raw, multi_table.multi_raw, other_table.other_raw, asian_table.asian_raw, indian_am_table.indian_am_raw
FROM (
	SELECT ballot_rtn_status
	FROM absentee
	WHERE ballot_req_type = 'MAIL'
	AND ballot_rtn_status <> ''
	GROUP BY ballot_rtn_status
	ORDER BY ballot_rtn_status
) categories
LEFT JOIN (
	SELECT ballot_rtn_status, COUNT(ballot_rtn_status) AS white_raw
	FROM absentee
	WHERE race = "WHITE"
	AND ballot_req_type = "MAIL"
	AND ballot_rtn_dt <> ''
	GROUP BY ballot_rtn_status
) AS white_table
ON categories.ballot_rtn_status = white_table.ballot_rtn_status
LEFT JOIN (
	SELECT ballot_rtn_status, COUNT(ballot_rtn_status) AS black_raw
	FROM absentee
	WHERE race = "BLACK or AFRICAN AMERICAN"
	AND ballot_req_type = "MAIL"
	AND ballot_rtn_dt <> ''
	GROUP BY ballot_rtn_status
) AS black_table
ON categories.ballot_rtn_status = black_table.ballot_rtn_status
LEFT JOIN (
	SELECT ballot_rtn_status, COUNT(ballot_rtn_status) AS undesig_raw
	FROM absentee
	WHERE race = "UNDESIGNATED"
	AND ballot_req_type = "MAIL"
	AND ballot_rtn_dt <> ''
	GROUP BY ballot_rtn_status
) AS undesig_table
ON categories.ballot_rtn_status = undesig_table.ballot_rtn_status
LEFT JOIN (
	SELECT ballot_rtn_status, COUNT(ballot_rtn_status) AS multi_raw
	FROM absentee
	WHERE race = "TWO or MORE RACES"
	AND ballot_req_type = "MAIL"
	AND ballot_rtn_dt <> ''
	GROUP BY ballot_rtn_status
) as multi_table
ON categories.ballot_rtn_status = multi_table.ballot_rtn_status
LEFT JOIN (
	SELECT ballot_rtn_status, COUNT(ballot_rtn_status) AS other_raw
	FROM absentee
	WHERE race = "OTHER"
	AND ballot_req_type = "MAIL"
	AND ballot_rtn_dt <> ''
	GROUP BY ballot_rtn_status
) AS other_table
ON categories.ballot_rtn_status = other_table.ballot_rtn_status
LEFT JOIN (
	SELECT ballot_rtn_status, COUNT(ballot_rtn_status) AS asian_raw
	FROM absentee
	WHERE race = "ASIAN"
	AND ballot_req_type = "MAIL"
	AND ballot_rtn_dt <> ''
	GROUP BY ballot_rtn_status
) as asian_table
ON categories.ballot_rtn_status = asian_table.ballot_rtn_status
LEFT JOIN (
	SELECT ballot_rtn_status, COUNT(ballot_rtn_status) AS indian_am_raw
	FROM absentee
	WHERE race = "INDIAN AMERICAN or ALASKA NATIVE"
	AND ballot_req_type = "MAIL"
	AND ballot_rtn_dt <> ''
	GROUP BY ballot_rtn_status
) AS indian_am_table
ON categories.ballot_rtn_status = indian_am_table.ballot_rtn_status
ORDER BY white_raw desc;

#breakdown by race for mail-in ballots, by percentage
#removing ballots never received by boards of elections
SELECT categories.ballot_rtn_status, white_table.white_rate, black_table.black_rate, undesig_table.undesig_rate, multi_table.multi_rate, other_table.other_rate, asian_table.asian_rate, indian_am_table.indian_am_rate
FROM (
	SELECT ballot_rtn_status
	FROM absentee
	WHERE ballot_req_type = 'MAIL'
	AND ballot_rtn_dt <> ''
	GROUP BY ballot_rtn_status
	ORDER BY ballot_rtn_status
) categories
LEFT JOIN (
	SELECT ballot_rtn_status, ROUND((((COUNT(ballot_rtn_status) / (SELECT COUNT(*) FROM absentee WHERE RACE = "WHITE" AND ballot_req_type = "MAIL" AND ballot_rtn_dt <> ''))) * 100), 2) as white_rate
	FROM absentee
	WHERE race = "WHITE"
	AND ballot_req_type = "MAIL"
	AND ballot_rtn_dt <> ''
	GROUP BY ballot_rtn_status
) AS white_table
ON categories.ballot_rtn_status = white_table.ballot_rtn_status
LEFT JOIN (
	SELECT ballot_rtn_status, ROUND((((COUNT(ballot_rtn_status) / (SELECT COUNT(*) FROM absentee WHERE race = "BLACK or AFRICAN AMERICAN" AND ballot_req_type = "MAIL" AND ballot_rtn_dt <> ''))) * 100), 2) as black_rate
	FROM absentee
	WHERE race = "BLACK or AFRICAN AMERICAN"
	AND ballot_req_type = "MAIL"
	AND ballot_rtn_dt <> ''
	GROUP BY ballot_rtn_status
) AS black_table
ON categories.ballot_rtn_status = black_table.ballot_rtn_status
LEFT JOIN (
	SELECT ballot_rtn_status, ROUND((((COUNT(ballot_rtn_status) / (SELECT COUNT(*) FROM absentee WHERE race = "UNDESIGNATED" AND ballot_req_type = "MAIL" AND ballot_rtn_dt <> ''))) * 100), 2) AS undesig_rate
	FROM absentee
	WHERE race = "UNDESIGNATED"
	AND ballot_req_type = "MAIL"
	AND ballot_rtn_dt <> ''
	GROUP BY ballot_rtn_status
) AS undesig_table
ON categories.ballot_rtn_status = undesig_table.ballot_rtn_status
LEFT JOIN (
	SELECT ballot_rtn_status, ROUND((((COUNT(ballot_rtn_status) / (SELECT COUNT(*) FROM absentee WHERE race = "TWO or MORE RACES" AND ballot_req_type = "MAIL" AND ballot_rtn_dt <> ''))) * 100), 2) as multi_rate
	FROM absentee
	WHERE race = "TWO or MORE RACES"
	AND ballot_req_type = "MAIL"
	AND ballot_rtn_dt <> ''
	GROUP BY ballot_rtn_status
) as multi_table
ON categories.ballot_rtn_status = multi_table.ballot_rtn_status
LEFT JOIN (
	SELECT ballot_rtn_status, ROUND((((COUNT(ballot_rtn_status) / (SELECT COUNT(*) FROM absentee WHERE race = "OTHER" AND ballot_req_type = "MAIL" AND ballot_rtn_dt <> ''))) * 100), 2) as other_rate
	FROM absentee
	WHERE race = "OTHER"
	AND ballot_req_type = "MAIL"
	AND ballot_rtn_dt <> ''
	GROUP BY ballot_rtn_status
) AS other_table
ON categories.ballot_rtn_status = other_table.ballot_rtn_status
LEFT JOIN (
	SELECT ballot_rtn_status, ROUND((((COUNT(ballot_rtn_status) / (SELECT COUNT(*) FROM absentee WHERE race = "ASIAN" AND ballot_req_type = "MAIL" AND ballot_rtn_dt <> ''))) * 100), 2) as asian_rate
	FROM absentee
	WHERE race = "ASIAN"
	AND ballot_req_type = "MAIL"
	AND ballot_rtn_dt <> ''
	GROUP BY ballot_rtn_status
) as asian_table
ON categories.ballot_rtn_status = asian_table.ballot_rtn_status
LEFT JOIN (
	SELECT ballot_rtn_status, ROUND((((COUNT(ballot_rtn_status) / (SELECT COUNT(*) FROM absentee WHERE race = "INDIAN AMERICAN or ALASKA NATIVE" AND ballot_req_type = "MAIL" AND ballot_rtn_dt <> ''))) * 100), 2) as indian_am_rate
	FROM absentee
	WHERE race = "INDIAN AMERICAN or ALASKA NATIVE"
	AND ballot_req_type = "MAIL"
	AND ballot_rtn_dt <> ''
	GROUP BY ballot_rtn_status
) AS indian_am_table
ON categories.ballot_rtn_status = indian_am_table.ballot_rtn_status
ORDER BY white_rate desc;

#calculate the rejection rates for white and black voters
#and find the disparity, NOT including unreceived ballots
SET @white_rec_rate = 100 - (
	SELECT ROUND((((COUNT(ballot_rtn_status) / (SELECT COUNT(*) FROM absentee WHERE RACE = "WHITE" AND ballot_req_type = "MAIL" AND ballot_rtn_dt <> ''))) * 100), 2) as white_rate
	FROM absentee
	WHERE race = "WHITE"
	AND ballot_req_type = "MAIL"
	AND ballot_rtn_dt <> ''
	AND ballot_rtn_status = 'ACCEPTED'
	GROUP BY ballot_rtn_status
);
SET @black_rec_rate = 100 - (
	SELECT ROUND((((COUNT(ballot_rtn_status) / (SELECT COUNT(*) FROM absentee WHERE race = "BLACK or AFRICAN AMERICAN" AND ballot_req_type = "MAIL" AND ballot_rtn_dt <> ''))) * 100), 2) as black_rate
	FROM absentee
	WHERE race = "BLACK or AFRICAN AMERICAN"
	AND ballot_rtn_status = 'ACCEPTED'
	AND ballot_req_type = "MAIL"
	AND ballot_rtn_dt <> ''
	GROUP BY ballot_rtn_status
);
SET @asian_rec_rate = 100 - (
	SELECT ROUND((((COUNT(ballot_rtn_status) / (SELECT COUNT(*) FROM absentee WHERE race = "ASIAN" AND ballot_req_type = "MAIL" AND ballot_rtn_dt <> ''))) * 100), 2) as black_rate
	FROM absentee
	WHERE race = "ASIAN"
	AND ballot_rtn_status = 'ACCEPTED'
	AND ballot_req_type = "MAIL"
	AND ballot_rtn_dt <> ''
	GROUP BY ballot_rtn_status
);
SET @indian_am_rec_rate = 100 - (
	SELECT ROUND((((COUNT(ballot_rtn_status) / (SELECT COUNT(*) FROM absentee WHERE race = "INDIAN AMERICAN or ALASKA NATIVE" AND ballot_req_type = "MAIL" AND ballot_rtn_dt <> ''))) * 100), 2) as black_rate
	FROM absentee
	WHERE race = "INDIAN AMERICAN or ALASKA NATIVE"
	AND ballot_rtn_status = 'ACCEPTED'
	AND ballot_req_type = "MAIL"
	AND ballot_rtn_dt <> ''
	GROUP BY ballot_rtn_status
);

SELECT ROUND(@black_rec_rate/ @white_rec_rate, 2) AS rate_ratio;
SELECT ROUND(@asian_rec_rate / @white_rec_rate, 2) AS rate_ratio;
SELECT ROUND(@indian_am_rec_rate / @white_rec_rate, 2) AS rate_ratio;

#######################################
# Analysis of voting by other methods #
#######################################

#create new table with only absentee by mail rows
CREATE TABLE absentee_mail AS
SELECT *
FROM absentee
WHERE ballot_req_type = 'MAIL';

#add a new field to count requests
ALTER TABLE absentee_mail
ADD COLUMN request_id INT FIRST;

#add an incremental update to give us a unique id
SET @i=0;
UPDATE absentee_mail
SET request_id = @i:=(@i + 1)
WHERE 1=1
ORDER BY ballot_req_dt;

#make sure all our values for request_id are indeed unique
SELECT request_id, COUNT(request_id) AS count
FROM absentee_mail
GROUP BY request_id
ORDER BY count DESC;

#create another new table of sequenced mail-in ballot
#requests based on our previous tables and ids
SET @row_number = 0;
CREATE TABLE absentee_mail_sequenced AS
SELECT absentee_mail.*, assigned_ids.request_no
FROM absentee_mail
JOIN (
	SELECT
		@row_number := CASE
			WHEN @ncid_number = ncid THEN @row_number + 1
			ELSE 1
			END AS request_no,
		@ncid_number := ncid AS ncid,
		ballot_req_dt,
		request_id
	FROM (
		SELECT *
		FROM absentee_mail
		ORDER BY ncid, ballot_req_dt
	) AS sorted
	ORDER BY request_no DESC
) AS assigned_ids
ON absentee_mail.request_id = assigned_ids.request_id
ORDER BY request_no DESC;

#move the column so we can analyze a little easier
ALTER TABLE absentee_mail_sequenced
MODIFY COLUMN request_no BIGINT AFTER ballot_rtn_status;

#check the row count for our voter history snapshot
#imported as voter_history0119
SELECT COUNT(*)
FROM voter_history0119;

#make sure we've got distinct county_id-voter_reg_num pairs
SELECT county_id, voter_reg_num
FROM voter_history0119
GROUP BY county_id, voter_reg_num;

#create an index on these fields to speed up queries
CREATE INDEX voter_history0119_idx ON
voter_history0119 (county_id, voter_reg_num);

#calculate the number of rejected, returned ballots
SELECT COUNT(*) AS COUNT
FROM absentee_mail_sequenced
WHERE ballot_rtn_status <> 'ACCEPTED'
AND ballot_rtn_dt <> '';

#calculate the number of distinct voters
#among all unaccepted ballots
SELECT COUNT(*) AS count
FROM (
	SELECT DISTINCT ncid, voter_first_name, voter_middle_name, voter_last_name
	FROM absentee_mail_sequenced
	WHERE ballot_rtn_status <> 'ACCEPTED'
	AND ballot_rtn_dt <> ''
) AS uniq_ids;

#count the number of distinct voters overall
SELECT COUNT(*) AS count
FROM (
	SELECT DISTINCT ncid, voter_first_name, voter_middle_name, voter_last_name
	FROM absentee_mail_sequenced
	WHERE ballot_rtn_dt <> ''
) AS uniq_ids;

#generate the racial breakdown of unique voters who had their
#mail-in ballots rejected at least once
SELECT rejected_demographics.race,
	rejected_demographics.count_unique AS unique_rejections,
	returned_demographics.count_unique AS unique_voters,
	ROUND( (rejected_demographics.count_unique/returned_demographics.count_unique) * 100, 2) AS pct_rejected
FROM (
	SELECT race, COUNT(race) AS count_unique
	FROM (
		SELECT deduped_ids.ncid, demographics.race
		FROM (
			SELECT DISTINCT(ncid) AS ncid
			FROM absentee_mail_sequenced
			WHERE ballot_rtn_status <> 'ACCEPTED'
			AND ballot_rtn_dt <> ''
		) AS deduped_ids
		LEFT JOIN (
			SELECT ncid, race
			FROM absentee_mail_sequenced
			WHERE request_no = 1
		) AS demographics
		ON deduped_ids.ncid = demographics.ncid
	) AS deduped_demographics
	GROUP BY race
) AS rejected_demographics
LEFT JOIN (
	SELECT race, COUNT(race) AS count_unique
	FROM (
		SELECT deduped_ids.ncid, demographics.race
		FROM (
			SELECT DISTINCT(ncid) AS ncid
			FROM absentee_mail_sequenced
			WHERE ballot_rtn_dt <> ''
		) AS deduped_ids
		LEFT JOIN (
			SELECT ncid, race
			FROM absentee_mail_sequenced
			WHERE request_no = 1
		) AS demographics
		ON deduped_ids.ncid = demographics.ncid
	) AS deduped_demographics
	GROUP BY race
) AS returned_demographics
ON rejected_demographics.race = returned_demographics.race
ORDER BY unique_rejections DESC;

#calculate the number of voters with rejected mail-in ballots
#that eventually got accepted in 2018
SELECT COUNT(ncid) AS count
FROM (
	SELECT DISTINCT(ncid) AS ncid
	FROM (
		SELECT unaccepted.*, accepted.ballot_req_dt AS acc_ballot_req_dt, accepted.ballot_send_dt AS acc_ballot_send_dt,
		accepted.ballot_rtn_dt AS acc_ballot_rtn_dt, accepted.ballot_rtn_status AS acc_ballot_rtn_status, 
		accepted.request_no AS acc_request_no
		FROM (
			SELECT *
			FROM absentee_mail_sequenced
			WHERE ballot_rtn_status <> 'ACCEPTED' AND ballot_rtn_dt <> ''
		) AS unaccepted
		INNER JOIN (
			SELECT *
			FROM absentee_mail_sequenced
			WHERE ballot_rtn_status = 'ACCEPTED'
		) as accepted
		ON unaccepted.ncid = accepted.ncid
	) AS dupe_ballots_accepted
) AS count_ids;

#generate a list of all 6383 distinct ncids from rejected, returned ballots
#and remove the 882 eventually accepted to give us the remainder of 5501
CREATE TABLE ncid_rejected_v2 AS
SELECT rejected_ids.ncid
FROM (
	SELECT DISTINCT(ncid) AS ncid
	FROM absentee_mail_sequenced
	WHERE ballot_rtn_status <> 'ACCEPTED' AND ballot_rtn_dt <> ''
) AS rejected_ids
WHERE ncid NOT IN (
	SELECT DISTINCT(ncid)
	FROM (
		SELECT unaccepted.*, accepted.ballot_req_dt AS acc_ballot_req_dt, accepted.ballot_send_dt AS acc_ballot_send_dt,
		accepted.ballot_rtn_dt AS acc_ballot_rtn_dt, accepted.ballot_rtn_status AS acc_ballot_rtn_status, 
		accepted.request_no AS acc_request_no
		FROM (
			SELECT *
			FROM absentee_mail_sequenced
			WHERE ballot_rtn_status <> 'ACCEPTED' AND ballot_rtn_dt <> ''
		) AS unaccepted
		INNER JOIN (
			SELECT *
			FROM absentee_mail_sequenced
			WHERE ballot_rtn_status= 'ACCEPTED'
		) as accepted
		ON unaccepted.ncid = accepted.ncid
	) AS dupe_ballots_accepted
);

#give it an index
CREATE INDEX ncid_rejected_v2_idx ON
ncid_rejected_v2 (ncid);

#generate the racial breakdown of unique voters who had their
#mail-in ballots ULTIMATELY rejected
SELECT rejected.*,
	total.total_voters AS race_total,
	ROUND((rejected.rejected_count/total_voters) * 100, 2) AS race_reject_rate
FROM(
	SELECT race,
		COUNT(race) AS rejected_count,
		ROUND((COUNT(ncid)/(SELECT COUNT(*) FROM eventual_voters_v2)) * 100,2) AS pct_of_rejected
	FROM (
		SELECT ncid_rejected_v2.ncid, race
		FROM ncid_rejected_v2
	LEFT JOIN absentee_mail_sequenced
		ON ncid_rejected_v2.ncid = absentee_mail_sequenced.ncid
		WHERE request_no = 1
	) AS t1
	GROUP BY race
) AS rejected
LEFT JOIN (
	SELECT race, COUNT(race) AS total_voters
	FROM (
		SELECT deduped_ids.ncid, demographics.race
		FROM (
			SELECT DISTINCT(ncid) AS ncid
			FROM absentee_mail_sequenced
			WHERE ballot_rtn_dt <> ''
		) AS deduped_ids
		LEFT JOIN (
			SELECT ncid, race
			FROM absentee_mail_sequenced
			WHERE request_no = 1
		) AS demographics
		ON deduped_ids.ncid = demographics.ncid
	) AS deduped_demographics
	GROUP BY race
) AS total
ON rejected.race = total.race
ORDER BY rejected_count DESC;

#construct a new table of rejected voters with both
#voter registration number & county to match
CREATE TABLE ncid_rejected_v3 AS
SELECT DISTINCT ncid_rejected_v2.*, county_codes.county_id, absentee_mail_sequenced.voter_reg_num
FROM ncid_rejected_v2
LEFT JOIN absentee_mail_sequenced
ON ncid_rejected_v2.ncid = absentee_mail_sequenced.ncid
LEFT JOIN county_codes
ON absentee_mail_sequenced.county_desc = county_codes.county_desc
WHERE absentee_mail_sequenced.ballot_rtn_dt <> '';

#then give it an index
CREATE INDEX ncid_rejected_v3_idx ON
ncid_rejected_v3 (county_id, voter_reg_num);

#Join our list of unaccepted, returned ballots with
#our 2018 voter history file snapshot to see how many ended up voting
CREATE TABLE eventual_voters_v3 AS
SELECT ncid_rejected_v3.ncid, ncid_rejected_v3.county_id, ncid_rejected_v3.voter_reg_num, voter_history0119.voting_method
FROM ncid_rejected_v3
LEFT JOIN voter_history0119
ON ncid_rejected_v3.county_id = voter_history0119.county_id
AND ncid_rejected_v3.voter_reg_num = voter_history0119.voter_reg_num;

#then give it an index
CREATE INDEX eventual_voters_v3_idx ON
eventual_voters_v3 (county_id, voter_reg_num);

#add in our county id column to make matching easier
ALTER TABLE absentee_mail_sequenced
ADD COLUMN county_id INT
AFTER county_desc;

UPDATE absentee_mail_sequenced
INNER JOIN county_codes
ON absentee_mail_sequenced.county_desc = county_codes.county_desc
SET absentee_mail_sequenced.county_id = county_codes.county_id;

#and give it an index
CREATE INDEX absentee_mail_sequenced_idx2 ON
absentee_mail_sequenced (county_id, voter_reg_num);

#use the new table of discrete, "uncounted" voters to find the
#out how many ulimately ended up voting through some other means.
SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
	ELSE voting_method
	END AS voting_method,
	COUNT(*) AS count,
	ROUND((COUNT(*)/(SELECT COUNT(*) FROM eventual_voters_v3)) * 100,2) AS pct
FROM (
	SELECT absentee_deduped.*, eventual_voters_v3.voting_method
	FROM eventual_voters_v3
	LEFT JOIN (
		SELECT absentee_mail_sequenced.*
		FROM (
			SELECT county_id, voter_reg_num, MIN(request_no) as min_request
			FROM absentee_mail_sequenced
			GROUP BY county_id, voter_reg_num
		) AS deduped
		INNER JOIN absentee_mail_sequenced
		ON deduped.county_id = absentee_mail_sequenced.county_id
		AND deduped.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		AND deduped.min_request = absentee_mail_sequenced.request_no
	) absentee_deduped
	ON eventual_voters_v3.county_id = absentee_deduped.county_id
	AND eventual_voters_v3.voter_reg_num = absentee_deduped.voter_reg_num
) AS mailin_history
GROUP BY voting_method
ORDER BY count desc;

#generate a breakdown of final voting method of rejected
#mail-in ballot voters by race, raw
SELECT overall_history.voting_method,
	overall_history.overall_count AS overall_count,
	white_history.white_count AS white_count,
	black_history.black_count AS black_count,
	undesig_history.undesig_count AS undesig_count,
	asian_history.asian_count AS asian_count,
	other_history.other_count AS other_count,
	indian_history.indian_count AS indian_pct,
	multi_history.multi_count AS multi_pct
FROM(
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		ELSE voting_method
		END AS voting_method,
		COUNT(ncid) AS overall_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.county_id = absentee_mail_sequenced.county_id
		AND eventual_voters_v3.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		WHERE request_no = 1
	) AS mailin_history
	GROUP BY voting_method
	ORDER BY overall_count desc
) AS overall_history
LEFT JOIN (
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		ELSE voting_method
		END AS voting_method,
		COUNT(ncid) AS white_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.county_id = absentee_mail_sequenced.county_id
		AND eventual_voters_v3.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		WHERE request_no = 1
		AND race = 'WHITE'
	) AS mailin_history
	GROUP BY voting_method
) AS white_history
ON overall_history.voting_method = white_history.voting_method
LEFT JOIN (
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		ELSE voting_method
		END AS voting_method,
		COUNT(ncid) AS black_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.county_id = absentee_mail_sequenced.county_id
		AND eventual_voters_v3.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		WHERE request_no = 1
		AND race = 'BLACK OR AFRICAN AMERICAN'
	) AS mailin_history
	GROUP BY voting_method
) AS black_history
ON overall_history.voting_method = black_history.voting_method
LEFT JOIN (
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		ELSE voting_method
		END AS voting_method,
		COUNT(ncid) AS undesig_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.county_id = absentee_mail_sequenced.county_id
		AND eventual_voters_v3.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		WHERE request_no = 1
		AND race = 'UNDESIGNATED'
	) AS mailin_history
	GROUP BY voting_method
) AS undesig_history
ON overall_history.voting_method = undesig_history.voting_method
LEFT JOIN (
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		ELSE voting_method
		END AS voting_method,
		COUNT(ncid) AS asian_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.county_id = absentee_mail_sequenced.county_id
		AND eventual_voters_v3.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		WHERE request_no = 1
		AND race = 'ASIAN'
	) AS mailin_history
	GROUP BY voting_method
) AS asian_history
ON overall_history.voting_method = asian_history.voting_method
LEFT JOIN (
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		ELSE voting_method
		END AS voting_method,
		COUNT(ncid) AS other_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.county_id = absentee_mail_sequenced.county_id
		AND eventual_voters_v3.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		WHERE request_no = 1
		AND race = 'OTHER'
	) AS mailin_history
	GROUP BY voting_method
) AS other_history
ON overall_history.voting_method = other_history.voting_method
LEFT JOIN (
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		ELSE voting_method
		END AS voting_method,
		COUNT(ncid) AS indian_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.county_id = absentee_mail_sequenced.county_id
		AND eventual_voters_v3.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		WHERE request_no = 1
		AND race = 'INDIAN AMERICAN or ALASKA NATIVE'
	) AS mailin_history
	GROUP BY voting_method
) AS indian_history
ON overall_history.voting_method = indian_history.voting_method
LEFT JOIN (
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		ELSE voting_method
		END AS voting_method,
		COUNT(ncid) AS multi_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.county_id = absentee_mail_sequenced.county_id
		AND eventual_voters_v3.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		WHERE request_no = 1
		AND race = 'TWO or MORE RACES'
	) AS mailin_history
	GROUP BY voting_method
) AS multi_history
ON overall_history.voting_method = multi_history.voting_method;

#generate a breakdown of final voting method of rejected
#mail-in ballot voters by race, as a percentage
SELECT overall_history.voting_method,
	ROUND((overall_history.overall_count/(SELECT COUNT(*) FROM eventual_voters_v3)) * 100,2) AS overall_pct,
	ROUND((white_history.white_count/(
	SELECT COUNT(*) FROM (
		SELECT eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.county_id = absentee_mail_sequenced.county_id
		AND eventual_voters_v3.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		WHERE request_no = 1
		AND race = 'WHITE'
	) AS white_denom
	)) * 100, 2) AS white_pct,
	ROUND((black_history.black_count/(
	SELECT COUNT(*) FROM (
		SELECT eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.county_id = absentee_mail_sequenced.county_id
		AND eventual_voters_v3.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		WHERE request_no = 1
		AND race = 'BLACK OR AFRICAN AMERICAN'
	) AS black_denom
	)) * 100, 2) AS black_pct,
	ROUND((undesig_history.undesig_count/(
	SELECT COUNT(*) FROM (
		SELECT eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.county_id = absentee_mail_sequenced.county_id
		AND eventual_voters_v3.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		WHERE request_no = 1
		AND race = 'UNDESIGNATED'
	) AS undesig_denom
	)) * 100, 2) AS undesig_pct,
	ROUND((asian_history.asian_count/(
	SELECT COUNT(*) FROM (
		SELECT eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.county_id = absentee_mail_sequenced.county_id
		AND eventual_voters_v3.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		WHERE request_no = 1
		AND race = 'ASIAN'
	) AS asian_denom
	)) * 100, 2) AS asian_pct,
	ROUND((other_history.other_count/(
	SELECT COUNT(*) FROM (
		SELECT eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.county_id = absentee_mail_sequenced.county_id
		AND eventual_voters_v3.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		WHERE request_no = 1
		AND race = 'OTHER'
	) AS other_denom
	)) * 100, 2) AS other_pct,
	ROUND((indian_history.indian_count/(
	SELECT COUNT(*) FROM (
		SELECT eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.county_id = absentee_mail_sequenced.county_id
		AND eventual_voters_v3.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		WHERE request_no = 1
		AND race = 'INDIAN AMERICAN or ALASKA NATIVE'
	) AS indian_denom
	)) * 100, 2) AS indian_pct,
	ROUND((multi_history.multi_count/(
	SELECT COUNT(*) FROM (
		SELECT eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.county_id = absentee_mail_sequenced.county_id
		AND eventual_voters_v3.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		WHERE request_no = 1
		AND race = 'TWO or MORE RACES'
	) AS multi_denom
	)) * 100, 2) AS multi_pct
FROM(
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		ELSE voting_method
		END AS voting_method,
		COUNT(ncid) AS overall_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.county_id = absentee_mail_sequenced.county_id
		AND eventual_voters_v3.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		WHERE request_no = 1
	) AS mailin_history
	GROUP BY voting_method
	ORDER BY overall_count desc
) AS overall_history
LEFT JOIN (
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		ELSE voting_method
		END AS voting_method,
		COUNT(ncid) AS white_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.county_id = absentee_mail_sequenced.county_id
		AND eventual_voters_v3.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		WHERE request_no = 1
		AND race = 'WHITE'
	) AS mailin_history
	GROUP BY voting_method
) AS white_history
ON overall_history.voting_method = white_history.voting_method
LEFT JOIN (
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		ELSE voting_method
		END AS voting_method,
		COUNT(ncid) AS black_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.county_id = absentee_mail_sequenced.county_id
		AND eventual_voters_v3.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		WHERE request_no = 1
		AND race = 'BLACK OR AFRICAN AMERICAN'
	) AS mailin_history
	GROUP BY voting_method
) AS black_history
ON overall_history.voting_method = black_history.voting_method
LEFT JOIN (
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		ELSE voting_method
		END AS voting_method,
		COUNT(ncid) AS undesig_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.county_id = absentee_mail_sequenced.county_id
		AND eventual_voters_v3.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		WHERE request_no = 1
		AND race = 'UNDESIGNATED'
	) AS mailin_history
	GROUP BY voting_method
) AS undesig_history
ON overall_history.voting_method = undesig_history.voting_method
LEFT JOIN (
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		ELSE voting_method
		END AS voting_method,
		COUNT(ncid) AS asian_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.county_id = absentee_mail_sequenced.county_id
		AND eventual_voters_v3.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		WHERE request_no = 1
		AND race = 'ASIAN'
	) AS mailin_history
	GROUP BY voting_method
) AS asian_history
ON overall_history.voting_method = asian_history.voting_method
LEFT JOIN (
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		ELSE voting_method
		END AS voting_method,
		COUNT(ncid) AS other_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.county_id = absentee_mail_sequenced.county_id
		AND eventual_voters_v3.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		WHERE request_no = 1
		AND race = 'OTHER'
	) AS mailin_history
	GROUP BY voting_method
) AS other_history
ON overall_history.voting_method = other_history.voting_method
LEFT JOIN (
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		ELSE voting_method
		END AS voting_method,
		COUNT(ncid) AS indian_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.county_id = absentee_mail_sequenced.county_id
		AND eventual_voters_v3.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		WHERE request_no = 1
		AND race = 'INDIAN AMERICAN or ALASKA NATIVE'
	) AS mailin_history
	GROUP BY voting_method
) AS indian_history
ON overall_history.voting_method = indian_history.voting_method
LEFT JOIN (
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		ELSE voting_method
		END AS voting_method,
		COUNT(ncid) AS multi_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.county_id = absentee_mail_sequenced.county_id
		AND eventual_voters_v3.voter_reg_num = absentee_mail_sequenced.voter_reg_num
		WHERE request_no = 1
		AND race = 'TWO or MORE RACES'
	) AS mailin_history
	GROUP BY voting_method
) AS multi_history
ON overall_history.voting_method = multi_history.voting_method;

#see how these figures compare with the total number of mail-in ballots cast,
#broken down by racial group
SELECT overall_history.status,
	ROUND((overall_history.overall_count/ (
		SELECT COUNT(*)
		FROM (
			SELECT deduped_ids.county_id, deduped_ids.voter_reg_num, demographics.race
			FROM (
				SELECT DISTINCT county_id, voter_reg_num
				FROM absentee_mail_sequenced
				WHERE ballot_rtn_dt <> ''
			) AS deduped_ids
			LEFT JOIN (
				SELECT county_id, voter_reg_num, race
				FROM absentee_mail_sequenced
				WHERE request_no = 1
			) AS demographics
			ON deduped_ids.county_id = demographics.county_id
			AND deduped_ids.voter_reg_num = demographics.voter_reg_num
		) AS deduped_demographics
	)) * 100,2) AS overall_pct,
	ROUND((white_history.white_count/ (
		SELECT COUNT(race) AS count_unique
		FROM (
			SELECT deduped_ids.county_id, deduped_ids.voter_reg_num, demographics.race
			FROM (
				SELECT DISTINCT county_id, voter_reg_num
				FROM absentee_mail_sequenced
				WHERE ballot_rtn_dt <> ''
			) AS deduped_ids
			LEFT JOIN (
				SELECT county_id, voter_reg_num, race
				FROM absentee_mail_sequenced
				WHERE request_no = 1
			) AS demographics
			ON deduped_ids.county_id = demographics.county_id
			AND deduped_ids.voter_reg_num = demographics.voter_reg_num
		) AS deduped_demographics
		GROUP BY race
		HAVING race = 'WHITE'
	)) * 100,2) AS white_pct,
	ROUND((black_history.black_count/ (
		SELECT COUNT(race) AS count_unique
		FROM (
			SELECT deduped_ids.county_id, deduped_ids.voter_reg_num, demographics.race
			FROM (
				SELECT DISTINCT county_id, voter_reg_num
				FROM absentee_mail_sequenced
				WHERE ballot_rtn_dt <> ''
			) AS deduped_ids
			LEFT JOIN (
				SELECT county_id, voter_reg_num, race
				FROM absentee_mail_sequenced
				WHERE request_no = 1
			) AS demographics
			ON deduped_ids.county_id = demographics.county_id
			AND deduped_ids.voter_reg_num = demographics.voter_reg_num
		) AS deduped_demographics
		GROUP BY race
		HAVING race = 'BLACK OR AFRICAN AMERICAN'
	)) * 100,2) AS black_pct,
	ROUND((undesig_history.undesig_count/ (
		SELECT COUNT(race) AS count_unique
		FROM (
			SELECT deduped_ids.county_id, deduped_ids.voter_reg_num, demographics.race
			FROM (
				SELECT DISTINCT county_id, voter_reg_num
				FROM absentee_mail_sequenced
				WHERE ballot_rtn_dt <> ''
			) AS deduped_ids
			LEFT JOIN (
				SELECT county_id, voter_reg_num, race
				FROM absentee_mail_sequenced
				WHERE request_no = 1
			) AS demographics
			ON deduped_ids.county_id = demographics.county_id
			AND deduped_ids.voter_reg_num = demographics.voter_reg_num
		) AS deduped_demographics
		GROUP BY race
		HAVING race = 'UNDESIGNATED'
	)) * 100,2) AS undesig_pct,
	ROUND((asian_history.asian_count/ (
		SELECT COUNT(race) AS count_unique
		FROM (
			SELECT deduped_ids.county_id, deduped_ids.voter_reg_num, demographics.race
			FROM (
				SELECT DISTINCT county_id, voter_reg_num
				FROM absentee_mail_sequenced
				WHERE ballot_rtn_dt <> ''
			) AS deduped_ids
			LEFT JOIN (
				SELECT county_id, voter_reg_num, race
				FROM absentee_mail_sequenced
				WHERE request_no = 1
			) AS demographics
			ON deduped_ids.county_id = demographics.county_id
			AND deduped_ids.voter_reg_num = demographics.voter_reg_num
		) AS deduped_demographics
		GROUP BY race
		HAVING race = 'ASIAN'
	)) * 100,2) AS asian_pct,
	ROUND((other_history.other_count/ (
		SELECT COUNT(race) AS count_unique
		FROM (
			SELECT deduped_ids.county_id, deduped_ids.voter_reg_num, demographics.race
			FROM (
				SELECT DISTINCT county_id, voter_reg_num
				FROM absentee_mail_sequenced
				WHERE ballot_rtn_dt <> ''
			) AS deduped_ids
			LEFT JOIN (
				SELECT county_id, voter_reg_num, race
				FROM absentee_mail_sequenced
				WHERE request_no = 1
			) AS demographics
			ON deduped_ids.county_id = demographics.county_id
			AND deduped_ids.voter_reg_num = demographics.voter_reg_num
		) AS deduped_demographics
		GROUP BY race
		HAVING race = 'OTHER'
	)) * 100,2) AS other_pct,
	ROUND((indian_history.indian_count/ (
		SELECT COUNT(race) AS count_unique
		FROM (
			SELECT deduped_ids.county_id, deduped_ids.voter_reg_num, demographics.race
			FROM (
				SELECT DISTINCT county_id, voter_reg_num
				FROM absentee_mail_sequenced
				WHERE ballot_rtn_dt <> ''
			) AS deduped_ids
			LEFT JOIN (
				SELECT county_id, voter_reg_num, race
				FROM absentee_mail_sequenced
				WHERE request_no = 1
			) AS demographics
			ON deduped_ids.county_id = demographics.county_id
			AND deduped_ids.voter_reg_num = demographics.voter_reg_num
		) AS deduped_demographics
		GROUP BY race
		HAVING race = 'INDIAN AMERICAN OR ALASKA NATIVE'
	)) * 100,2) AS indian_pct,
	ROUND((multi_history.multi_count/ (
		SELECT COUNT(race) AS count_unique
		FROM (
			SELECT deduped_ids.county_id, deduped_ids.voter_reg_num, demographics.race
			FROM (
				SELECT DISTINCT county_id, voter_reg_num
				FROM absentee_mail_sequenced
				WHERE ballot_rtn_dt <> ''
			) AS deduped_ids
			LEFT JOIN (
				SELECT county_id, voter_reg_num, race
				FROM absentee_mail_sequenced
				WHERE request_no = 1
			) AS demographics
			ON deduped_ids.county_id = demographics.county_id
			AND deduped_ids.voter_reg_num = demographics.voter_reg_num
		) AS deduped_demographics
		GROUP BY race
		HAVING race = 'TWO OR MORE RACES'
	)) * 100,2) AS multi_pct
FROM(
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		END AS status,
		COUNT(ncid) AS overall_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.ncid = absentee_mail_sequenced.ncid
		WHERE request_no = 1
	) AS mailin_history
	GROUP BY status
	ORDER BY overall_count desc
) AS overall_history
LEFT JOIN (
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		END AS status,
		COUNT(ncid) AS white_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.ncid = absentee_mail_sequenced.ncid
		WHERE request_no = 1
		AND race = 'WHITE'
	) AS mailin_history
	GROUP BY status
) AS white_history
ON overall_history.status = white_history.status
LEFT JOIN (
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		END AS status,
		COUNT(ncid) AS black_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.ncid = absentee_mail_sequenced.ncid
		WHERE request_no = 1
		AND race = 'BLACK OR AFRICAN AMERICAN'
	) AS mailin_history
	GROUP BY status
) AS black_history
ON overall_history.status = black_history.status
LEFT JOIN (
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		END AS status,
		COUNT(ncid) AS undesig_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.ncid = absentee_mail_sequenced.ncid
		WHERE request_no = 1
		AND race = 'UNDESIGNATED'
	) AS mailin_history
	GROUP BY status
) AS undesig_history
ON overall_history.status = undesig_history.status
LEFT JOIN (
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		END AS status,
		COUNT(ncid) AS asian_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.ncid = absentee_mail_sequenced.ncid
		WHERE request_no = 1
		AND race = 'ASIAN'
	) AS mailin_history
	GROUP BY status
) AS asian_history
ON overall_history.status = asian_history.status
LEFT JOIN (
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		END AS status,
		COUNT(ncid) AS other_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.ncid = absentee_mail_sequenced.ncid
		WHERE request_no = 1
		AND race = 'OTHER'
	) AS mailin_history
	GROUP BY status
) AS other_history
ON overall_history.status = other_history.status
LEFT JOIN (
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		END AS status,
		COUNT(ncid) AS indian_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.ncid = absentee_mail_sequenced.ncid
		WHERE request_no = 1
		AND race = 'INDIAN AMERICAN or ALASKA NATIVE'
	) AS mailin_history
	GROUP BY status
) AS indian_history
ON overall_history.status = indian_history.status
LEFT JOIN (
	SELECT CASE WHEN voting_method IS NULL THEN 'UNCOUNTED'
		END AS status,
		COUNT(ncid) AS multi_count
	FROM (
		SELECT absentee_mail_sequenced.*, eventual_voters_v3.voting_method
		FROM eventual_voters_v3
		LEFT JOIN absentee_mail_sequenced
		ON eventual_voters_v3.ncid = absentee_mail_sequenced.ncid
		WHERE request_no = 1
		AND race = 'TWO or MORE RACES'
	) AS mailin_history
	GROUP BY status
) AS multi_history
ON overall_history.status = multi_history.status;

#########################
# County-level analysis #
#########################

#calculate the ballot acceptance rate count by county, by race
#only for returned ballots, by percentage
SELECT overall.county_desc AS county,
overall.accept_overall,
white.accept_white,
black.accept_black,
undesig.accept_undesig,
multi.accept_multi,
other.accept_other,
asian.accept_asian,
indian_am.accept_indian_am
FROM (
	SELECT total.county_desc,
	ROUND((accepted.accepted/total.total)*100,1) AS accept_overall
	FROM (
		SELECT county_desc, 
			COUNT(county_desc) AS total
		FROM absentee
		WHERE ballot_req_type = 'MAIL'
		AND ballot_rtn_dt <> ''
		GROUP BY county_desc
	) AS total
	JOIN (
		SELECT county_desc, 
			COUNT(county_desc) AS accepted
		FROM absentee
		WHERE ballot_req_type = 'MAIL'
		AND ballot_rtn_status = 'ACCEPTED'
		GROUP BY county_desc
	) AS accepted
ON total.county_desc = accepted.county_desc
) AS overall
LEFT JOIN (
	SELECT total.county_desc,
	ROUND((accepted.accepted/total.total)*100,1) AS accept_white
	FROM (
		SELECT county_desc, 
			COUNT(county_desc) AS total
		FROM absentee
		WHERE ballot_req_type = 'MAIL'
		AND ballot_rtn_dt <> ''
		AND race = "WHITE"
		GROUP BY county_desc
	) AS total
	JOIN (
		SELECT county_desc, 
			COUNT(county_desc) AS accepted
		FROM absentee
		WHERE ballot_req_type = 'MAIL'
		AND ballot_rtn_status = 'ACCEPTED'
		AND race = "WHITE"
		GROUP BY county_desc
	) AS accepted
	ON total.county_desc = accepted.county_desc
) as white
ON overall.county_desc = white.county_desc
LEFT JOIN (
	SELECT total.county_desc,
	ROUND((accepted.accepted/total.total)*100,1) AS accept_black
	FROM (
		SELECT county_desc, 
			COUNT(county_desc) AS total
		FROM absentee
		WHERE ballot_req_type = 'MAIL'
		AND ballot_rtn_dt <> ''
		AND race = "BLACK OR AFRICAN AMERICAN"
		GROUP BY county_desc
	) AS total
	JOIN (
		SELECT county_desc, 
			COUNT(county_desc) AS accepted
		FROM absentee
		WHERE ballot_req_type = 'MAIL'
		AND ballot_rtn_status = 'ACCEPTED'
		AND race = "BLACK OR AFRICAN AMERICAN"
		GROUP BY county_desc
	) AS accepted
	ON total.county_desc = accepted.county_desc
) as black
ON overall.county_desc = black.county_desc
LEFT JOIN (
	SELECT total.county_desc,
	ROUND((accepted.accepted/total.total)*100,1) AS accept_undesig
	FROM (
		SELECT county_desc, 
			COUNT(county_desc) AS total
		FROM absentee
		WHERE ballot_req_type = 'MAIL'
		AND ballot_rtn_dt <> ''
		AND race = "UNDESIGNATED"
		GROUP BY county_desc
	) AS total
	JOIN (
		SELECT county_desc, 
			COUNT(county_desc) AS accepted
		FROM absentee
		WHERE ballot_req_type = 'MAIL'
		AND ballot_rtn_status = 'ACCEPTED'
		AND race = "UNDESIGNATED"
		GROUP BY county_desc
	) AS accepted
	ON total.county_desc = accepted.county_desc
) as undesig
ON overall.county_desc = undesig.county_desc
LEFT JOIN (
	SELECT total.county_desc,
	ROUND((accepted.accepted/total.total)*100,1) AS accept_multi
	FROM (
		SELECT county_desc, 
			COUNT(county_desc) AS total
		FROM absentee
		WHERE ballot_req_type = 'MAIL'
		AND ballot_rtn_dt <> ''
		AND race = "TWO or MORE RACES"
		GROUP BY county_desc
	) AS total
	JOIN (
		SELECT county_desc, 
			COUNT(county_desc) AS accepted
		FROM absentee
		WHERE ballot_req_type = 'MAIL'
		AND ballot_rtn_status = 'ACCEPTED'
		AND race = "TWO or MORE RACES"
		GROUP BY county_desc
	) AS accepted
	ON total.county_desc = accepted.county_desc
) as multi
ON overall.county_desc = multi.county_desc
LEFT JOIN (
	SELECT total.county_desc,
	ROUND((accepted.accepted/total.total)*100,1) AS accept_other
	FROM (
		SELECT county_desc, 
			COUNT(county_desc) AS total
		FROM absentee
		WHERE ballot_req_type = 'MAIL'
		AND ballot_rtn_dt <> ''
		AND race = "OTHER"
		GROUP BY county_desc
	) AS total
	JOIN (
		SELECT county_desc, 
			COUNT(county_desc) AS accepted
		FROM absentee
		WHERE ballot_req_type = 'MAIL'
		AND ballot_rtn_status = 'ACCEPTED'
		AND race = "OTHER"
		GROUP BY county_desc
	) AS accepted
	ON total.county_desc = accepted.county_desc
) as other
ON overall.county_desc = other.county_desc
LEFT JOIN (
	SELECT total.county_desc,
	ROUND((accepted.accepted/total.total)*100,1) AS accept_asian
	FROM (
		SELECT county_desc, 
			COUNT(county_desc) AS total
		FROM absentee
		WHERE ballot_req_type = 'MAIL'
		AND ballot_rtn_dt <> ''
		AND race = "ASIAN"
		GROUP BY county_desc
	) AS total
	JOIN (
		SELECT county_desc, 
			COUNT(county_desc) AS accepted
		FROM absentee
		WHERE ballot_req_type = 'MAIL'
		AND ballot_rtn_status = 'ACCEPTED'
		AND race = "ASIAN"
		GROUP BY county_desc
	) AS accepted
	ON total.county_desc = accepted.county_desc
) as asian
ON overall.county_desc = asian.county_desc
LEFT JOIN (
	SELECT total.county_desc,
	ROUND((accepted.accepted/total.total)*100,1) AS accept_indian_am
	FROM (
		SELECT county_desc, 
			COUNT(county_desc) AS total
		FROM absentee
		WHERE ballot_req_type = 'MAIL'
		AND ballot_rtn_dt <> ''
		AND race = "INDIAN AMERICAN or ALASKA NATIVE"
		GROUP BY county_desc
	) AS total
	JOIN (
		SELECT county_desc, 
			COUNT(county_desc) AS accepted
		FROM absentee
		WHERE ballot_req_type = 'MAIL'
		AND ballot_rtn_status = 'ACCEPTED'
		AND race = "INDIAN AMERICAN or ALASKA NATIVE"
		GROUP BY county_desc
	) AS accepted
	ON total.county_desc = accepted.county_desc
) as indian_am
ON overall.county_desc = indian_am.county_desc
ORDER BY accept_overall;

#calculate the ballot acceptance rate count by county, by race
#for returned ballots, looking specifically at white/black disparities
SELECT overall.county_desc AS county,
overall.accepted_ballots_overall,
overall.total_ballots_overall,
overall.accept_overall,
white.accepted_ballots_white,
white.total_ballots_white,
white.accept_white,
black.accepted_ballots_black,
black.total_ballots_black,
black.accept_black
FROM (
	SELECT total.county_desc,
	ROUND((accepted.accepted/total.total)*100,1) AS accept_overall,
	accepted.accepted AS accepted_ballots_overall,
	total.total AS total_ballots_overall
	FROM (
		SELECT county_desc, 
			COUNT(county_desc) AS total
		FROM absentee
		WHERE ballot_req_type = 'MAIL'
		AND ballot_rtn_dt <> ''
		GROUP BY county_desc
	) AS total
	JOIN (
		SELECT county_desc, 
			COUNT(county_desc) AS accepted
		FROM absentee
		WHERE ballot_req_type = 'MAIL'
		AND ballot_rtn_status = 'ACCEPTED'
		GROUP BY county_desc
	) AS accepted
ON total.county_desc = accepted.county_desc
) AS overall
LEFT JOIN (
	SELECT total.county_desc,
	ROUND((accepted.accepted/total.total)*100,1) AS accept_white,
	accepted.accepted AS accepted_ballots_white,
	total.total AS total_ballots_white
	FROM (
		SELECT county_desc, 
			COUNT(county_desc) AS total
		FROM absentee
		WHERE ballot_req_type = 'MAIL'
		AND ballot_rtn_dt <> ''
		AND race = "WHITE"
		GROUP BY county_desc
	) AS total
	JOIN (
		SELECT county_desc, 
			COUNT(county_desc) AS accepted
		FROM absentee
		WHERE ballot_req_type = 'MAIL'
		AND ballot_rtn_status = 'ACCEPTED'
		AND race = "WHITE"
		GROUP BY county_desc
	) AS accepted
	ON total.county_desc = accepted.county_desc
) as white
ON overall.county_desc = white.county_desc
LEFT JOIN (
	SELECT total.county_desc,
	ROUND((accepted.accepted/total.total)*100,1) AS accept_black,
	accepted.accepted AS accepted_ballots_black,
	total.total AS total_ballots_black
	FROM (
		SELECT county_desc, 
			COUNT(county_desc) AS total
		FROM absentee
		WHERE ballot_req_type = 'MAIL'
		AND ballot_rtn_dt <> ''
		AND race = "BLACK OR AFRICAN AMERICAN"
		GROUP BY county_desc
	) AS total
	JOIN (
		SELECT county_desc, 
			COUNT(county_desc) AS accepted
		FROM absentee
		WHERE ballot_req_type = 'MAIL'
		AND ballot_rtn_status = 'ACCEPTED'
		AND race = "BLACK OR AFRICAN AMERICAN"
		GROUP BY county_desc
	) AS accepted
	ON total.county_desc = accepted.county_desc
) as black
ON overall.county_desc = black.county_desc
ORDER BY total_ballots_black DESC;
