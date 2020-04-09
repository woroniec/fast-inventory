import os
import csv
import psycopg2
from psycopg2 import extras
import time
from datetime import datetime
from pathlib import Path

def main():

    print("Attempting to connect to database...")
    

    try:
        conn = psycopg2.connect(dbstring)
        print("Connected. Updating product information...")
    except:
        print("Unable to connect to db")


    # Removes header lines
    with open(r"C:\Users\[user]\Documents\straitswebtools\inventorywebtool\inventorywebtool.csv",'r', encoding = "ISO-8859-1") as f:
        with open(r"C:\Users\[user]\Documents\straitswebtools\inventorywebtool\updated_inventorywebtool.csv",'w') as f1:
            next(f) 
            for line in f:
                f1.write(line)
                
    # Cleanup
    os.remove(r"C:\Users\[user]\Documents\straitswebtools\inventorywebtool\inventorywebtool.csv")
    
    start = time.time()

    cur = conn.cursor()


    query = "TRUNCATE time"
    cur.execute(query)
    conn.commit()
    print("time table truncated.")            

    with open(r'C:\Users\[user]\Documents\straitswebtools\inventorywebtool\updated_inventorywebtool.csv', newline='') as csvfile:
        spamreader = csv.reader(csvfile,  delimiter=',',quotechar='"')
        

        i = 0

        allProducts = []
        for row in spamreader:
            num = row[0]
            description = row[1]
            totalavailableforsale = int(float(row[2]))
            qtyonhand = int(float(row[3]))
            qtyallocated = int(float(row[4]))
            qtynotavailable = int(float(row[5]))
            qtynotavailabletopick = int(float(row[6]))
            qtydropship = int(float(row[7]))
            qtyonorderpo = int(float(row[8]))
            qtyonorderso = int(float(row[9]))
            allProducts.insert(i,[num,description,totalavailableforsale,qtyonhand,qtyallocated,qtynotavailable,qtynotavailabletopick,qtydropship,qtyonorderpo,qtyonorderso])
            i += 1


        sql = "INSERT INTO work_products ( num, description, totalavailableforsale, qtyonhand, qtyallocated, qtynotavailable, qtynotavailabletopick,qtydropship,qtyonorderpo, qtyonorderso) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"
        

        psycopg2.extras.execute_batch(cur, sql, allProducts, page_size=100)

        
        print(f"{i} record(s) updated.") 
    end = time.time()
    print(f"Completed in {end - start} seconds")

    
    the_time = datetime.now().strftime("%Y-%m-%d %H-%M-%S")
    # Move imported file to archive
    Path(r"C:\Users\[user]\Documents\straitswebtools\inventorywebtool\updated_inventorywebtool.csv").rename(fr"C:\Users\[user]\Documents\straitswebtools\inventorywebtool\archive\updated_inventorywebtool_{the_time}.csv")

    # Insert timestamp into time table

    now = datetime.utcnow()
    cur.execute("INSERT INTO time (products_update) VALUES (%s)",(now,))

    # Fire work table swap procedure for super low table downtime
    cur.execute("CALL products_work_table_swap();")

    conn.commit()
    conn.close()
 


main()
