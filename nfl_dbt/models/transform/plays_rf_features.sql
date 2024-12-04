WITH playsConverted AS (
    SELECT 
        quarter, 
        down, 
        yardsToGo, 
        yardlineNumber, 
        preSnapHomeScore, 
        preSnapVisitorScore,
        CASE WHEN playNullifiedByPenalty = 'Y' THEN CAST(1 AS DECIMAL) ELSE CAST(0 AS DECIMAL) END AS playNullifiedByPenalty,
        absoluteYardlineNumber, 
        preSnapHomeTeamWinProbability, 
        preSnapVisitorTeamWinProbability,
        expectedPoints,
        CASE WHEN passResult = 'C' THEN CAST(1 AS DECIMAL) ELSE CAST(0 AS DECIMAL) END AS passResult_complete,
        CASE WHEN passResult = 'I' THEN CAST(1 AS DECIMAL) ELSE CAST(0 AS DECIMAL) END AS passResult_incomplete,
        CASE WHEN passResult = 'S' THEN CAST(1 AS DECIMAL) ELSE CAST(0 AS DECIMAL) END AS passResult_sack,
        CASE WHEN passResult = 'IN' THEN CAST(1 AS DECIMAL) ELSE CAST(0 AS DECIMAL) END AS passResult_interception,
        CASE WHEN passResult = 'R' THEN CAST(1 AS DECIMAL) ELSE CAST(0 AS DECIMAL) END AS passResult_scramble,
        COALESCE(CAST(passLength AS DECIMAL), 0) AS passLength, -- Error here now
        COALESCE(CAST(targetX AS DECIMAL), 0) AS targetX,
        COALESCE(CAST(targetY AS DECIMAL), 0) AS targetY,
        CASE WHEN playAction IS NOT NULL THEN CAST(1 AS DECIMAL) ELSE CAST(0 AS DECIMAL) END AS playAction,
        CASE WHEN passTippedAtLine IS NOT NULL THEN CAST(1 AS DECIMAL) ELSE CAST(0 AS DECIMAL) END AS passTippedAtLine,
        CASE WHEN unblockedPressure IS NOT NULL THEN CAST(1 AS DECIMAL) ELSE CAST(0 AS DECIMAL) END AS unblockedPressure,
        CASE WHEN qbSpike IS NOT NULL THEN CAST(1 AS DECIMAL) ELSE CAST(0 AS DECIMAL) END AS qbSpike,
        CASE WHEN qbKneel IS NOT NULL THEN CAST(1 AS DECIMAL) ELSE CAST(0 AS DECIMAL) END AS qbKneel,
        CASE WHEN qbSneak IS NOT NULL THEN CAST(1 AS DECIMAL) ELSE CAST(0 AS DECIMAL) END AS qbSneak,
        COALESCE(CAST(penaltyYards AS DECIMAL), 0) AS penaltyYards,
        prePenaltyYardsGained, 
        homeTeamWinProbabilityAdded, 
        visitorTeamWinProbilityAdded, 
        expectedPointsAdded, 
        CASE WHEN isDropback IS NOT NULL THEN CAST(1 AS DECIMAL) ELSE CAST(0 AS DECIMAL) END AS isDropback, 
        COALESCE(CAST(timeToThrow AS DECIMAL), 0) AS timeToThrow,
        COALESCE(CAST(timeInTackleBox AS DECIMAL), 0) AS timeInTackleBox,
        COALESCE(CAST(timeToSack AS DECIMAL), 0) AS timeToSack,
        COALESCE(CAST(dropbackDistance AS DECIMAL), 0) AS dropbackDistance,
        pff_runPassOption,
        -- Replace NULL in playClockAtSnap with the average value and cast as DECIMAL, 
        CASE 
            WHEN playClockAtSnap = 'NA' OR playClockAtSnap IS NULL THEN 
                (SELECT AVG(CAST(playClockAtSnap AS DECIMAL)) 
                FROM bronze.plays 
                WHERE playClockAtSnap != 'NA' AND playClockAtSnap IS NOT NULL)
            ELSE CAST(playClockAtSnap AS DECIMAL)END AS playClockAtSnap,
        -- Replace NULL in pff_manZone with the most common value and cast as DECIMAL
        COALESCE(CAST(pff_manZone AS DECIMAL), 
        CAST((SELECT pff_manZone 
                FROM bronze.plays 
                GROUP BY pff_manZone 
                ORDER BY COUNT(*) DESC 
                LIMIT 1) AS DECIMAL)) AS pff_manZone,
        -- Convert categorical values of pff_runConceptPrimary to numbers and cast as DECIMAL
        CASE 
            WHEN pff_runConceptPrimary = 'NA' OR pff_runConceptPrimary = 'UNDEFINED' THEN CAST(0 AS DECIMAL)
            WHEN pff_runConceptPrimary = 'OUTSIDE ZONE' THEN CAST(1 AS DECIMAL)
            WHEN pff_runConceptPrimary = 'TRAP' THEN CAST(2 AS DECIMAL)
            WHEN pff_runConceptPrimary = 'COUNTER' THEN CAST(3 AS DECIMAL)
            WHEN pff_runConceptPrimary = 'DRAW' THEN CAST(4 AS DECIMAL)
            WHEN pff_runConceptPrimary = 'MAN' THEN CAST(5 AS DECIMAL)
            WHEN pff_runConceptPrimary = 'POWER' THEN CAST(6 AS DECIMAL)
            WHEN pff_runConceptPrimary = 'INSIDE ZONE' THEN CAST(7 AS DECIMAL)
            WHEN pff_runConceptPrimary = 'FB RUN' THEN CAST(8 AS DECIMAL)
            WHEN pff_runConceptPrimary = 'PULL LEAD' THEN CAST(9 AS DECIMAL)
            WHEN pff_runConceptPrimary = 'TRICK' THEN CAST(10 AS DECIMAL)
            WHEN pff_runConceptPrimary = 'SNEAK' THEN CAST(11 AS DECIMAL)
            ELSE CAST(0 AS DECIMAL) 
        END AS pff_runConceptPrimary_num,
        -- Convert categorical values of pff_passCoverage to numbers and cast as DECIMAL
        CASE 
            WHEN pff_passCoverage = 'NA' THEN CAST(0 AS DECIMAL)
            WHEN pff_passCoverage = 'Cover-3' THEN CAST(1 AS DECIMAL)
            WHEN pff_passCoverage = 'Cover-3 Cloud Right' THEN CAST(2 AS DECIMAL)
            WHEN pff_passCoverage = 'Cover-3 Seam' THEN CAST(3 AS DECIMAL)
            WHEN pff_passCoverage = 'Miscellaneous' THEN CAST(4 AS DECIMAL)
            WHEN pff_passCoverage = 'Cover-3 Cloud Left' THEN CAST(5 AS DECIMAL)
            WHEN pff_passCoverage = 'Cover-1 Double' THEN CAST(6 AS DECIMAL)
            WHEN pff_passCoverage = 'Cover-0' THEN CAST(7 AS DECIMAL)
            WHEN pff_passCoverage = 'Goal Line' THEN CAST(8 AS DECIMAL)
            WHEN pff_passCoverage = 'Bracket' THEN CAST(9 AS DECIMAL)
            WHEN pff_passCoverage = 'Cover 6-Left' THEN CAST(10 AS DECIMAL)
            WHEN pff_passCoverage = 'Prevent' THEN CAST(11 AS DECIMAL)
            WHEN pff_passCoverage = 'Cover-1' THEN CAST(12 AS DECIMAL)
            WHEN pff_passCoverage = 'Cover-3 Double Cloud' THEN CAST(13 AS DECIMAL)
            WHEN pff_passCoverage = 'Quarters' THEN CAST(14 AS DECIMAL)
            WHEN pff_passCoverage = 'Cover-6 Right' THEN CAST(15 AS DECIMAL)
            WHEN pff_passCoverage = 'Red Zone' THEN CAST(16 AS DECIMAL)
            WHEN pff_passCoverage = '2-Man' THEN CAST(17 AS DECIMAL)
            WHEN pff_passCoverage = 'Cover-2' THEN CAST(18 AS DECIMAL)
            ELSE CAST(0 AS DECIMAL)
        END AS pff_passCoverage_num,
        -- Convert pff_runConceptSecondary to numbers based on the provided mapping and cast as DECIMAL
        CASE 
            WHEN pff_runConceptSecondary = 'MISDIRECTION' THEN CAST(0 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'INVERTED;READ OPTION;SPLIT' THEN CAST(1 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'CROSS LEAD;LEAD;READ OPTION' THEN CAST(2 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'CROSS LEAD;INVERTED;READ OPTION' THEN CAST(3 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'LEAD;LEAD' THEN CAST(4 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'READ OPTION' THEN CAST(5 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'LEAD' THEN CAST(6 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'READ OPTION;SPEED OPTION;SPLIT' THEN CAST(7 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'CROSS LEAD;PITCH' THEN CAST(8 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'CROSS LEAD;READ OPTION;SPEED OPTION' THEN CAST(9 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'QB RUNS;SPLIT' THEN CAST(10 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'LEAD;PITCH;SPLIT' THEN CAST(11 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'BACKSIDE FOLD;QB RUNS' THEN CAST(12 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'CROSS LEAD;LEAD' THEN CAST(13 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'READ OPTION;SPEED OPTION' THEN CAST(14 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'LEAD;READ OPTION;SPLIT' THEN CAST(15 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'LEAD;READ OPTION' THEN CAST(16 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'INVERTED;READ OPTION;SPEED OPTION' THEN CAST(17 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'CROSS LEAD;READ OPTION;SPLIT' THEN CAST(18 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'READ OPTION;SPLIT' THEN CAST(19 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'BACKSIDE FOLD' THEN CAST(20 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'PITCH' THEN CAST(21 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'INVERTED;READ OPTION' THEN CAST(22 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'SPLIT' THEN CAST(23 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'PITCH;SPLIT' THEN CAST(24 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'SPEED OPTION' THEN CAST(25 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'CROSS LEAD;SPLIT' THEN CAST(26 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'CROSS LEAD;MISDIRECTION' THEN CAST(27 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'LEAD;PITCH' THEN CAST(28 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'LEAD;QB RUNS' THEN CAST(29 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'CROSS LEAD;QB RUNS' THEN CAST(30 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'LEAD;SPEED OPTION' THEN CAST(31 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'MISDIRECTION;SPLIT' THEN CAST(32 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'CROSS LEAD;LEAD;QB RUNS' THEN CAST(33 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'BACKSIDE FOLD;PITCH' THEN CAST(34 AS DECIMAL)
            WHEN pff_runConceptSecondary = 'NA' THEN CAST(35 AS DECIMAL)
            ELSE CAST(0 AS DECIMAL)
        END AS pff_runConceptSecondary_num,
        yardsGained
    FROM bronze.plays
)

SELECT * FROM playsConverted
