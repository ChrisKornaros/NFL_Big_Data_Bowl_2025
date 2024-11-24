WITH play_analysis AS (
    SELECT
        gameId,
        playId,
        possessionTeam,
        offenseFormation,
        receiverAlignment,
        -- Determine the type of play
        CASE 
            WHEN isDropback THEN 'Pass'
            WHEN rushLocationType IS NOT NULL THEN 'Rush'
            WHEN penaltyYards IS NOT NULL THEN 'Penalty'
            WHEN playDescription ILIKE '%punt%' OR playDescription ILIKE '%field goal%' THEN 'Special Teams'
            ELSE 'Unknown'
        END AS playType,
        -- Yards gained or lost
        yardsGained,
        -- Determine the outcome of the play based on the playType
        CASE
            -- Pass outcomes
            WHEN isDropback AND passResult = 'C' THEN 'Complete'
            WHEN isDropback AND passResult = 'I' THEN 'Incomplete'
            WHEN isDropback AND passResult = 'IN' THEN 'Intercepted'
            WHEN isDropback AND passResult = 'Fumbled' THEN 'Fumbled'
            WHEN isDropback AND playDescription ILIKE '%touchdown%' THEN 'Touchdown'
            -- Rush outcomes
            WHEN rushLocationType IS NOT NULL AND yardsGained > 0 THEN 'Gain'
            WHEN rushLocationType IS NOT NULL AND yardsGained < 0 THEN 'Loss'
            WHEN rushLocationType IS NOT NULL AND playDescription ILIKE '%fumble%' THEN 'Fumble'
            WHEN rushLocationType IS NOT NULL AND playDescription ILIKE '%touchdown%' THEN 'Touchdown'
            -- Special Teams outcomes
            WHEN playDescription ILIKE '%fair catch%' THEN 'Fair Catch'
            WHEN playDescription ILIKE '%returned%' THEN 'Returned'
            WHEN playDescription ILIKE '%field goal good%' THEN 'Field Goal Good'
            WHEN playDescription ILIKE '%field goal missed%' THEN 'Field Goal Missed'
            WHEN playDescription ILIKE '%blocked%' THEN 'Blocked'
            WHEN playDescription ILIKE '%touchdown%' THEN 'Touchdown'
            -- Penalty outcomes
            WHEN penaltyYards IS NOT NULL THEN 'Penalty'
            ELSE 'Unknown'
        END AS playOutcome
    FROM bronze.plays
)
SELECT 
    gameId, 
    playId, 
    possessionTeam, 
    offenseFormation, 
    receiverAlignment, 
    playType, 
    yardsGained, 
    playOutcome
FROM play_analysis

