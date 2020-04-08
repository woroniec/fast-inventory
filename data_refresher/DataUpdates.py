
import csv
import psycopg2
from psycopg2 import extras
import time
from datetime import datetime

def main():

    print("Attempting to connect to database...")
    start = time.time()

    try:
        conn = psycopg2.connect(os.getenv("DATABASE_URL"))
        print("Connected. Updating product information...")
    except:
        print("Unable to connect to db")

    cur = conn.cursor()

    query = "TRUNCATE products"
    cur.execute(query)
    conn.commit()
    print("products table truncated.")

    query = "TRUNCATE time"
    cur.execute(query)
    conn.commit()
    print("time table truncated.")

    

    with open('C:\FastInv\OutputFile.csv', newline='') as csvfile:
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


        sql = "INSERT INTO products ( num, description, totalavailableforsale, qtyonhand, qtyallocated, qtynotavailable, qtynotavailabletopick,qtydropship,qtyonorderpo, qtyonorderso) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"
        

        psycopg2.extras.execute_batch(cur, sql, allProducts, page_size=100)

        
        print(f"{i} record(s) updated.") 
    end = time.time()
    print(f"Completed in {end - start} seconds")

    # Insert timestamp into time table

    now = datetime.utcnow()
    cur.execute("INSERT INTO time (products_update) VALUES (%s)",(now,))
    conn.commit()
    conn.close()
 


main()