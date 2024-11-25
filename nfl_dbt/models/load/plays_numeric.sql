-- Worth considering, for future changes: group positive/negative outcomes as ordinal (high/low), for better interpretability
SELECT gameId, playId, possessionTeam,
    CASE 
    WHEN offenseFormation LIKE '%JUMBO%' THEN 1
    WHEN offenseFormation LIKE '%WILDCAT%' THEN 2
    WHEN offenseFormation LIKE '%EMPTY%' THEN 3
    WHEN offenseFormation LIKE '%PISTOL%' THEN 4
    WHEN offenseFormation LIKE '%I_FORM%' THEN 5
    WHEN offenseFormation LIKE '%SHOTGUN%' THEN 6
    WHEN offenseFormation LIKE '%SINGLEBACK%' THEN 7
    WHEN offenseFormation LIKE '%NA%' THEN 0
    END AS offenseFormation,
    CASE
        WHEN receiverAlignment LIKE '%1x0%' THEN 1
        WHEN receiverAlignment LIKE '%1x1%' THEN 2
        WHEN receiverAlignment LIKE '%2x0%' THEN 3
        WHEN receiverAlignment LIKE '%2x1%' THEN 4
        WHEN receiverAlignment LIKE '%2x2%' THEN 5
        WHEN receiverAlignment LIKE '%3x0%' THEN 6
        WHEN receiverAlignment LIKE '%3x1%' THEN 7
        WHEN receiverAlignment LIKE '%3x2%' THEN 8
        WHEN receiverAlignment LIKE '%3x3%' THEN 9
        WHEN receiverAlignment LIKE '%4x1%' THEN 10
        WHEN receiverAlignment LIKE '%4x2%' THEN 11
        WHEN receiverAlignment LIKE '%NA%' THEN 0
        END AS receiverAlignment,
    CASE
        WHEN playType LIKE '%Rush%' THEN 1
        WHEN playType LIKE '%Pass%' THEN 2
        END AS playType,
    CASE 
        WHEN defensiveFormation = 'Cover-0' THEN 1
        WHEN defensiveFormation = '2-Man' THEN 2
        WHEN defensiveFormation = 'Cover-1' THEN 3
        WHEN defensiveFormation = 'Cover-1 Double' THEN 4
        WHEN defensiveFormation = 'Cover-2' THEN 5
        WHEN defensiveFormation = 'Cover-3' THEN 6
        WHEN defensiveFormation = 'Cover-3 Seam' THEN 7
        WHEN defensiveFormation = 'Cover-3 Cloud Left' THEN 8
        WHEN defensiveFormation = 'Cover-3 Cloud Right' THEN 9
        WHEN defensiveFormation = 'Cover-3 Double Cloud' THEN 10
        WHEN defensiveFormation = 'Cover-6 Right' THEN 11
        WHEN defensiveFormation = 'Cover 6-Left' THEN 12
        WHEN defensiveFormation = 'Quarters' THEN 13
        WHEN defensiveFormation = 'Bracket' THEN 14
        WHEN defensiveFormation = 'Prevent' THEN 15
        WHEN defensiveFormation = 'Red Zone' THEN 16
        WHEN defensiveFormation = 'Goal Line' THEN 17
        WHEN defensiveFormation = 'Miscellaneous' THEN 18
        WHEN defensiveFormation = 'NA' THEN 19
        END AS defensiveFormation,
    CASE
        WHEN pff_manZone LIKE '%Man%' THEN 1
        WHEN pff_manZone LIKE '%Zone%' THEN 2
        WHEN pff_manZone LIKE '%NA%' THEN 3
        WHEN pff_manZone LIKE '%Other%' THEN 4
        END AS pff_manZone,
    yardsGained,
    CASE
        WHEN playOutcome LIKE '%Gain%' THEN 1
        WHEN playOutcome LIKE '%Loss%' THEN 2
        WHEN playOutcome LIKE '%Complete%' THEN 3
        WHEN playOutcome LIKE '%Incomplete%' THEN 4
        WHEN playOutcome LIKE '%Scrambled%' THEN 5
        WHEN playOutcome LIKE '%Touchdown%' THEN 6
        WHEN playOutcome LIKE '%Intercepted%' THEN 7
        WHEN playOutcome LIKE '%Fumbled%' THEN 8
        WHEN playOutcome LIKE '%Sacked%' THEN 9
        WHEN playOutcome LIKE '%Penalty%' THEN 0
        END AS playOutcome
FROM silver.plays_agg