# BACKGROUND

While implementing **ASSIGN** for **Endeavour Health**, I came across **YottaDB**.  
The ASSIGN code is available here: [https://github.com/endeavourhealth-discovery/ASSIGN](https://github.com/endeavourhealth-discovery/ASSIGN).

If you use any of the document database code, I would appreciate it if you could acknowledge the following in a disclaimer file if you fork the project:
- **YottaDB** ([https://yottadb.com/](https://yottadb.com/))
- **Endeavour Health** ([https://www.endeavourhealth.org/](https://www.endeavourhealth.org/))
- **mgateway** ([https://www.mgateway.com/](https://www.mgateway.com/))
- **Lifetime Software Solutions** (my company)

For cloud hosting, I’ve been using **brightbox.co.uk**, which offers simple and scalable cloud infrastructure for developers.  
More details: [https://brightbox.co.uk/](https://brightbox.co.uk/)

# THE RESPOSITORY

This repository is an attempt to showcase a **document database** built using **Python** and **YottaDB**, while also enabling users to query the document data using **SQL**.  
This is made possible through **Octo** — YottaDB’s SQL layer — which allows you to map **globals** directly to SQL tables.

The underlying YottaDB technology is essentially the same as that used by **InterSystems IRIS**.  
The **MUMPS** global storage model (which powers **Epic**, **InterSystems HealthShare**, and other major healthcare systems) is a proven and highly successful approach in the healthcare technology space.  
The key difference: **YottaDB** is **open source**, while InterSystems IRIS is not.

Database size is constrained solely by available storage capacity.

This documentation should give you everything you need to stand up a YottaDB instance in just a few minutes — provided you're comfortable working with **Linux**.  
I used **Ubuntu** during development, but it should work with most Linux environments.

For hosting, I’ve been running YottaDB on the **brightbox.co.uk** platform, and locally on a Windows laptop via **Oracle VirtualBox** or **WSL** (*Windows Subsystem for Linux*) — both approaches work well.

---

This architecture/repository enables developers to query **JSON documents** directly, without the overhead of querying **JSON blobs**.  
While others may have explored similar ideas before, implementing this with **Octo** was surprisingly straightforward.

This approach stands out because it offers:
- **Schema-less flexibility** (like NoSQL) combined with **SQL familiarity**  
- **No need for secondary indexes**  
- **Predictable, high performance** (thanks to MUMPS globals optimized for transactional workloads)

The document database is based on just three main SQL tables:
- **zdoc** → maps to the `^doc` global
- **zaxin** → maps to the `^axin` global
- **xasum** → maps to the `^asum` global

For more background on how **globals** work, see:  
[https://github.com/robtweed/global_storage/blob/master/README.md](https://github.com/robtweed/global_storage/blob/master/README.md)

# INSTALLING YOTTADB


### Pre-requisites
Run the following commands to install the necessary packages:

```bash
sudo su
apt install -y --no-install-recommends file binutils libelf1 libicu-dev nano wget ca-certificates
apt install -y git make gcc libgcrypt-dev libssl-dev libgpgme-dev libconfig-dev tcsh
apt install -y cmake bison flex
apt install -y libreadline-dev
apt install -y libcurl4-openssl-dev
```

---

### Installing YottaDB
```bash
cd /tmp/
mkdir /tmp/tmp
wget -P /tmp/tmp https://gitlab.com/YottaDB/DB/YDB/raw/master/sr_unix/ydbinstall.sh
cd /tmp/tmp/
chmod +x ydbinstall.sh
sudo ./ydbinstall.sh --octo --gui --encplugin --installdir /usr/local/lib/yottadb/latest
```

---

### Installing the YottaDB Python Plug-in

1. **Create and configure a new user:**
```bash
adduser fred
adduser fred sudo
su fred
```

2. **Set up a Python virtual environment:**
```bash
sudo apt install python3.12-venv
python3 -m venv /home/fred/yottadb_venv
source /home/fred/yottadb_venv/bin/activate
```

3. **Test MUMPS access:**
```bash
cd /home/fred/
/usr/local/lib/yottadb/latest/ydb
```
(You should get a MUMPS prompt. Exit with `H`.)

4. **Ensure you're running as the correct user:**
```bash
su fred
```

5. **Install required Python packages and system libraries:**
```bash
sudo apt install python3-pip
sudo apt install libffi-dev
```

6. **Set YottaDB environment variables:**
```bash
export ydb_dist=/usr/local/lib/yottadb/latest/
export ydb_gbldir=/home/fred/.yottadb/r2.02_x86_64/g/yottadb.gld
export ydb_dir=/home/fred/.yottadb
export ydb_rel=r2.02_x86_64
export ydb_routines="/home/fred/.yottadb/r2.02_x86_64/r(/home/fred/.yottadb/r2.02_x86_64/r) /usr/local/lib/yottadb/latest/plugin/o/_ydbaim.so /usr/local/lib/yottadb/latest/plugin/o/_ydbgui.so /usr/local/lib/yottadb/latest/plugin/o/_ydbmwebserver.so /usr/local/lib/yottadb/latest/plugin/o/_ydbocto.so /usr/local/lib/yottadb/latest/plugin/o/_ydbposix.so /usr/local/lib/yottadb/latest/libyottadbutil.so"
export ydb_icu_version=70.1
export ydb_xc_ydbposix=/usr/local/lib/yottadb/latest/plugin/ydbposix.xc
```

7. **Install the YottaDB Python package:**
```bash
pip3 install yottadb
```

---

### Database Configuration

Run the following to configure the database settings:

```bash
$ydb_dist/mupip SET -NULL_SUBSCRIPTS=true -region DEFAULT
$ydb_dist/mupip set -journal=off -region DEFAULT
$ydb_dist/mupip set -access_method=mm -region DEFAULT
```

**Note:**  
If you are **not** using YottaDB version **2.02**, you can adjust the key size (skip this if you are on 2.02):

```bash
$ydb_dist/mupip set -key_size=510 -region DEFAULT
```

---

### Viewing Database Configuration

To view the current database configuration, run:

```bash
$ydb_dist/dse d -f
```

# CONSUMING THE FHIR DATA


### Step 1: Prepare the FHIR Data

- Copy the files `fhir.nor.txt` and `fhir.eoc.txt` from `/fhir/` to `/tmp/`.

  > `fhir.nor.txt` contains **100,000 synthetic patient resources**, with each line representing a FHIR Patient resource.

---

### Step 2: Prepare the MUMPS Routines

- Copy `/mumps/*.m` into your YottaDB routine directory:  
  `/home/fred/.yottadb/r2.02_x86_64/r`

---

### Step 3: Convert FHIR to XPath Format

- Copy `/python/xpath_v2.py` to `/tmp/`.

- Run the script to convert the FHIR data into XPath-ready format:
```bash
python3 /tmp/xpath_v2.py '/tmp/fhir.nor.txt' '/tmp/xpath_patient.txt'
python3 /tmp/xpath_v2.py '/tmp/fhir.eoc.txt' '/tmp/xpath_eoc.txt'
```

---

### Step 4: Load Data into YottaDB

- Open a MUMPS prompt:
```bash
/usr/local/lib/yottadb/latest/ydb
```

- Import the patient data:
```mumps
do IDXPATH2^CONSUMER("/tmp/xpath_patient.txt","nor")
do STT^CONSUMER("nor","/tmp/xpath_patient.txt")
```

- Import the episode of care data:
```mumps
do IDXPATH2^CONSUMER("/tmp/xpath_eoc.txt","eoc")
do STT^CONSUMER("eoc","/tmp/xpath_eoc.txt")
```

---

### Additional Notes

After loading, you will have the following **globals** populated:

| Global | Description |
|:-------|:------------|
| `^doc`  | Stores the document data |
| `^axin` | Inverted index for fast value-based searching |
| `^asum` | Patient-document summary index (useful for multi-record data like observations) |

---

### Example: Inspecting the Data

**Document Global (`^doc`)**
```mumps
YDB> zwr ^doc(1,*)
^doc(1,0,1,1)="true"
^doc(1,0,9,8)=33560
^doc(1,0,14,14)="female"
^doc(1,0,15,15)="52573bc0-7971-476b-ad2c-edaa10138a38"
...
```

**XPath Mapping (`^xpath`)**
```mumps
YDB> zwr ^xpath
^xpath(1)="nor.active"
^xpath(2)="nor.address.city"
^xpath(3)="nor.address.district"
...
```

**Inverted Index (`^axin`)**
```mumps
YDB> zwr ^axin(29,"f93thylno@supanet.com",*)
^axin(29,"f93thylno@supanet.com",1,7,27)=""
```

**Patient-Document Summary (`^asum`)**
```mumps
YDB> zwr ^asum("nor","52573bc0-7971-476b-ad2c-edaa10138a38",*)
^asum("nor","52573bc0-7971-476b-ad2c-edaa10138a38",1)=""
```

---

### Data Model Summary

- `^doc`: document data (docid, group, order, xpathid)
- `^xpath`: maps xpathid to field meaning (e.g., "nor.address.city")
- `^axin`: inverted index (xpathid, value, docid, group, order)
- `^asum`: links patient type and patient ID to docids (for fast retrieval)

---

### Resetting the Database

If you want to clear everything and start fresh:
```mumps
do RESET^CONSUMER
```

# Creating the SQL Tables and Functions

I find the easiest way to get to an Octo SQL prompt is by issuing a `zsystem` command from a YDB prompt:

```mumps
zsystem "octo"
```

Copying and pasting the SQL command in a PuTTY session is a nice way to run the SQL commands.  
I've been copying the commands from my Windows desktop, then pasting the commands into my PuTTY session by right-clicking:

```sql
CREATE TABLE zaxin (
      xpath INTEGER,
      value VARCHAR,
      docid INTEGER,
      groupid INTEGER,
      orderid INTEGER,
      PRIMARY KEY (xpath, value, docid, groupid, orderid)
)
GLOBAL "^axin";

CREATE TABLE zdoc (
      docid INTEGER,
      groupid INTEGER,
      orderid INTEGER,
      xpath INTEGER,
      value VARCHAR EXTRACT "^doc(keys(""docid""),keys(""groupid""),keys(""orderid""),keys(""xpath""))",
      PRIMARY KEY (docid, groupid, orderid, xpath)
)
GLOBAL "^doc";

CREATE TABLE xasum (
      type VARCHAR,
      id VARCHAR,
      docid INTEGER,
      PRIMARY KEY (type, id, docid)
)
GLOBAL "^asum";
```

A simple query like this allows you to pretty much query any field across the entire database:

```sql
SELECT zdoc.*
FROM zaxin
JOIN zdoc ON zdoc.docid = zaxin.docid
WHERE zaxin.xpath = 29 AND zaxin.value = 'f93thylno@supanet.com';
```

**Search flow:**  
```
[Search Query] "f93thylno@supanet.com"
  ↓
^axin(29, "f93thylno@supanet.com", ...) → ^doc(1,7,28,29)
  ↓
^xpath(29) defines meaning: "nor.telecom.value"
```

Example output:
```
docid|groupid|orderid|xpath|value
1|0|1|1|true
1|0|9|8|33560
...
1|7|28|29|f93thylno@supanet.com
(29 rows)
```

You can modify the search easily, e.g., to find all females:

```sql
SELECT zdoc.*
FROM zaxin
JOIN zdoc ON zdoc.docid = zaxin.docid
WHERE zaxin.xpath = 14 AND zaxin.value = 'female';
```

---

This simple query could be used in conjunction with a machine learning model (e.g., Ollama) to create queries from natural language.

More complex processing can be done by calling a function.  
(Yes, you need to be able to write some MUMPS to create a function, but you can pretty much learn the fundamentals of MUMPS in a short space of time.)

---

## Example: Calculate Patient's Age from Date of Birth

MUMPS code:

```mumps
AGE(dob) ; dob is a +$Horolog date.
    set today=$$HD^STDDATE(+$H)
    set curryr=$p(today,".",3)
    set currmo=$p(today,".",2)
    set currday=$p(today,".",1)
    set dob=$$HD^STDDATE(dob)
    if dob="Unknown" quit -1
    set birthyr=$p(dob,".",3)
    set birthmo=$p(dob,".",2)
    set birthday=$p(dob,".",1)
    set age=curryr-birthyr
    if (currmo<birthmo)!((currmo=birthmo)&(currday<birthday)) set age=age-1
    quit age
```

Create the function in Octo:

```sql
CREATE FUNCTION AGE(int)
RETURNS VARCHAR AS $$AGE^NORNU;
```

Example usage:

```sql
SELECT AGE(67318-500);
-- Output: 1

SELECT AGE(CAST(value AS INT))
FROM zdoc
WHERE docid = 1 AND xpath = 8;
-- Output: 92
```

---

## Example: Retrieve Specific Fields from Documents

MUMPS code:

```mumps
DOC(docid, xpath) ;
    set (order, group, value) = ""
    for  set group=$o(^doc(docid,group)) quit:group=""  do  quit:value'=""
    . for  set order=$o(^doc(docid,group,order)) quit:order=""  do  quit:value'=""
    .. if $get(^doc(docid,group,order,xpath))'="" set value=^(xpath)
    quit value
```

Create the functions:

```sql
CREATE FUNCTION DOC(int, int)
RETURNS VARCHAR AS $$DOC^NORNU;

-- Overloaded function
CREATE FUNCTION DOC(int, int, int)
RETURNS VARCHAR AS $$DOC2^NORNU;
```

Other functions:

```sql
CREATE FUNCTION ASUM(varchar, varchar, int)
RETURNS VARCHAR AS $$ASUM^NORNU;

CREATE FUNCTION TEMPKILL(varchar, varchar)
RETURNS VARCHAR AS $$KILLG^NORNU;

CREATE FUNCTION SUMV2(varchar, integer)
RETURNS VARCHAR AS $$SUMV^NORNU;

CREATE FUNCTION AGEV(varchar)
RETURNS VARCHAR AS $$AGEV^NORNU;

CREATE FUNCTION HDV(varchar)
RETURNS VARCHAR AS $$HD^NORNU;

CREATE FUNCTION ISNULL(varchar)
RETURNS INTEGER AS $$ISNULL^NORNU;

CREATE FUNCTION DHV(varchar)
RETURNS VARCHAR AS $$DH^NORNU;
```

Example:

```sql
SELECT docid, AGE(CAST(value AS INT)), DOC(docid,24)
FROM zdoc
WHERE xpath = 8
LIMIT 10;
```

Result:

```
docid|age|doc
1|92|dammbruck, korenza (mrs)
2|100|barreira, kent (mr)
...
10|87|conrades, rosalynn (mrs)
(10 rows)
```

Search for younger patients:

```sql
SELECT docid, AGE(CAST(value AS INT)), DOC(docid,24)
FROM zdoc
WHERE xpath = 8
AND CAST(AGE(CAST(value AS INT)) AS INT) < 20
LIMIT 10;
```

---

## Testing Patient Search Backend

Run:

```mumps
Write $extract($$STT^NORNU("A"),1,1000)
```

- Extracts and displays the first 1000 characters of results

- Provides a quick way to validate the search backend is functioning

---

## Other Useful Back-end Routines

- Copy the file `%death.txt` from `/fhir/` to `/tmp/`.

```mumps
// Deaths by age group
do DEADSTAT^NORNU

// Record a death
do MAKEDEAD^NORNU

// End 10% of the episode of care records for each organisation
do ENDEOC^NORNU
```

---

## Example SQL: GMS Registered Patients on 1 Jan 1993

```sql

-- 33 = eoc.extension.valuecoding.code
-- 42 = nor.dateofdeath
-- 43 = eoc.period.end
-- 39 = eoc.period.start
-- 33 = eoc.extension.valuecoding.code
-- 38 = eoc.patient.reference
-- 6 = nor.address.text

SELECT docid,
       ASUM('nor', DOC(docid,0,38), 42) AS dod,
       DOC(docid,0,43) AS end_date,
       HDV(DOC(docid,0,39)) AS start_date,
       DOC(docid,1,33) AS status,
       DOC(docid,0,38) AS nor,
       ASUM('nor', DOC(docid,0,38), 6) AS address
FROM xasum
WHERE type = 'eoc'
  AND DOC(docid,1,33) = 'r'
  AND (ISNULL(ASUM('nor', DOC(docid,0,38), 42)) = 1 OR ASUM('nor', DOC(docid,0,38), 42) >= DHV('1.1.1993'))
  AND DOC(docid,0,39) <= DHV('1.1.1993')
  AND (DOC(docid,0,43) >= DHV('1.1.1993') OR ISNULL(DOC(docid,0,43)) = 1);
```

Expected result if no records match:

```
docid|dod|end_date|start_date|status|nor|address
(0 rows)
```

The `ISNULL` SQL function runs this MUMPS code:

```mumps
YDB> Write $$ISNULL^NORNU($$DOC2^NORNU(138384,0,43))
1
YDB> Write $$ISNULL^NORNU($$DOC2^NORNU(138383,0,43))
...
```

# Standing Up the Python Web Services and Patient Search UI

## Setup

```bash
cd /srv/
sudo mkdir nornu
```

Copy files:
- Copy `/javascript/index.html` to `/srv/nornu/` (user interface).
- Copy `/python/calltab.ci` to `/srv/`.
- Copy `/python/mumps_srv_v5.py` to `/srv/`.

Switch to user `fred`:

```bash
su fred
source /home/fred/yottadb_venv/bin/activate
```

Set environment variables:

```bash
export ydb_dist=/usr/local/lib/yottadb/latest/
export ydb_gbldir=/home/fred/.yottadb/r2.02_x86_64/g/yottadb.gld
export ydb_dir=/home/fred/.yottadb
export ydb_rel=r2.02_x86_64
export ydb_routines="/home/fred/.yottadb/r2.02_x86_64/r(/home/fred/.yottadb/r2.02_x86_64/r) /usr/local/lib/yottadb/latest/plugin/o/_ydbaim.so /usr/local/lib/yottadb/latest/plugin/o/_ydbgui.so /usr/local/lib/yottadb/latest/plugin/o/_ydbmwebserver.so /usr/local/lib/yottadb/latest/plugin/o/_ydbocto.so /usr/local/lib/yottadb/latest/plugin/o/_ydbposix.so /usr/local/lib/yottadb/latest/libyottadbutil.so"
export ydb_icu_version=70.1
export ydb_xc_ydbposix=/usr/local/lib/yottadb/latest/plugin/ydbposix.xc
```

Install required Python packages:

```bash
pip install flask
pip install flask-cors
```

Run the Python service:

```bash
cd /srv/
python3 mumps_srv_v5.py
```

---

## Running with Gunicorn (Production WSGI Server)

Install Gunicorn:

```bash
sudo apt install gunicorn
pip install gunicorn
```

Start Gunicorn:

```bash
~/yottadb_venv/bin/gunicorn --bind 0.0.0.0:9080 --workers 4 --timeout 120 --access-logfile /tmp/access.log --error-logfile /tmp/error.log mumps_srv_v5:app > /tmp/gunicorn_stdout.log 2>&1 &
```

Stop Gunicorn:

```bash
pkill -f gunicorn
```

Check if Gunicorn is running:

```bash
ps aux | grep gunicorn
```

---

## Accessing the Service

In your browser, navigate to:

```
http://<IP>:9080/srv/nornu
```

---

## Optional: Running the YottaDB GUI

The YottaDB GUI allows you to view globals, routines, and run Octo SQL queries.

Start the GUI:

```bash
/usr/local/lib/yottadb/latest/ydb -run %ydbgui --readwrite --port 9081
```

Access it in your browser:

```
http://<IP>:9081
```
