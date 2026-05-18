# Oracle Bank Practice

Oracle 23ai Free alapú gyakorló projekt analytic SQL, adattárházas lekérdezések és PL/SQL gyakorlásához.

A projekt célja:
- lokálisan újraépíthető Oracle gyakorlókörnyezet létrehozása banki jellegű adatokkal
- Oracle SQL ismétlések
- Window functionök gyakorlása (`LAG`, `RANK`, `SUM OVER`)
- Banki/adattárházas use case-ek modellezése
- Oracle + Docker fejlesztői workflow kialakítása

# Környezet

Séma link: https://dbdiagram.io/d/Oracle-analytic-SQL-practice-6a0afaf8697f99c1679f59d0

- Oracle Database 23ai Free
- Docker / version 29.4.3, build 055a478
- Oracle SQL Developer / 24.3.1.347
- macOS / Tahoe 26.3.1
- VSCode / 1.120

# Gyakorlási témák

- CTE (WITH)
- Window functions
- SUM() OVER()
- LAG()
- RANK()
- DENSE_RANK()
- ROW_NUMBER()
- Aggregációk
- Analytic SQL
- Oracle specifikus SQL
- Banki adattárház use case-ek
- Triggerek (napló tábla)

---

# Oracle Docker konténer indítása

Oracle image letöltése:

```bash
docker pull container-registry.oracle.com/database/free:latest
```

Konténer létrehozása

```bash
docker run -d \
  --name oracle-free \
  -p 1521:1521 \
  -e ORACLE_PWD=Oracle123 \
  container-registry.oracle.com/database/free:latest
```

Konténer indítása később

```bash
docker start oracle-free
docker logs -f oracle-free
```

Konténer leállítása
```bash
docker stop oracle-free
```

# SQL Developer kapcsolat, user létrehozás

SYSTEM userrel csatlakozva:
```sql
ALTER SESSION SET CONTAINER = FREEPDB1;

CREATE USER attila IDENTIFIED BY qwe123;

GRANT CONNECT, RESOURCE TO attila;

GRANT CREATE TABLE TO attila;
GRANT CREATE SEQUENCE TO attila;
GRANT CREATE VIEW TO attila;
GRANT CREATE PROCEDURE TO attila;

ALTER USER attila QUOTA UNLIMITED ON USERS;
```

Csatlakozás

```
Paraméter      Érték
Host           localhost
Port           1521
Service Name   FREEPDB1
User           attila
Password       qwe123
```

# Séma telepítés
Oracle SQL Developerben vagy VS Code Oracle extensionnel kell futtatni

Projekt struktúra
```text
sql/
├── 00_setup.sql
├── 01_drop_schema.sql
├── 02_create_schema.sql
├── 03_seed_data.sql
└── 04_analytic_queries.sql
```

Csak futtatni kell: _00_setup.sql_

```Run Script / F5```,  ha SQL Developerben futtatod


