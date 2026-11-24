-- Which drivers perform better than other drivers serving the same cuisine?
-- Question: Find drivers who have completed at least 5 deliveries for 
-- restaurants belonging to a particular cuisine type and whose average
-- delivery duration is shorter than the average delivery duration for 
-- that cuisine. Return the driver's name, cuisine type, number of deliveries,
-- average delivery duration, and the average duration for that cuisine.

CREATE VIEW DeliveryDuration AS
SELECT d.deliveryID, d.driverID,
       d.deliveryTime - d.pickupTime AS duration
FROM Delivery d;

CREATE VIEW DriverAverage AS
SELECT driverID,
       COUNT(*) AS totalDeliveries,
       AVG(duration) AS avgDuration
FROM DeliveryDuration
GROUP BY driverID
HAVING COUNT(*) >= 5;

CREATE VIEW OverallDeliveryAverage AS
SELECT AVG(duration) AS overallAvg
FROM DeliveryDuration;

SELECT dr.driverID, dr.name,
       da.totalDeliveries, da.avgDuration
FROM Driver dr
JOIN DriverAverage da ON dr.driverID = da.driverID
CROSS JOIN OverallDeliveryAverage oa
WHERE da.avgDuration < oa.overallAvg
ORDER BY da.avgDuration;