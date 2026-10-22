# Laboratorul 3

!!! abstract "Obiective"

    Să învățăm ce unelte avem la dispoziție în SQL pentru interogarea bazei de date. Să descoperim cum putem adăuga filtre pentru a indica care rânduri vrem să fie modificate sau șterse. Să vedem cum ne ajută constrângerile de integritate în practică pentru a „conserva” anumite proprietăți invariante.

## Interogări complexe

În laboratorul precedent, ne-am jucat un pic cu comenzile de bază din SQL. Scopul acestui laborator (și ale celor următoare) este să intrăm în detaliu pe fiecare categorie de comenzi și să vedem cum le putem folosi pentru a ne descurca în situații reale.

Pentru acest laborator, vom lucra tot cu senzori și măsurători, dar folosind o schemă puțin mai elaborată: [`measurements_v2.sql`](data/measurements_v2.sql). Recomandarea este să creați o bază de date nouă (folosind comanda `CREATE DATABASE`) în care să importați tabelele și datele din fișierul acesta.

Dacă vă uitați peste comenzile de DDL din fișier, o să observați câteva cuvinte cheie și funcționalități pe care nu le-am discutat încă:

- Cheile primare ale tabelelor au tipul de date `SERIAL`, respectiv `BIGSERIAL`. Acestea sunt [pseudo-tipuri de date specifice PostgreSQL](https://www.postgresql.org/docs/current/datatype-numeric.html#DATATYPE-SERIAL), care acționează ca o coloană de tip întreg (respectiv _big integer_) configurată să se incrementeze automat la insert.

- Unele coloane sunt etichetate cu [constrângerea `NOT NULL`](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-NOT-NULL). Aceasta indică faptul că ele trebuie tot timpul să conțină o valoare validă, nu pot fi setate implicit la valoarea specială `NULL`.

    La fel ca alte limbaje de programare, SQL are un sistem de tipuri de date care permite setarea unei coloane/variabile la valoarea specială `NULL` (care indică absența unei valori/înregistrări). Aceasta corespunde la `NULL` în C/C++ (pentru pointeri), la `null` în C#/Java sau la `None` în Python. Deși este de multe ori o funcționalitate convenabilă, prezența sau utilizarea `NULL` în code poate duce la multe bug-uri subtile (Tony Hoare, inventatorul acestui concept, a numit referințele `NULL` ca fiind [_the billion-dollar mistake_](https://www.infoq.com/presentations/Null-References-The-Billion-Dollar-Mistake-Tony-Hoare/)).

- Coloana `code` a unui senzor are constrângerea `UNIQUE`. Aceasta se asigură că fiecare senzor (fiecare rând din tabel) are o valoare distinctă pentru această coloană (față de celelalte rânduri existente).

- Unele coloane au o [constrângere de tip `CHECK`](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-CHECK-CONSTRAINTS). Aceste constrângeri pot conține expresii logice arbitrare și sunt verificate la fiecare actualizare a tabelului (baza de date se asigură că acel predicat logic rămâne adevărat, altfel se produce o eroare).

- Pentru câteva coloane am definit și o valoare `DEFAULT`. Aceasta este folosită de oricâte ori inserăm rânduri în tabel și nu specificăm explicit valorile pentru coloanele respective. În absența unei valori `DEFAULT`, SQL o să folosească valoarea `NULL` (dacă coloana respectivă este null-abilă) sau o să dea eroare.

    De exemplu, coloana `installed_at` din tabelul `sensors` are valoarea implicită `CURRENT_DATE`; aceasta este o valoare specială, care îi indică bazei de date să completeze coloana respectivă cu data de azi.

- În loc de `TIMESTAMP`, pentru coloana `recorded_at` am folosit tipul de date `TIMESTAMPTZ` (_timestamp with timezone_). În mod implicit, toate datele și toți timpii sunt înregistrați în baza de date în [Timpul Universal Coordonat](https://en.wikipedia.org/wiki/Coordinated_Universal_Time) (UTC). Acest tip de date permite reținerea unui fus orar asociat înregistrărilor (de exemplu, România este pe UTC+2, exceptând ora de vară).

Vom reveni și în laboratoarele viitoare la unele dintre aceste funcționalități avansate ale limbajului SQL și ale sistemului de gestiune PostgreSQL. Deocamdată, ne vom concentra pe cum putem extrage informații dintr-o bază de date creată anterior.

### Comanda `SELECT` &mdash; Caracteristici de bază

Comanda [`SELECT`](https://www.postgresql.org/docs/current/sql-select.html) este folosită pentru a citi date dintr-un tabel existent. Este o comandă foarte versatilă, care poate fi folosită atât independent cât și în interiorul unei alte expresii (o să discutăm puțin mai încolo de _sub-interogări_).

Inovația adusă de SQL peste alte soluții de BD a fost abilitatea de a lucra cu mai multe date în același timp. Comanda `SELECT` poate returna o singură valoare (un _scalar_), un _rând_ cu mai multe coloane / valori sau chiar mai multe _rânduri_. Totodată, poate fi extinsă cu mai multe _clauze_ și apeluri de _funcții_ (sau _operatori_), care îi permit să combine informații din mai multe coloane (_computed columns_) sau să producă rezumate statistice pe baza a mai multor rânduri (_agregări_).

Sintaxa generală a comenzii este:

```sql
SELECT coloana_1, coloana_2, ...
FROM nume_tabel
[WHERE conditie_1 AND conditie_2]
[ORDER BY coloana_1 ASC, coloana_2, ...]
[HAVING coloana_1 >= 0]
```

Mai exact, imediat după select urmează o listă de coloane sau expresii care vor fi incluse în rezultat (alternativ, putem pune caracterul special `*` pentru a include toate coloanele din tabel). Putem adăuga și coloane adiționale, calculate pe baza celorlalte valori, cărora să le dăm un nume / alias folosind cuvântul cheie `AS`.

Un alt element constitutiv este partea cu `FROM`, unde indicăm tabelul din care vrem să citim datele. În caz că vrem să îl putem adresa mai ușor, putem să-i dăm un alias folosind tot `AS`. De exemplu:

```sql
SELECT t1.coloana_1, (t1.coloana_1 + 1) AS "coloana_1_plus_unu"
FROM tabel AS t1;
```

În secțiunile de mai jos vom discuta despre clauzele adiționale care vin după `FROM`.

### Filtrarea rândurilor folosind `WHERE`

Pentru a elimina o parte din rândurile întoarse de comanda `SELECT`, putem filtra rezultatul adăugând o comandă `WHERE`. Sistemul va verifica fiecare rând și le va întoarce doar pe cele care satisfac criteriile date.

După `WHERE`, urmează o expresie logică. Putem compara coloane cu valori folosind operatorii `=`, `<>` (diferit), `>`, `<`, `>=` și `<=`, iar expresiile pot fi combinate cu `AND`, `OR` și `NOT`. Pentru intervale numerice este util operatorul `BETWEEN`, iar pentru o listă de valori putem folosi `IN`:

```sql
SELECT *
FROM measurements
WHERE sensor_id IN (1, 3)
  AND raw_value BETWEEN 0 AND 100;
```

`NULL` nu reprezintă o valoare și nu poate fi comparat folosind `=` sau `<>`. Pentru a selecta valorile lipsă trebuie să folosim `IS NULL`, respectiv `IS NOT NULL`:

```sql
SELECT measurement_id, recorded_at
FROM measurements
WHERE raw_value IS NULL;
```

În cazul expresiilor cu `AND` și `OR` este recomandat să folosim paranteze pentru a face intenția explicită. Rețineți și că rezultatul unei expresii SQL poate fi `TRUE`, `FALSE` sau `UNKNOWN`; rândurile sunt păstrate de `WHERE` numai atunci când expresia este `TRUE`.

De exemplu, pentru a identifica senzorii care măsoară lungimi / distanțe (în metri), putem folosi comanda:

```sql
SELECT *
FROM sensors
WHERE unit = 'm';
```

### Ordonarea rezultatelor &mdash; clauza `ORDER BY`

Clauza `ORDER BY` ordonează rândurile rezultate după una sau mai multe coloane ori expresii. Ordinea implicită este crescătoare (`ASC`), iar pentru ordinea descrescătoare folosim `DESC`:

```sql
SELECT code, sensor_type, installed_at
FROM sensors
ORDER BY installed_at DESC, code ASC;
```

Putem ordona și după o coloană calculată sau după poziția ei în lista `SELECT`, însă referirea explicită la nume este de obicei mai clară. Pentru coloanele care pot avea valoarea `NULL`, putem alege poziția acestora folosind `NULLS FIRST` sau `NULLS LAST`:

```sql
SELECT measurement_id, raw_value
FROM measurements
ORDER BY raw_value DESC NULLS LAST;
```

### Îmbinarea datelor din mai multe tabele &mdash; clauza `JOIN`

O cheie străină ne permite să asociem rândurile din `measurements` cu senzorii din `sensors`. Un `JOIN` combină rânduri din două tabele atunci când condiția de asociere este adevărată:

```sql
SELECT m.recorded_at, m.raw_value, s.code, s.unit
FROM measurements AS m
JOIN sensors AS s ON s.sensor_id = m.sensor_id
ORDER BY m.recorded_at;
```

`JOIN` (sau `INNER JOIN`) întoarce doar rândurile care au un corespondent în ambele tabele. Pentru a păstra și senzorii fără măsurători, pornim de la `sensors` și folosim `LEFT JOIN`:

```sql
SELECT s.code, COUNT(m.measurement_id) AS number_of_measurements
FROM sensors AS s
LEFT JOIN measurements AS m ON m.sensor_id = s.sensor_id
GROUP BY s.sensor_id, s.code
ORDER BY s.code;
```

Observați că numărăm `measurement_id`, nu `COUNT(*)`: la un `LEFT JOIN`, `COUNT(*)` ar număra și rândul artificial cu valori `NULL` creat pentru un senzor fără măsurători. Atunci când două tabele au coloane cu același nume, aliasurile și calificarea (`m.sensor_id`, `s.sensor_id`) evită ambiguitatea.

### Agregarea datelor

Funcțiile de agregare calculează o singură valoare pe mai multe rânduri. Cele mai folosite sunt `COUNT`, `SUM`, `AVG`, `MIN` și `MAX`. `COUNT(*)` numără rândurile, în timp ce `COUNT(coloana)` ignoră valorile `NULL` din acea coloană:

```sql
SELECT
    sensor_id,
    COUNT(*) AS number_of_rows,
    COUNT(raw_value) AS number_of_values,
    AVG(raw_value) AS average_value,
    MIN(raw_value) AS minimum_value,
    MAX(raw_value) AS maximum_value
FROM measurements
GROUP BY sensor_id;
```

`GROUP BY` împarte rândurile în grupuri. Orice coloană din `SELECT` care nu este argumentul unei funcții de agregare trebuie să apară în `GROUP BY` (sau să fie determinată univoc de o coloană grupată). Dacă nu folosim `GROUP BY`, agregarea se face asupra întregului rezultat.

### Filtrarea grupurilor &mdash; clauza `HAVING`

Spre deosebire de `WHERE`, care filtrează rânduri înainte de agregare, `HAVING` filtrează grupurile după ce au fost calculate agregările. De aceea, `HAVING` este folosit de regulă împreună cu `GROUP BY`:

```sql
SELECT sensor_id, COUNT(*) AS number_of_measurements
FROM measurements
WHERE recorded_at >= '2026-10-15'
GROUP BY sensor_id
HAVING COUNT(*) >= 2
ORDER BY number_of_measurements DESC;
```

În exemplu, `WHERE` elimină rândurile vechi înainte de numărare, iar `HAVING` păstrează doar senzorii care au cel puțin două măsurători. Dacă vrem să filtrăm după o valoare individuală, folosim `WHERE`, nu `HAVING`.

## Sub-interogări (_subqueries_)

O sub-interogare este o comandă `SELECT` inclusă într-o altă comandă. Ea poate fi folosită pentru a calcula o valoare, pentru a produce o listă de valori sau pentru a verifica existența unor rânduri.

De exemplu, următoarea interogare găsește măsurătorile realizate de senzorii care au o rată de eșantionare de cel puțin 50 Hz:

```sql
SELECT *
FROM measurements
WHERE sensor_id IN (
    SELECT sensor_id
    FROM sensors
    WHERE sampling_rate_hz >= 50
);
```

Pentru o sub-interogare care întoarce o singură valoare putem folosi direct rezultatul ei:

```sql
SELECT measurement_id, raw_value
FROM measurements
WHERE raw_value > (
    SELECT AVG(raw_value)
    FROM measurements
);
```

Operatorul `EXISTS` verifică dacă sub-interogarea produce cel puțin un rând și este util când ne interesează existența unei legături, nu valorile rezultate:

```sql
SELECT s.code
FROM sensors AS s
WHERE EXISTS (
    SELECT 1
    FROM measurements AS m
    WHERE m.sensor_id = s.sensor_id
      AND m.raw_value IS NULL
);
```

## Aplicarea de filtre la `UPDATE` / `DELETE`

Clauza `WHERE` se poate folosi și la comenzile care modifică date. Fără `WHERE`, `UPDATE` modifică toate rândurile, iar `DELETE` șterge toate rândurile din tabel. Înainte de a rula o modificare, este o practică bună să verificăm cu un `SELECT` exact ce rânduri urmează să fie afectate:

```sql
SELECT measurement_id, raw_value
FROM measurements
WHERE sensor_id = 3 AND raw_value < 0;
```

După verificare, putem șterge rândurile:

```sql
DELETE FROM measurements
WHERE sensor_id = 3 AND raw_value < 0;
```

Pentru o modificare în locul ștergerii folosim `UPDATE`:

```sql
UPDATE sensors
SET is_calibrated = TRUE
WHERE sensor_id = 3;
```

Într-o situație reală, putem grupa operațiile într-o tranzacție (`BEGIN`, `COMMIT`) și le putem anula cu `ROLLBACK` dacă verificarea rezultatului nu este cea dorită. Nu testați comenzile distructive pe singura copie a unor date importante.

## Importanța constrângerilor de integritate

Constrângerile mută verificarea unor reguli din codul aplicației în baza de date. Astfel, regula este respectată indiferent de aplicația, utilizatorul sau scriptul care încearcă să modifice datele. În schema noastră:

- `PRIMARY KEY` identifică în mod unic fiecare rând;
- `FOREIGN KEY` împiedică o măsurătoare să indice un senzor inexistent;
- `NOT NULL` obligă coloana să primească o valoare;
- `UNIQUE` împiedică repetarea codului unui senzor;
- `CHECK` validează o condiție, de exemplu `uncertainty >= 0`;
- `DEFAULT` completează automat o valoare atunci când aceasta nu este furnizată.

Putem observa efectul unei constrângeri încercând operații invalide:

```sql
-- Eșuează deoarece codul există deja:
INSERT INTO sensors (code, sensor_type, unit, sampling_rate_hz)
VALUES ('LIDAR-FRONT', 'LiDAR', 'm', 10);

-- Eșuează deoarece incertitudinea nu poate fi negativă:
INSERT INTO measurements (sensor_id, raw_value, uncertainty, experiment_run)
VALUES (1, 4.5, -1, 'RUN-TEST');
```

Mesajul de eroare trebuie interpretat, nu ignorat: operația nu a fost acceptată, iar datele existente nu sunt transformate într-o stare invalidă.

## Salvarea unei copii de siguranță și restaurarea ei &mdash; comanda `psql`

Pentru a salva schema și datele unei baze PostgreSQL folosim utilitarul `pg_dump`. Fișierul rezultat în format SQL poate fi restaurat prin `psql` într-o bază de date existentă:

```bash
pg_dump --username=postgres --dbname=measurements \
    --file=measurements-backup.sql

createdb --username=postgres measurements-restored
psql --username=postgres --dbname=measurements-restored \
    --file=measurements-backup.sql
```

Înlocuiți numele bazei și opțiunile de conectare cu cele folosite pe calculatorul vostru. Dacă baza este rulată într-un container, comenzile pot fi executate în container sau pot primi opțiunile `--host`, `--port`, `--username` și `--dbname` corespunzătoare.

După restaurare, verificați rezultatul conectându-vă la baza nouă și rulând câteva interogări, de exemplu:

```sql
SELECT COUNT(*) FROM sensors;
SELECT COUNT(*) FROM measurements;
```

Un dump în format SQL este ușor de inspectat și folosit cu `psql`, însă pentru baze mari PostgreSQL oferă și formatul personalizat (`pg_dump --format=custom`), care se restaurează cu `pg_restore`. O copie de siguranță este utilă numai dacă am verificat și faptul că poate fi restaurată.

## Exerciții

1. Încărcați în baza voastră de date fișierul [`measurements_v2.sql`](data/measurements_v2.sql).

2. Afișați toate măsurătorile realizate de către toți senzorii (conținutul tabelului `measurements`).

3. Afișați tabelul de măsurători, incluzând în rezultate o coloană nouă cu _incertitudinea relativă_ a fiecărei măsurători („incertitudinea relativă” este incertitudinea măsurătorii împărțită la valoarea brută a măsurătorii). **Nu alterați/modificați structura tabelului salvat în baza de date.** Ce se întâmplă când valoarea măsurătorii este `NULL`?

4. Afișați măsurătorile de la senzorul de LIDAR (cu `id = 1`), incluzând în rezultat doar coloanele de `recorded_at`, `raw_value` și `uncertainty`.

5. Ce se întâmplă dacă încercați să introduceți în baza de date o măsurătoare cu `uncertainty` negativ? (e.g. cu `uncertainty = -1`)

6. Afișați toate măsurătorile cu valoare brută lipsă.

7. Afișați pentru fiecare senzor codul și numărul de măsurători asociate. Includeți și senzorii care nu au nicio măsurătoare.

8. Afișați primii trei senzori, în ordine descrescătoare după data instalării lor.

9. Creați o interogare care să afișeze codul, tipul de senzor și rata de eșantionare în Hz pentru toți senzorii _necalibrați_, ordonați de la cea mai mare rată de eșantionare până la cea mai mică.

10. Senzorul termic a avut o eroare și a înregistrat la un moment dat și valori nefizice (o temperatură sub 0 K). Folosind comanda `DELETE` cu o clauză `WHERE`, ștergeți toate măsurătorile de la acest senzor care au valoarea brută negativă.

11. Încercați să rezolvați [exercițiile din categoria _Basic exercises_](https://pgexercises.com/questions/basic/) de pe site-ul [PostgreSQL Exercises](https://pgexercises.com/).
