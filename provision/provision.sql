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