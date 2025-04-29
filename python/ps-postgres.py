import psycopg2
from psycopg2 import sql

# Database connection parameters
url = "192.168.178.51"
port = 1337
database = ""
user = "paul"
password = "blah"

try:
    # Establish the connection
    conn = psycopg2.connect(
        host=url,
        port=port,
        dbname=database,
        user=user,
        password=password
    )

    print("Connected to the database!")

    # Define the SQL query
    #query = "SELECT * FROM xdoc WHERE docid = 221;"
    sql ="SELECT ASUM('nor', DOC(docid,0,38), 71) as dod,";
    sql = sql + " HDV(DOC(docid,0,39)) as start_date,";
    sql = sql + " HDV(DOC(docid,0,72)) as end_date,";
    sql = sql + " DOC(docid,1,33) as status,";
    sql = sql + " DOC2(docid,0,38) as nor,";
    sql = sql + " ASUM('nor', DOC(docid,0,38), 6) as address,";
    sql = sql + " UPRN(ASUM('nor', DOC(docid,0,38), 6)) as uprn";
    sql = sql + " FROM xasum";
    sql = sql + " WHERE type = 'eoc'";
    sql = sql + " AND DOC(docid,1,33) = 'r'";
    sql = sql + " AND (ISNULL(ASUM('nor', DOC(docid,0,38), 71))=1 OR DHV('1.1.1991') <= ASUM('nor', DOC(docid,0,38), 71))";
    sql = sql + " AND DHV('1.1.1991') >= DOC(docid,0,39)";
    sql = sql + " AND (DHV('1.1.1991') <= DOC(docid,0,72) OR ISNULL(DOC(docid,0,72))=1);";    

    # Create a cursor object to execute the query
    with conn.cursor() as cursor:
        #cursor.execute(query)
        cursor.execute(sql)

        # Fetch the results
        results = cursor.fetchall()
        column_names = [desc[0] for desc in cursor.description]

        # Print the column names
        print("Query Results:")
        print("\t".join(column_names))

        # Print each row in the result set
        for row in results:
            print("\t".join(map(str, row)))

except psycopg2.Error as e:
    print(f"Error: {e.pgcode}\n{e.pgerror}")

except Exception as e:
    print(f"Unexpected error: {e}")

finally:
    # Close the connection
    if 'conn' in locals() and conn:
        conn.close()
