-- Looks at the average total yards by offensive formation and receiver alignment
-- Good target for linear regression
SELECT offenseFormation, receiverAlignment, avg(yardsGained)
  FROM silver.plays_agg
  GROUP BY offenseFormation, receiverAlignment
  ORDER BY avg(yardsGained) DESC