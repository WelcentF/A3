-- Which restaurants have high menu variety but low sales?
-- Question: Find restaurants that offer more menu items than 
-- the average restaurant but have sold fewer total units than 
-- the average restaurant. Include restaurants that have never 
-- sold any menu items. Return the restaurant name, cuisine type, 
-- number of menu items offered, and total quantity sold.

CREATE VIEW RestaurantMenuSize AS
SELECT r.rID, r.name, r.cuisineType,
       COUNT(m.mID) AS menuSize
FROM Restaurant r
LEFT JOIN MenuItem m ON r.rID = m.rID
GROUP BY r.rID, r.name, r.cuisineType;

CREATE VIEW RestaurantSales AS
SELECT r.rID,
       SUM(CASE WHEN p.paymentStatus = 'successful'
                THEN c.quantity
                ELSE 0 END) AS totalUnitsSold
FROM Restaurant r
LEFT JOIN MenuItem m ON r.rID = m.rID
LEFT JOIN Contains c ON m.mID = c.mID
LEFT JOIN Orders o ON c.oID = o.oID
LEFT JOIN Payment p ON o.oID = p.oID
GROUP BY r.rID;


SELECT ms.name, ms.cuisineType,
       ms.menuSize, rs.totalUnitsSold
FROM RestaurantMenuSize ms
JOIN RestaurantSales rs ON ms.rID = rs.rID
WHERE ms.menuSize > (
    SELECT AVG(menuSize)
    FROM RestaurantMenuSize
)
AND rs.totalUnitsSold < (
    SELECT AVG(totalUnitsSold)
    FROM RestaurantSales
)
ORDER BY rs.totalUnitsSold;