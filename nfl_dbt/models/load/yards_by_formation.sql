-- Looks at the average total yards by offensive formation and receiver alignment
-- Good target for linear regression
SELECT offenseFormation, defensiveFormation, receiverAlignment, avg(yardsGained)
  FROM silver.plays_agg
  GROUP BY offenseFormation, defensiveFormation, receiverAlignment
  ORDER BY avg(yardsGained) DESC