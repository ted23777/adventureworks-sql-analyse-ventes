-- =====================================================
-- Etape 1 :  Exploration et contrôle qualité
-- Objectif : cadrer le périmètre avant de l'analyser
--   Question    : quel est le périmètre analysé, et la donnée est-elle
--                 cohérente avant de l'exploiter ?
--   Tables      : Sales.SalesOrderHeader, Sales.SalesOrderDetail,
--                 Production.Product, Sales.Customer, Sales.SalesTerritory
--   Techniques  : UNION ALL, agrégats conditionnels, contrôle de cohérence
-- =====================================================

--USE AdventureWorks2022;
--GO

-- Volumétrie des tables du périmètre
SELECT 'Sales.SalesOrderHeader' AS table_source, COUNT(*) AS nb_lignes FROM Sales.SalesOrderHeader
UNION ALL SELECT 'Sales.SalesOrderDetail', COUNT(*) FROM Sales.SalesOrderDetail
UNION ALL SELECT 'Production.Product',     COUNT(*) FROM Production.Product
UNION ALL SELECT 'Sales.Customer',         COUNT(*) FROM Sales.Customer
UNION ALL SELECT 'Sales.SalesTerritory',   COUNT(*) FROM Sales.SalesTerritory;

-- Période couverte et cardinalités
SELECT
    MIN(OrderDate)              AS premiere_commande,
    MAX(OrderDate)              AS derniere_commande,
    COUNT(DISTINCT CustomerID)  AS nb_clients,
    COUNT(*)                    AS nb_commandes
FROM Sales.SalesOrderHeader;

-- Contrôle qualité : répartition en ligne / réseau de revendeurs
SELECT
    CASE WHEN OnlineOrderFlag = 1 THEN 'Vente en ligne' ELSE 'Revendeur' END AS canal,
    COUNT(*)                                              AS nb_commandes,
    SUM(CASE WHEN SalesPersonID IS NULL THEN 1 ELSE 0 END) AS sans_commercial,
    CAST(SUM(TotalDue) AS DECIMAL(18,2))                  AS ca_total
FROM Sales.SalesOrderHeader
GROUP BY OnlineOrderFlag;