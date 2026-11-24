-- Which customers are frequent and diverse food delivery users?
-- Question: Find customers who have placed at least 5 successfully 
-- paid orders, ordered from at least 3 different restaurants, and 
-- spent more than the average total spending among customers with 
-- successful payments. Return each customer's name, number of 
-- successful orders, number of distinct restaurants ordered from,
--  and total spending.

CREATE VIEW SuccessfulCustomerOrders AS
SELECT c.cID, c.name, o.oID, o.rID, p.paymentAmount
FROM Customer c
JOIN Orders o ON c.cID = o.cID
JOIN Payment p ON o.oID = p.oID
WHERE p.paymentStatus = 'successful';

CREATE VIEW CustomerActivity AS
SELECT cID, name,
       COUNT(oID) AS successfulOrders,
       COUNT(DISTINCT rID) AS distinctRestaurants,
       SUM(paymentAmount) AS totalSpent
FROM SuccessfulCustomerOrders
GROUP BY cID, name
HAVING COUNT(oID) >= 5
   AND COUNT(DISTINCT rID) >= 3;

SELECT name, successfulOrders,
       distinctRestaurants, totalSpent
FROM CustomerActivity
WHERE totalSpent > (
    SELECT AVG(totalSpent)
    FROM CustomerActivity
)
ORDER BY totalSpent DESC;