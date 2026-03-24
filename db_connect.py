import psycopg2

def get_db():
    return psycopg2.connect(
        host = 'localhost',
        database = 'emp_db',
        port = '5432',
        user = 'postgres',
        password = '1234'

    )

conn = get_db()
curr = conn.cursor()
print('succefully connected')

curr.execute('select * from employee')
rows = curr.fetchall()

for row in rows:
    print(row)

