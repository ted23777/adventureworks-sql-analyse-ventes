--=====================================================
--Etape 2 : Évolution du chiffre d'affaires-- 
--=====================================================

--USE AdventureWorks2022;
--GO

-- Vue annuelle
SELECT   
    YEAR(OrderDate)                       AS annee,    
    COUNT(DISTINCT SalesOrderID)          AS nb_commandes,    
    CAST(SUM(SubTotal)  AS DECIMAL(18,2)) AS ca_ht,    
    CAST(SUM(TotalDue)  AS DECIMAL(18,2)) AS ca_ttc,    
    CAST(AVG(TotalDue)  AS DECIMAL(18,2)) AS panier_moyen
FROM Sales.SalesOrderHeader 
GROUP BY YEAR(OrderDate) 
ORDER BY annee;

 -- Vue mensuelle avec évolution vs mois précédent
WITH ca_mensuel AS (    
    SELECT        
        YEAR(OrderDate)  AS annee,        
        MONTH(OrderDate) AS mois,        
        SUM(TotalDue)    AS ca    
    FROM Sales.SalesOrderHeader    
    GROUP BY YEAR(OrderDate), MONTH(OrderDate))

SELECT    
    annee,    
    mois,    CAST(ca AS DECIMAL(18,2))                       AS ca,    
    CAST(LAG(ca) OVER (ORDER BY annee, mois) AS DECIMAL(18,2)) AS ca_mois_precedent,    
    CAST(        
        100.0 * (ca - LAG(ca) OVER (ORDER BY annee, mois))        
        / NULLIF(LAG(ca) OVER (ORDER BY annee, mois), 0)    
    AS DECIMAL(6,2))                                AS evolution_pct 
FROM ca_mensuel 
ORDER BY annee, mois;