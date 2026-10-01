-- Each period runs Saturday to Sunday so it covers the travel weekends.
-- Years come from the bank holidays data, so new years appear automatically.

-- England school has 6 holidays a year 
-- 1. February half-term (1 week): Gave two anchors to avoid sunday problem. where a single anchor on a Sunday snaps a week early. 
-- 2. Easter holidays (about 2 weeks)
-- 3. May half-term (1 week)

-- 4. Summer holidays (about 6 weeks): england schools usually break up somewhere between about 18 and 24 July and return in the first week of September (around 1–5 Sept)
-- So 20 July and 31 August aren't official dates, just reference points in the middle of those ranges.

-- 5. October half-term (1 week):Gave two anchors to avoid sunday problem. The week is usually the last full week of October, starting on a Monday somewhere between about 21 and 28 October, and sometimes running into early November. 
-- I gave two reference points in the middle of that range, 21 and 28 October, and then used the week containing 28 October as the official date.

-- 6. Christmas holidays (about 2 weeks)



----------------------------------------------------------------
-- week_monday(d) finds the Monday of the week containing the specific date
-- + 6 moves to that week's Sunday, -2 moves to the previous week's Saturday.
CREATE OR REPLACE MACRO week_monday(d) AS CAST(DATE_TRUNC('week', d) AS DATE);

-- 'Good Friday', 'Easter Monday', and 'Spring bank holiday' 
-- These are the only moving holidays followed by a school holiday.
CREATE OR REPLACE TABLE dim_uk_school_holidays AS
WITH anchors AS (
    SELECT
        holiday_year,
        MAX(CASE WHEN holiday_name = 'Good Friday' THEN holiday_date END)         AS good_friday,
        MAX(CASE WHEN holiday_name = 'Easter Monday' THEN holiday_date END)       AS easter_monday,
        MAX(CASE WHEN holiday_name = 'Spring bank holiday' THEN holiday_date END) AS spring_bank_holiday
    FROM stg_bank_holidays
    WHERE holiday_year >= YEAR(CURRENT_DATE)
    GROUP BY holiday_year
),

estimates AS (
    SELECT
        holiday_year,
        '1.February half-term' AS holiday_name,
        week_monday(MAKE_DATE(holiday_year, 2, 12)) - 2 AS start_date,
        week_monday(MAKE_DATE(holiday_year, 2, 18)) + 6 AS end_date,
        'Week containing 15 Feb' AS rule
    FROM anchors

    UNION ALL
    SELECT
        holiday_year,
        '2.Easter holidays',
        good_friday - 6,
        easter_monday + 6,
        'Week before Good Friday to week after Easter Monday'
    FROM anchors
    WHERE good_friday IS NOT NULL

    UNION ALL
    SELECT
        holiday_year,
        '3.May half-term',
        spring_bank_holiday - 2,
        spring_bank_holiday + 6,
        'Week of the spring bank holiday'
    FROM anchors
    WHERE spring_bank_holiday IS NOT NULL

    UNION ALL
    SELECT
        holiday_year,
        '4.Summer holidays',
        week_monday(MAKE_DATE(holiday_year, 7, 22)) + 5,
        week_monday(MAKE_DATE(holiday_year, 8, 31)) + 6,
        'Saturday after 20 Jul to Sunday after 31 Aug'
    FROM anchors

    UNION ALL
    SELECT
        holiday_year,
        '5.October half-term',
        week_monday(MAKE_DATE(holiday_year, 10, 21)) - 2,
        week_monday(MAKE_DATE(holiday_year, 10, 28)) + 6,
        'Week containing 28 Oct'
    FROM anchors

    UNION ALL
    SELECT
        holiday_year,
        '6.Christmas holidays',
        week_monday(MAKE_DATE(holiday_year, 12, 25)) - 2,
        week_monday(MAKE_DATE(holiday_year + 1, 1, 1)) + 6,
        'Week containing Christmas Day to week containing 1 Jan'
    FROM anchors
)

SELECT
    holiday_year,
    holiday_name,
    start_date,
    end_date,
    'England' AS region,
    TRUE      AS is_estimate,
    rule
FROM estimates
ORDER BY start_date;