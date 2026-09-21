-- =====================================================
-- 03 — Performance produits et marge brute
-- =====================================================

--USE AdventureWorks2022;
--GO

SELECT     

    pc.Name                 AS categorie,    
    ps.Name                 AS sous_categorie,    
    p.Name                  AS produit,   
    SUM(sod.OrderQty)       AS quantite_vendue,    
    CAST(SUM(sod.LineTotal) AS DECIMAL(18,2))        AS ca, 
    CAST(SUM(sod.LineTotal - sod.OrderQty * p.StandardCost) AS DECIMAL(18,2)) AS marge_brute,    
    CAST(        
        100.0 * SUM(sod.LineTotal - sod.OrderQty * p.StandardCost)       
         / NULLIF(SUM(sod.LineTotal), 0)    
    AS DECIMAL(6,2))                                 AS taux_marge_pct 
FROM Sales.SalesOrderDetail sod 
JOIN Production.Product p           ON p.ProductID = sod.ProductID 
LEFT JOIN Production.ProductSubcategory ps ON ps.ProductSubcategoryID = p.ProductSubcategoryID
LEFT JOIN Production.ProductCategory pc    ON pc.ProductCategoryID = ps.ProductCategoryID
GROUP BY pc.Name, ps.Name, p.Name
ORDER BY ca DESC; 
            
-- Synthèse par catégorie : poids dans le CA total
WITH ca_categorie AS (    
    SELECT        
        COALESCE(pc.Name, 'Non catégorisé') AS categorie,        
        SUM(sod.LineTotal)                  AS ca    
    FROM Sales.SalesOrderDetail sod    
    JOIN Production.Product p           ON p.ProductID = sod.ProductID   
    LEFT JOIN Production.ProductSubcategory ps ON ps.ProductSubcategoryID = p.ProductSubcategoryID    
    LEFT JOIN Production.ProductCategory pc    ON pc.ProductCategoryID = ps.ProductCategoryID    
    GROUP BY COALESCE(pc.Name, 'Non catégorisé'))

SELECT    
    categorie,    
    CAST(ca AS DECIMAL(18,2))                                  AS ca,    
    CAST(100.0 * ca / SUM(ca) OVER () AS DECIMAL(6,2))         AS part_du_ca_pct
FROM ca_categorie
ORDER BY ca DESC;