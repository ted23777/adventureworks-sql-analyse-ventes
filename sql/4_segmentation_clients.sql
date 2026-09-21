-- =====================================================
-- 03 — Segmentation RFM (Récence, Fréquence, Montant)
-- ===================================================== 

--USE AdventureWorks2022;
--GO

WITH date_reference AS (    
        SELECT MAX(OrderDate) AS date_ref FROM Sales.SalesOrderHeader),

comportement_achat AS (   
        SELECT        
                soh.CustomerID,        
                DATEDIFF(DAY, MAX(soh.OrderDate), 
                (
                        SELECT date_ref FROM date_reference)) AS recence_jours,        
                COUNT(DISTINCT soh.SalesOrderID) AS frequence,        
                SUM(soh.TotalDue)                AS montant_total    
        FROM Sales.SalesOrderHeader soh    
        GROUP BY soh.CustomerID
                ),

scores_rfm AS (    
        SELECT        
                CustomerID,        
                recence_jours,        
                frequence,        
                montant_total,        
                NTILE(4) OVER (ORDER BY recence_jours DESC) AS score_r,        
                NTILE(4) OVER (ORDER BY frequence)          AS score_f,        
                NTILE(4) OVER (ORDER BY montant_total)      AS score_m    
        FROM comportement_achat),
        
segments AS (    
        SELECT       
                *,        
                CASE           
                        WHEN score_r >= 3 AND score_f >= 3 AND score_m >= 3 THEN 'Clients premium'            
                        WHEN score_r >= 3 AND score_f >= 3                  THEN 'Clients fidèles'            
                        WHEN score_r >= 3                                    THEN 'Clients récents'            
                        WHEN score_f >= 3 OR score_m >= 3                    THEN 'À réactiver'            
                        ELSE 'Clients dormants'        
                END AS segment    
        FROM scores_rfm
)
SELECT    
        segment,    
        COUNT(*)                                          AS nb_clients,    
        CAST(AVG(CAST(recence_jours AS FLOAT)) AS INT)    AS recence_moyenne_jours,    
        CAST(AVG(CAST(frequence AS FLOAT)) AS DECIMAL(6,2)) AS frequence_moyenne,    
        CAST(SUM(montant_total) AS DECIMAL(18,2))         AS ca_du_segment,    
        CAST(100.0 * SUM(montant_total) / SUM(SUM(montant_total)) OVER () AS DECIMAL(6,2)) AS part_ca_pct 
        
FROM segments
GROUP BY segment
ORDER BY ca_du_segment DESC;