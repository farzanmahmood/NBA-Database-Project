--1. Win % when shooting > 40% from 3 (league-wide)
SELECT ROUND(100.0 * SUM(CASE WHEN win = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS win_pct_above_40_3pt
FROM stats
WHERE fg3_pct >= 0.40;

--2. Win % when a team has more rebounds than opponent
SELECT ROUND(100.0 * SUM(CASE WHEN s.win = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS win_pct_more_rebounds
FROM stats s
JOIN stats opp ON s.game_id = opp.game_id AND s.team_id <> opp.team_id
WHERE s.reb > opp.reb;

--3. Win % when committing fewer turnovers than opponent
SELECT ROUND(100.0 * SUM(CASE WHEN s.win = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS win_pct_fewer_turnovers
FROM stats s
JOIN stats opp ON s.game_id = opp.game_id AND s.team_id <> opp.team_id
WHERE s.to < opp.to;

--4. League-wide win % when FG% > 50
SELECT ROUND(100.0 * SUM(CASE WHEN win = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS win_pct_fg_above_50
FROM stats
WHERE fg_pct > 0.50;

--5. Correlation-style table: Wins by Turnover differential
SELECT 
    CASE 
        WHEN s.to - opp.to < 0 THEN 'Fewer TOs'
        WHEN s.to - opp.to = 0 THEN 'Equal TOs'
        ELSE 'More TOs' 
    END AS turnover_diff,
    COUNT(*) AS games_played,
    SUM(CASE WHEN s.win = 1 THEN 1 ELSE 0 END) AS wins,
    ROUND(100.0 * SUM(CASE WHEN s.win = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS win_pct
FROM stats s
JOIN stats opp ON s.game_id = opp.game_id AND s.team_id <> opp.team_id
GROUP BY CASE 
        WHEN s.to - opp.to < 0 THEN 'Fewer TOs'
        WHEN s.to - opp.to = 0 THEN 'Equal TOs'
        ELSE 'More TOs' 
    END;

--6. Impact of offensive rebounds
SELECT 
    CASE WHEN s.oreb > opp.oreb THEN 'More OReb' ELSE 'Fewer/Equal OReb' END AS oreb_diff,
    COUNT(*) AS games,
    SUM(CASE WHEN s.win = 1 THEN 1 ELSE 0 END) AS wins,
    ROUND(100.0 * SUM(CASE WHEN s.win = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS win_pct
FROM stats s
JOIN stats opp ON s.game_id = opp.game_id AND s.team_id <> opp.team_id
GROUP BY CASE WHEN s.oreb > opp.oreb THEN 'More OReb' ELSE 'Fewer/Equal OReb' END;

--7. Assists vs Wins
SELECT 
    CASE WHEN s.ast > opp.ast THEN 'More AST' ELSE 'Fewer/Equal AST' END AS ast_diff,
    COUNT(*) AS games,
    SUM(CASE WHEN s.win = 1 THEN 1 ELSE 0 END) AS wins,
    ROUND(100.0 * SUM(CASE WHEN s.win = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS win_pct
FROM stats s
JOIN stats opp ON s.game_id = opp.game_id AND s.team_id <> opp.team_id
GROUP BY CASE WHEN s.ast > opp.ast THEN 'More AST' ELSE 'Fewer/Equal AST' END;

--8. Steals & Blocks combined (defensive plays or "stocks")
SELECT 
    CASE WHEN (s.stl + s.blk) > (opp.stl + opp.blk) THEN 'More STL+BLK' ELSE 'Fewer/Equal STL+BLK' END AS defense_impact,
    COUNT(*) AS games,
    SUM(CASE WHEN s.win = 1 THEN 1 ELSE 0 END) AS wins,
    ROUND(100.0 * SUM(CASE WHEN s.win = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS win_pct
FROM stats s
JOIN stats opp ON s.game_id = opp.game_id AND s.team_id <> opp.team_id
GROUP BY CASE WHEN (s.stl + s.blk) > (opp.stl + opp.blk) THEN 'More STL+BLK' ELSE 'Fewer/Equal STL+BLK' END;

--9. Free Throw Percentage impact (> 75%)
SELECT ROUND(100.0 * SUM(CASE WHEN win = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS win_pct_above_75_ft
FROM stats
WHERE ft_pct > 0.75;

--10. Win % when scoring 110+ points
SELECT ROUND(100.0 * SUM(CASE WHEN win = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS win_pct_110_plus_pts
FROM stats
WHERE pts >= 110;

--11. Impact of FGA differential
SELECT 
    CASE WHEN s.fga > opp.fga THEN 'More Shots Attempted' ELSE 'Fewer/Equal Shots Attempted' END AS fga_diff,
    COUNT(*) AS games,
    SUM(CASE WHEN s.win = 1 THEN 1 ELSE 0 END) AS wins,
    ROUND(100.0 * SUM(CASE WHEN s.win = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS win_pct
FROM stats s
JOIN stats opp ON s.game_id = opp.game_id AND s.team_id <> opp.team_id
GROUP BY CASE WHEN s.fga > opp.fga THEN 'More Shots Attempted' ELSE 'Fewer/Equal Shots Attempted' END;

--12. Plus/Minus distribution in Wins
SELECT win, ROUND(AVG(plus_minus), 2) AS avg_plus_minus
FROM stats
GROUP BY win;

--13. Home vs Away Win %
SELECT is_home, COUNT(*) AS games, SUM(CASE WHEN win = 1 THEN 1 ELSE 0 END) AS wins, ROUND(100.0 * SUM(CASE WHEN win = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS win_pct
FROM stats
GROUP BY is_home;

--14. Conference comparison of winning stats (East vs West)
SELECT t.conference, COUNT(*) AS games, SUM(CASE WHEN s.win = 1 THEN 1 ELSE 0 END) AS wins, ROUND(100.0 * SUM(CASE WHEN s.win = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS win_pct
FROM stats s
JOIN teams t ON s.team_id = t.team_id
GROUP BY t.conference;
