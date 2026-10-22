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
SELECT coloana_1, (coloana_1 + 1) AS "coloana_1_plus_unu"

```

În secțiunile de mai jos vom discuta despre clauzele adiționale care vin după `FROM`.

### Filtrarea rândurilor folosind `WHERE`

Pentru a elimina o parte din rândurile întoarse de comanda `SELECT`, putem filtra rezultatul adăugând o comandă `WHERE`. Sistemul va verifica fiecare rând și le va întoarce doar pe cele care satisfac criteriile date. După `WHERE`,

<!-- TODO -->

De exemplu, pentru a identifica senzorii care măsoară lungimi / distanțe (în metri), putem folosi comanda:

```sql
SELECT *
FROM sensors
WHERE unit = 'm';
```

### Ordonarea rezultatelor &mdash; clauza `ORDER BY`

### Filtrarea rezultatelor de după ordonare &mdash; clauza `HAVING`

### Îmbinarea datelor din mai multe tabele &mdash; clauza `JOIN`

### Agregarea datelor

## Sub-interogări (_subqueries_)

TO DO

## Aplicarea de filtre la `UPDATE` / `DELETE`

## Importanța constrângerilor de integritate

## Salvarea unei copii de siguranță și restaurarea ei &mdash; comanda `psql`

TO DO

## Exerciții

1. Încărcați în baza voastră de date fișierul [`measurements_v2.sql`](data/measurements_v2.sql).

2. Afișați toate măsurătorile realizate de către toți senzorii (conținutul tabelului `measurements`).

3. Afișați tabelul de măsurători, incluzând în rezultate o coloană nouă cu _incertitudinea relativă_ a fiecărei măsurători („incertitudinea relativă” este incertitudinea măsurătorii împărțită la valoarea brută a măsurătorii). **Nu alterați/modificați structura tabelului salvat în baza de date.** Ce se întâmplă când valoarea măsurătorii este `NULL`?

4. Afișați măsurătorile de la senzorul de LIDAR (cu `id = 1`), incluzând în rezultat doar coloanele de `recorded_at`, `raw_value` și `uncertainty`.

5. Ce se întâmplă dacă încercați să introduceți în baza de date o măsurătoare cu `uncertainty` negativ? (e.g. cu `uncertainty = -1`)

6. Afișați toate măsurătorile cu valoare brută lipsă.

8. Afișați primii trei senzori, în ordine descrescătoare după data instalării lor.

9. Creați o interogare care să afișeze codul, tipul de senzor și rata de eșantionare în Hz pentru toți senzorii _necalibrați_, ordonați de la cea mai mare rată de eșantionare până la cea mai mică.

10. Senzorul termic a avut o eroare și a înregistrat la un moment dat și valori nefizice (o temperatură sub 0 K). Folosind comanda `DELETE` cu o clauză `WHERE`, ștergeți toate măsurătorile de la acest senzor care au valoarea brută negativă.

11. Încercați să rezolvați [exercițiile din categoria _Basic exercises_](https://pgexercises.com/questions/basic/) de pe site-ul [PostgreSQL Exercises](https://pgexercises.com/).
