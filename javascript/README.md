# ⚡ Lightning-Fast Patient Search with YottaDB

<img src="screenshot.png" alt="Demo Screenshot" width="800" />

A high-performance, low-latency patient search system using **YottaDB** for native execution and a modern JavaScript front-end.

---

## 🔑 Key Features

- **Sub-millisecond response times** on datasets with over 100,000 patient records
- **Full-text search** across multiple demographic fields
- **Direct execution in YottaDB**, no SQL engine required
- **JSON API responses** for simple web or system integration

---

## 🔍 Search Capabilities

Supported search fields:

- **Names**: Family and given names  
- **Birthdates**: Normalized date formats  
- **Postal codes**: Space-insensitive match  
- **Address fields**: City, district, and street lines  

---

## 🔄 Search Execution Flow

1. Accepts comma-separated search input  
2. Normalizes and processes each term via the `FIND` function  
3. Matches terms against pre-built `^axin` indices  
4. Aggregates and ranks results by frequency of matches  
5. Returns a paginated JSON object with matching patients  

---

## 🚀 Getting Started

### Prerequisites

- [YottaDB](https://yottadb.com) installed and configured  
- Python 3.8+ (if using the Flask API for web integration)

Before running, set this global:

```mumps
SET ^ICONFIG("NATIVE")=1
```

---

## 🌐 Demo

Try it live:  
👉 [Patient Search Demo](https://www.simon-group.co.uk/srv/nornu/nornu.html)

---

## 🗂️ Code Structure

| Path            | Description                         |
|-----------------|-------------------------------------|
| `/mumps`        | Native YottaDB code (`LV.m`)        |
| `/javascript`   | UI implementation (HTML + JS)       |
| `/fhir/fhir.zip`| Sample FHIR-formatted patient data  |

---

## 🧠 How `LV.m` Works

The heart of the search logic is in `LV.m`, using hierarchical index traversal and match scoring. Here's a breakdown of its main components:

### 🔎 `FIND` (Main Search Dispatcher)

- Normalizes input  
- Handles different field types: names, DOBs, postal codes, and address components  
- Adds all matching index paths to a list (`xpath`) for further searching  

### 🔁 `SRCH` (Index Scanner)

- Iterates through pre-indexed values stored in `^axin(index, value, docid)`  
- Adds document IDs to temporary stores:
  - `^TDOC($J,docid)` for results  
  - `^TXR($J,docid)` to count frequency (used for ranking)

### 📊 Result Aggregation

- Collects up to 500 best-matching document IDs  
- Formats them as JSON by calling `$$J^NORNU(docid)`  
- Returns structured response including `"totalCount"`

---

## 🧪 Example Search Input

```
"bob, 25.09.1969, b39 6rd"
```

This will:

- Match `bob` against given and family names  
- Match `25.09.1969` as birth date  
- Normalize and match the postal code  

---

## 📎 Notes

- Result limit is hardcoded to 500 entries to maintain performance  
- Matching is case-insensitive and accent-neutral  
- Postal code validation uses `validp^NORNU`
