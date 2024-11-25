WITH offensive_play_analysis AS (
    SELECT
        gameId,
        playId,
        possessionTeam,
        yardlineNumber, -- Consider adding game clock as well eventually to see if there is any temporal relationship
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
            WHEN isDropback AND passResult = 'S' THEN 'Sacked'
            WHEN isDropback AND passResult = 'R' THEN 'Scrambled'
            WHEN isDropback AND passResult = 'Fumbled' THEN 'Fumbled'
            WHEN isDropback AND playDescription ILIKE '%touchdown%' THEN 'Touchdown'
            -- Rush outcomes
            WHEN rushLocationType IS NOT NULL AND yardsGained > 0 THEN 'Gain'
            WHEN rushLocationType IS NOT NULL AND yardsGained < 0 THEN 'Loss'
            WHEN rushLocationType IS NOT NULL AND playDescription ILIKE '%fumble%' THEN 'Fumbled'
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
),
defensive_play_analysis AS (
    SELECT
        p.gameId,
        p.playId,
        -- Determine the defensive team using the possessionTeam and join with the games table
        CASE 
            WHEN g.homeTeamAbbr = p.possessionTeam THEN g.visitorTeamAbbr
            WHEN g.visitorTeamAbbr = p.possessionTeam THEN g.homeTeamAbbr
            ELSE NULL
        END AS defensiveTeam,
        p.yardlineNumber,
        p.pff_passCoverage AS defensiveFormation,
        p.pff_manZone,
        -- Determine defensive play outcomes
        CASE
            -- Pass outcomes (same as offensive play outcomes)
            WHEN p.isDropback AND p.passResult = 'C' THEN 'Completion'
            WHEN p.isDropback AND p.passResult = 'I' THEN 'Incompletion'
            WHEN p.isDropback AND p.passResult = 'IN' THEN 'Intercepted'
            WHEN p.isDropback AND p.passResult = 'S' THEN 'Sacked'
            WHEN p.isDropback AND p.passResult = 'R' THEN 'Scrambled'
            WHEN p.isDropback AND p.passResult = 'Fumbled' THEN 'Fumbled'
            WHEN p.isDropback AND p.playDescription ILIKE '%touchdown%' THEN 'Touchdown'
            -- Rushing outcomes (custom defensive logic)
            WHEN p.rushLocationType IS NOT NULL AND p.yardsGained < 0 THEN 'Tackle For Loss'
            WHEN p.rushLocationType IS NOT NULL AND p.yardsGained > 0 THEN 'Gain'
            WHEN p.rushLocationType IS NOT NULL AND p.playDescription ILIKE '%fumble%' THEN 'Fumbled'
            WHEN p.rushLocationType IS NOT NULL AND p.playDescription ILIKE '%touchdown%' THEN 'Touchdown'
            -- Special Teams outcomes
            WHEN p.playDescription ILIKE '%fair catch%' THEN 'Fair Catch'
            WHEN p.playDescription ILIKE '%returned%' THEN 'Returned'
            WHEN p.playDescription ILIKE '%field goal good%' THEN 'Field Goal Good'
            WHEN p.playDescription ILIKE '%field goal missed%' THEN 'Field Goal Missed'
            WHEN p.playDescription ILIKE '%blocked%' THEN 'Blocked'
            WHEN p.playDescription ILIKE '%touchdown%' THEN 'Touchdown'
            -- Penalty outcomes
            WHEN p.penaltyYards IS NOT NULL THEN 'Penalty'
            -- Safety outcome
            WHEN p.playDescription ILIKE '%safety%' THEN 'Safety'
            ELSE 'Unknown'
        END AS defensivePlayOutcome
    FROM bronze.plays p
    JOIN bronze.games g
        ON p.gameId = g.gameId
)
SELECT 
    opa.gameId, 
    opa.playId, 
    opa.possessionTeam, 
    opa.offenseFormation, 
    opa.receiverAlignment, 
    opa.playType, 
    opa.yardsGained, 
    opa.playOutcome,
    dpa.defensiveTeam,
    dpa.yardlineNumber,
    dpa.defensiveFormation,
    dpa.pff_manZone,
    dpa.defensivePlayOutcome
FROM offensive_play_analysis opa
JOIN defensive_play_analysis dpa
    ON opa.gameId = dpa.gameId AND opa.playId = dpa.playId
