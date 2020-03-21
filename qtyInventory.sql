SELECT totalqty.partid               AS PARTID,
         part.num AS NUM, description,
       totalqty.locationgroupid      AS LOCATIONGROUPID,
       
       Sum(( CASE 
                      WHEN ( totalqty.t = 'QTYONHAND' ) THEN totalqty.qty 
                      ELSE 0 
                    end )) -
       Sum(( CASE 
                      WHEN ( totalqty.t = 'QTYNOTAVAILABLE' ) THEN totalqty.qty 
                      ELSE 0 
                    end ))  -
          ( Sum((CASE WHEN (totalqty.t = 'QTYALLOCATEDTORECEIVE') THEN 
                totalqty.qty 
                ELSE 0 end)) + Sum((CASE WHEN (totalqty.t = 'QTYALLOCATEDTOSEND') 
                THEN 
                totalqty.qty ELSE 0 end)) ) AS TotalAvailableForSale,
       
       Sum(( CASE 
               WHEN ( totalqty.t = 'QTYONHAND' ) THEN totalqty.qty 
               ELSE 0 
             end ))                      AS QTYONHAND, 
       Sum(( CASE 
               WHEN ( totalqty.t = 'QTYALLOCATEDPO' ) THEN totalqty.qty 
               ELSE 0 
             end ))                    + 
       Sum(( CASE 
               WHEN ( totalqty.t = 'QTYALLOCATEDSO' ) THEN totalqty.qty 
               ELSE 0 
             end ))                      +
       Sum(( CASE 
               WHEN ( totalqty.t = 'QTYALLOCATEDMO' ) THEN totalqty.qty 
               ELSE 0 
             end ))                     + 
       ( Sum((CASE WHEN (totalqty.t = 'QTYALLOCATEDTORECEIVE') THEN 
         totalqty.qty 
         ELSE 0 end)) + Sum((CASE WHEN (totalqty.t = 'QTYALLOCATEDTOSEND') 
         THEN 
         totalqty.qty ELSE 0 end)) ) AS QTYALLOCATED, 
       Sum(( CASE 
               WHEN ( totalqty.t = 'QTYNOTAVAILABLE' ) THEN totalqty.qty 
               ELSE 0 
             end ))                      AS QTYNOTAVAILABLE, 
       Sum(( CASE 
               WHEN ( totalqty.t = 'QTYNOTAVAILABLETOPICK' ) THEN 
               totalqty.qty 
               ELSE 0 
             end ))                      AS QTYNOTAVAILABLETOPICK, 
       Sum(( CASE 
               WHEN ( totalqty.t = 'QTYDROPSHIP' ) THEN totalqty.qty 
               ELSE 0 
             end ))                      AS QTYDROPSHIP, 
       Sum(( CASE 
               WHEN ( totalqty.t = 'QTYONORDERPO' ) THEN totalqty.qty 
               ELSE 0 
             end ))                      AS QTYONORDERPO, 
       Sum(( CASE 
               WHEN ( totalqty.t = 'QTYONORDERSO' ) THEN totalqty.qty 
               ELSE 0 
             end ))                      AS QTYONORDERSO, 
       ( Sum((CASE WHEN (totalqty.t = 'QTYONORDERTORECEIVE') THEN 
         totalqty.qty 
         ELSE 0 end)) + Sum((CASE WHEN (totalqty.t = 'QTYONORDERTOSEND') 
         THEN 
         totalqty.qty ELSE 0 end)) ) AS QTYONORDERTO, 
       Sum(( CASE 
               WHEN ( totalqty.t = 'QTYONORDERMO' ) THEN totalqty.qty 
               ELSE 0 
             end ))                      AS QTYONORDERMO 
