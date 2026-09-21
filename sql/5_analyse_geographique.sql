-- =====================================================
-- 05 — Répartition géographique et mix de canaux
-- ===================================================== 

-- USE AdventureWorks2022;
-- GO

SELECT    
        st.[Group]                                       AS zone,    
        st.Name                                          AS territoire,
        st.CountryRegionCode                             AS pays,    
        COUNT(DISTINCT soh.SalesOrderID)                 AS nb_commandes,    
        COUNT(DISTINCT soh.CustomerID)                   AS nb_clients,   
        CAST(SUM(soh.TotalDue) AS DECIMAL(18,2))         AS ca,    
        CAST(AVG(soh.TotalDue) AS DECIMAL(18,2))         AS panier_moyen,
        CAST(        
            100.0 * SUM(CASE WHEN soh.OnlineOrderFlag = 1 THEN soh.TotalDue ELSE 0 END)       
             / NULLIF(SUM(soh.TotalDue), 0)    
        AS DECIMAL(6,2))                                 AS part_vente_en_ligne_pct 
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesTerritory st ON st.TerritoryID = soh.TerritoryID
GROUP BY st.[Group], st.Name, st.CountryRegionCode
ORDER BY ca DESC;