FROM   (
        SELECT 'QTYONHAND'                   AS t,
               tag.partid                AS PARTID, 
               location.locationgroupid  AS LOCATIONGROUPID, 
               Coalesce(Sum(tag.qty), 0) AS QTY 
        FROM   (tag 
                JOIN (SELECT id, locationgroupid FROM LOCATION WHERE id NOT IN (1806,1808,1810,1807)) as location
                  ON(( location.id = tag.locationid ))) 
        WHERE  ( tag.typeid IN ( 30, 40 ) ) 
        GROUP  BY location.locationgroupid, 
                  tag.partid 
        UNION 
        SELECT 'QTYALLOCATED'                   AS t, 
               qtyallocated.partid          AS PARTID, 
               qtyallocated.locationgroupid AS LOCATIONGROUPID, 
               qtyallocated.qty             AS QTY 
        FROM   qtyallocated 
        UNION 
        SELECT 'QTYALLOCATEDPO'                   AS t, 
               qtyallocatedpo.partid          AS PARTID, 
               qtyallocatedpo.locationgroupid AS LOCATIONGROUPID, 
               qtyallocatedpo.qty             AS QTY 
        FROM   qtyallocatedpo 
        UNION 
        SELECT 'QTYALLOCATEDSO'                   AS t, 
               qtyallocatedso.partid          AS PARTID, 
               qtyallocatedso.locationgroupid AS LOCATIONGROUPID, 
               qtyallocatedso.qty             AS QTY 
        FROM   qtyallocatedso 
        UNION 
        SELECT 'QTYALLOCATEDTORECEIVE'                   AS t, 
               qtyallocatedtoreceive.partid          AS PARTID, 
               qtyallocatedtoreceive.locationgroupid AS LOCATIONGROUPID, 
               qtyallocatedtoreceive.qty             AS QTY 
        FROM   qtyallocatedtoreceive 
        UNION 
        SELECT 'QTYALLOCATEDTOSEND'                   AS t, 
               qtyallocatedtosend.partid          AS PARTID, 
               qtyallocatedtosend.locationgroupid AS LOCATIONGROUPID, 
               qtyallocatedtosend.qty             AS QTY 
        FROM   qtyallocatedtosend 
        UNION 
        SELECT 'QTYALLOCATEDMO'                   AS t, 
               qtyallocatedmo.partid          AS PARTID, 
               qtyallocatedmo.locationgroupid AS LOCATIONGROUPID, 
               qtyallocatedmo.qty             AS QTY 
        FROM   qtyallocatedmo 
        UNION 
        SELECT 'QTYNOTAVAILABLE'                   AS t, 
               qtynotavailable.partid          AS PARTID, 
               qtynotavailable.locationgroupid AS LOCATIONGROUPID, 
               qtynotavailable.qty             AS QTY 
        FROM   qtynotavailable 
        UNION 
        SELECT 'QTYNOTAVAILABLETOPICK'                   AS t, 
               qtynotavailabletopick.partid          AS PARTID, 
               qtynotavailabletopick.locationgroupid AS LOCATIONGROUPID, 
               qtynotavailabletopick.qty             AS QTY 
        FROM   qtynotavailabletopick 
        UNION 
        SELECT 'QTYDROPSHIP'                   AS t, 
               qtydropship.partid          AS PARTID, 
               qtydropship.locationgroupid AS LOCATIONGROUPID, 
               qtydropship.qty             AS QTY 
        FROM   qtydropship 
        UNION 
        SELECT 'QTYONORDERPO'                   AS t, 
               qtyonorderpo.partid          AS PARTID, 
               qtyonorderpo.locationgroupid AS LOCATIONGROUPID, 
               qtyonorderpo.qty             AS QTY 
        FROM   qtyonorderpo 
        UNION 
        SELECT 'QTYONORDERSO'                   AS t, 
               qtyonorderso.partid          AS PARTID, 
               qtyonorderso.locationgroupid AS LOCATIONGROUPID, 
               qtyonorderso.qty             AS QTY 
        FROM   qtyonorderso 
        UNION 
        SELECT 'QTYONORDERTORECEIVE'                   AS t, 
               qtyonordertoreceive.partid          AS PARTID, 
               qtyonordertoreceive.locationgroupid AS LOCATIONGROUPID, 
               qtyonordertoreceive.qty             AS QTY 
        FROM   qtyonordertoreceive 
        UNION 
        SELECT 'QTYONORDERTOSEND'                   AS t, 
               qtyonordertosend.partid          AS PARTID, 
               qtyonordertosend.locationgroupid AS LOCATIONGROUPID, 
               qtyonordertosend.qty             AS QTY 
        FROM   qtyonordertosend 
        UNION 
        SELECT 'QTYONORDERMO'                   AS t, 
               qtyonordermo.partid          AS PARTID, 
               qtyonordermo.locationgroupid AS LOCATIONGROUPID, 
               qtyonordermo.qty             AS QTY 
        FROM   qtyonordermo) totalqty 
        join part on totalqty.partid = part.id
GROUP  BY totalqty.partid, 
          totalqty.locationgroupid 