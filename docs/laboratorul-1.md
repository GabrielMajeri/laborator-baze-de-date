# Laboratorul 1

!!! abstract "Obiective"

    Să înțelegem conceptele de bază referitoare la stocarea datelor pe calculator, să descoperim principalele tipuri de sisteme de gestiune a bazelor de date (SGBD), să ne configurăm mediul de lucru local și să începem să ne familiarizăm cu limbajul SQL.

## Introducere

Bine ați venit la laboratorul de baze de date! În ziua de azi, datele sunt esențiale pentru multe locuri de muncă, iar acest lucru este cu atât mai adevărat pentru oamenii de știință, care lucrează cu seturi mari de date (*Big Data*). Sistemele informatice trebuie proiectate și dezvoltate pentru a putea gestiona aceste cantități mari de date și pentru a extrage informații utile din ele.

În cadrul acestor laboratoare, vom dobândi experiență practică cu câteva tipuri diferite de baze de date: relaționale (*relational*), vectoriale (*vector DB*), pentru serii de timp (*time series*), cheie-valoare (*key-value store*) etc. Se face de obicei distincția între bazele de date relaționale, care folosesc *limbajul de interogare structurat* (*Structured Query Language* &mdash; [SQL](https://en.wikipedia.org/wiki/SQL)) pentru a accesa și gestiona datele, respectiv cele nerelaționale, denumite uzual [NoSQL](https://en.wikipedia.org/wiki/NoSQL), care tind să aibă interfețe specifice.

Vom lucra cu mai multe sisteme moderne de gestiune a bazelor de date: [PostgreSQL](https://www.postgresql.org/), [MongoDB](https://www.mongodb.com/), [Redis](https://redis.io/), [InfluxDB](https://www.influxdata.com/) și posibil altele. Scopul este să ne familiarizăm cu uneltele disponibile, să învățăm ce avantaje și dezavantaje au fiecare și cum să alegem sistemul potrivit pentru datele noastre.

### De ce avem nevoie de bazele de date?

Dacă ați scris până acum programe care lucrează cu fișiere pe disc, ați văzut că procesul poate fi destul de complicat: trebuie deschis fișierul, trebuie găsit rândul / poziția care ne interesează, trebuie să citim informațiile în formatul corect (e.g. numere întregi, numere reale, șiruri de caractere, bytes etc.).

În practică, apar probleme și mai complicate: cum putem citi și prelucra un fișier în paralel (pe mai multe procesoare)? Ce se întâmplă dacă mai multe programe vor să modifice un fișier în același timp? Cum putem face copii de siguranță sau cum putem avea un istoric al modificărilor?

Sistemele de gestiune a bazelor de date (SGBD; în engleză, *Database Management System*, DBMS) sunt aplicații specializate pentru stocarea diferitelor tipuri de date într-un mod eficient și sigur. De multe ori, acestea sunt instalate pe servere și sunt accesibile prin rețea.

Modul în care funcționează aceste sisteme în profunzime este dincolo de scopul cursului. Ne vom mulțumi să înțelegem cum le putem configura și cum le putem folosi în practică. Vom învăța atât cum să utilizăm seturi de date și resurse existente, cât și cum să proiectăm și să creăm propria noastră bază de date, prin intermediul unui DBMS existent.

### Cu ce fel de date lucrăm?

Pe parcursul carierei voastre, vă veți întâlni cu tot felul de date:

- **Tabulare:** fișiere cu date separate prin virgulă (*comma-separated values*, CSV) sau prin spații (*tab-separated values*, TSV); conțin mai multe *rânduri*, fiecare având valori pentru un set comun de *coloane*.
- **Vectori:** datele sunt reprezentate de vectori într-un spațiu vectorial cu multe dimensiuni, în care vectorii „apropiați” codifică obiecte cu proprietăți asemănătoare.
- **Geospațiale:** locații geografice (puncte reprezentate prin latitudine și longitudine), zone pe hartă, proiecții, geometrii/corpuri 3D etc. Se încadrează în conceptul de [Geographic Information System](https://en.wikipedia.org/wiki/Geographic_information_system) (GIS).
- **Tablouri multidimensionale:** vectori, matrici, tensori de rang înalt. Câteodată poartă și denumirea de [*data cube*](https://en.wikipedia.org/wiki/Data_cube) (în special seturile de date foarte mari).
- **Serii de timp:** o înșiruire de măsurători / înregistrări, indexate după momentul efectuării lor. De obicei, măsurătorile sunt realizate periodic, la un interval fix (rata de eșantionare).
- **Grafuri:** o colecție de *noduri* și *muchii* (sau *arce*, în cazul grafurilor direcționate). Putem asocia măsurători cu fiecare nod sau fiecare muchie.

Acestea sunt doar câteva exemple de moduri în care pot fi reprezentate datele. Scopul nostru este să alegem formatul care permite codificarea cât mai fidelă și performantă a datelor, pentru a le putea transforma apoi în informații.

### Care sunt principalele tipuri de baze de date?

În funcție de natura datelor pe care vrem să le stocăm, sistemele de gestiune a bazelor de date se pot clasifica în:

- **Relaționale** &mdash; [PostgreSQL](https://www.postgresql.org/), [MySQL](https://www.mysql.com/), [MariaDB](https://mariadb.org/), [SQLite](https://sqlite.org/index.html), [Microsoft SQL Server](https://www.microsoft.com/en/sql-server), [Oracle SQL](https://en.wikipedia.org/wiki/Oracle_Database), [IBM Db2](https://www.ibm.com/products/db2)
- **Orientate pe documente** &mdash; [MongoDB](https://www.mongodb.com/), [CouchDB](https://couchdb.apache.org/), [ElasticSearch](https://www.elastic.co/elasticsearch/), [Solr](https://solr.apache.org/)
- **Pentru serii de timp** &mdash; [InfluxDB](https://www.influxdata.com/), [TimescaleDB](https://github.com/timescale/timescaledb), [ClickHouse](https://clickhouse.com/), [Prometheus](https://prometheus.io/)
- **Vectoriale** &mdash; [Redis](https://redis.io/), [Qdrant](https://qdrant.tech/), [Weaviate](https://weaviate.io/)
- **Grafuri** &mdash; [Neo4j](https://neo4j.com/)

Fiecare sistem de gestiune a bazelor de date este optimizat pentru lucrul cu un anumit tip de date. Unele sunt suficient de flexibile pentru a acoperi mai multe tipuri de date în aceeași bază de date (de exemplu, MongoDB poate gestiona atât documente cât și vectori; PostgreSQL are extensii care îi permit să îmbine date relaționale, serii de timp și vectoriale).

## Configurarea mediului de lucru

Primul sistem de gestiune a bazelor de date cu care vom lucra este [PostgreSQL](https://www.postgresql.org/), un program *open source* și gratuit. Este folosit predominant pentru baze de date relaționale, gestionate prin intermediul limbajului SQL, dar există extensii (tot *open source* și gratuite) care permit utilizarea lui pentru stocarea și prelucrarea [seriilor de timp](https://github.com/timescale/timescaledb), [datelor geospațiale](https://postgis.net/) sau a [datelor vectoriale](https://github.com/pgvector/pgvector).

Recomandarea noastră este să folosiți o instanță containerizată (instrucțiunile de mai jos), pentru a nu vă complica cu procesul de instalare PostgreSQL pe sistemul vostru și pentru a putea să resetați mai ușor baza de date (în caz că o stricați :slightly_smiling_face:).

### Containerizat

O modalitate populară de câțiva ani de a împacheta și distribui produsele software este [*containerizarea*](https://www.docker.com/). Un container software include de obicei o singură aplicație și toate dependințele (e.g. bibliotecile) de care are nevoie să ruleze.

Una dintre cele mai cunoscute platforme de gestiune a containerelor este [Docker](https://www.docker.com/). Ei au fost printre primii care au popularizat această abordare. Noi vă recomandăm să folosiți în schimb [Podman](https://podman.io/), care este complet gratuit și *open source* (în comparație cu Docker, care are unele componente proprietare). Dacă în viitor ajungeți să lucrați cu containere pe un cluster [HPC](https://en.wikipedia.org/wiki/High-performance_computing), s-ar putea să întâlniți și sistemul [Singularity](https://docs.sylabs.io/guides/4.6/user-guide/).

!!! goal "Obiectiv"

    Urmați [instrucțiunile oficiale de pe site-ul Podman](https://podman.io/get-started) pentru a instala executabilele `podman` și `podman-compose`. Puteți instala și [Podman Desktop](https://podman-desktop.io/downloads) dacă vreți și o interfață grafică pentru gestionarea containerelor. Calculatoarele din laboratorul de la facultate ar trebui să aibă deja Podman instalat. Luați legătura cu tutorele de laborator dacă întâmpinați dificultăți.

După ce ați instalat Podman, puteți încerca să rulați un container simplu pentru a testa funcționalitatea sistemului:

```shell
podman run --rm docker.io/hello-world
```

Podman se va conecta la registrul public de containere [Docker Hub](https://hub.docker.com/), va descărca [imaginea](https://www.ibm.com/think/topics/container-images) [`hello-world`](https://hub.docker.com/_/hello-world/) și va rula o instanță containerizată a acestei aplicații. Parametrul `--rm` îi spune lui Podman să șteargă containerul după ce își termină execuția (nu vrem să rămână salvat și să consume resurse).

Pentru a porni o instanță containerizată de PostgreSQL, puteți folosi următoarea sintaxă:

```shell
podman run \
    --detach \
    --name postgres-laborator \
    --env POSTGRES_PASSWORD=parola \
    --publish 5432:5432 \
    docker.io/postgres
```

Comanda va porni în fundal (`--detach`) un container denumit `postgres-laborator`, cu parola utilizatorului implicit `postgres` setată să fie `parola`, folosind imaginea [`docker.io/postgres`](https://hub.docker.com/_/postgres/). Portul 5432 din container va fi disponibil și pe `localhost`.

Pentru a vedea dacă containerul a pornit cu succes, rulați următoarea comandă (care folosește utilitarul [`psql`](https://www.postgresql.org/docs/current/app-psql.html)):

```shell
podman exec -it postgres-laborator psql --version
```

Ar trebui să vă afișeze un mesaj similar cu următorul:

```text
psql (PostgreSQL) 18.6 (Debian 18.6-1.pgdg13+2)
```

Dacă nu funcționează, puteți diagnostica problema uitându-vă pe logurile containerului:

```shell
podman logs postgres-laborator
```

Pentru a opri ulterior containerul de PostgreSQL (care rulează în fundal și consumă resurse), puteți rula comanda:

```shell
podman stop postgres-laborator
```

Pentru a porni din nou containerul de PostgreSQL, folosiți comanda:

```shell
podman start postgres-laborator
```

!!! danger "Atenție"

    Pentru a șterge cu totul instanța, inclusiv fișierele și datele din ea (de exemplu, pentru a reseta totul), puteți folosi comanda:

    ```shell
    podman rm --volumes postgres-laborator
    ```

### Instalat local

Serverul de PostgreSQL este o aplicație *open source* scrisă în [C](https://en.wikipedia.org/wiki/C_(programming_language)). Codul sursă îl puteți vedea [aici](https://github.com/postgres/postgres). Cu toate că ați putea să compilați aplicația de la sursă, recomandarea noastră este să instalați un pachet precompilat pentru sistemul vostru de operare.

!!! goal "Obiectiv"

    Urmați [instrucțiunile oficiale](https://www.postgresql.org/download/) de pe site-ul PostgreSQL pentru a descărca și instala cea mai recentă versiune de Postgres pentru sistemul vostru de operare.

Ca parte din instalarea standard, ar trebui să aveți acces și la utilitarul [`psql`](https://www.postgresql.org/docs/current/app-psql.html). Următoarea comandă:

```shell
psql --version
```

Ar trebui să ruleze cu succes și să afișeze un mesaj similar cu următorul:

```text
psql (PostgreSQL) 18.6
```

Pentru a opri și reporni ulterior serverul de PostgreSQL, urmați [instrucțiunile specifice sistemului vostru de operare](https://stackoverflow.com/q/45671327/5723188). Pe Linux puteți folosi de obicei [systemd](https://systemd.io/):

```shell
systemctl stop postgresql
```

Pe Windows sau macOS va trebui să folosiți interfața grafică sau interfața de control pentru serviciile de sistem.

## Conectarea la baza de date

Acum că ați reușit să instalați și să porniți o instanță de PostgreSQL, trebuie să ne conectăm la ea pentru a putea începe să o folosim. La fel ca majoritatea sistemelor de gestiune a bazelor de date, Postgres adoptă [o arhitectură client&ndash;server](https://en.wikipedia.org/wiki/Client%E2%80%93server_model): sistemul acționează ca un server care oferă acces securizat prin rețea clienților (aplicațiilor).

Există diferite moduri de a accesa baza de date, iar mai jos vom discuta despre câteva variante.

### Din linia de comandă: `psql`

Sistemul de bază PostgreSQL include și utilitarul [`psql`](https://www.postgresql.org/docs/current/app-psql.html), o interfață din linia de comandă pentru gestiunea bazei de date.

Dacă ați instalat PostgreSQL prin intermediul Podman, nu mai este nevoie să instalați separat altceva; puteți folosi versiunea de `psql` care vine inclusă în container:

```shell
podman exec -it postgres-laborator psql --username postgres
```

Ar trebui să vă lase să accesați interfața `psql` fără să vă solicite vreo parolă (comanda rulează ca utilizatorul `postgres` în container, deci sistemul îl va recunoaște și îi va da acces la utilizatorul corespunzător din PostgreSQL).

Dacă ați instalat PostgreSQL direct pe calculatorul vostru, cel mai probabil a fost inclus și pachetul care conține `psql`. Îl puteți folosi pentru a vă conecta la sistemul de gestiune a bazelor de date:

```shell
psql --username=postgres
```

Dacă comanda nu este găsită, asigurați-vă că ați instalat și `psql`. Altfel, s-ar putea să fie nevoie să specificați câteva detalii adiționale pentru conectare:

```shell
psql --host=localhost --port=5432 --username=postgres --dbname=postgres
```

În ambele cazuri, ar trebui să aveți acces la o interfață interactivă:

```text
psql (18.6 (Debian 18.6-1.pgdg13+2))
Type "help" for help.

postgres=#
```

Puteți introduce comenzi SQL sau metacomenzi, iar `psql` le va trimite spre serverul de PostgreSQL pentru a fi procesate. Încercați să rulați următoarea comandă pentru a vedea versiunea bazei de date:

```sql
SELECT version();
```

O să vă afișeze un rând cu informații despre serverul de baze de date care rulează:

```text
PostgreSQL 18.6 (Debian 18.6-1.pgdg13+2) on x86_64-pc-linux-gnu,
compiled by gcc (Debian 14.2.0-19) 14.2.0, 64-bit
```

S-ar putea să fie nevoie să apăsați pe `q` după executarea comenzii, pentru a ieși din [pager](https://unix.stackexchange.com/questions/144016/what-is-a-pager). `psql` încearcă să formateze rezultatele comenzilor pentru a fi mai ușor de citit.

La final, scrieți comanda `exit` și dați Enter pentru a ieși din interfața `psql`.

### Din browser: pgAdmin

[pgAdmin](https://www.pgadmin.org/) este o aplicație web *open source* care (așa cum sugerează și numele) permite gestiunea bazelor de date PostgreSQL.

Dacă aveți deja instalat și configurat Podman, puteți rula această aplicație într-un container folosind următoarea comandă:

```shell
podman run \
    --detach \
    --name pgadmin-laborator \
    --publish 8080:80 \
    --env 'PGADMIN_DEFAULT_EMAIL=user@example.com' \
    --env 'PGADMIN_DEFAULT_PASSWORD=parola' \
    docker.io/dpage/pgadmin4
```

Altfel, urmați [instrucțiunile de instalare](https://www.pgadmin.org/download/) specifice sistemului vostru de operare.

După instalare, interfața web ar trebui să fie accesibilă din browser la adresa [`localhost:8080`](http://localhost:8080) (sau [`localhost:80`](http://localhost:80) dacă ați folosit-o pe cea din exemplul lor).

Vă puteți autentifica folosind adresa de e-mail și parola din comanda de mai sus (e-mail address: `user@example.com`, password: `parola`). pgAdmin necesită autentificare deoarece poate fi folosit într-un mediu cu mai mulți utilizatori, pentru gestiunea mai multor servere de baze de date.

<figure markdown="span">
![pgAdmin - Pagina de pornire](images/pgadmin-setup-guide/landing-page.png)
<figcaption>Prima pagină a interfeței pgAdmin</figcaption>
</figure>

După autentificare, o să ajungeți la panoul de administrare. Acum trebuie să configurăm conexiunea la baza de date PostgreSQL configurată anterior.

<figure markdown="span">
![pgAdmin - Panou de control](images/pgadmin-setup-guide/dashboard.png)
<figcaption>Panoul de control al pgAdmin</figcaption>
</figure>

Pe tab-ul `General`, setați un nume pentru noua conexiune. Pe tab-ul `Connection`, completați informațiile de conectare. Dacă folosiți pgAdmin containerizat, adresa la care trebuie să vă conectați este `host.containers.internal` (echivalent cu `localhost` pe calculatorul vostru). Pentru pgAdmin și PostgreSQL instalate local, puteți folosi direct `localhost`. În ambele cazuri, port-ul este `5432`, username-ul este `postgres`, iar parola este `parola` (sau ce parolă ați setat voi la instalare).

<figure markdown="span">
![pgAdmin - Conexiune la baza de date](images/pgadmin-setup-guide/connection-settings.png)
<figcaption>Configurarea conexiunii la baza de date în pgAdmin</figcaption>
</figure>

Dacă ați configurat totul cum trebuie și ați salvat configurația, o să vi se deschidă o pagină cu informații despre serverul de baze de date la care v-ați conectat.

<figure markdown="span">
![pgAdmin - Informații despre server-ul de baze de date](images/pgadmin-setup-guide/database-page.png)
<figcaption>Informații despre server-ul de baze de date</figcaption>
</figure>

Pentru a putea executa comenzi în primele laboratoare, va trebui să folosiți interfața de *Query Tool* din pgAdmin. O puteți accesa selectând al doilea buton din panoul lateral din stânga. Selectați server-ul existent pe care l-ați adăugat anterior și (dacă este nevoie) introduceți din nou parola server-ului.

<figure markdown="span">
![pgAdmin - Query Tool](images/pgadmin-setup-guide/query-tool.png)
<figcaption>Pagina de activare a Query Tool</figcaption>
</figure>

În noua interfață care se deschide, puteți introduce comenzi SQL și le puteți executa. Rezultatele vor fi afișate în partea de jos a ferestrei.

<figure markdown="span">
![pgAdmin - Interfața de Query Tool](images/pgadmin-setup-guide/query-tool-results.png)
<figcaption>Interfața de Query Tool din pgAdmin</figcaption>
</figure>

Încercați să rulați și în acest caz comanda `SELECT version();` pentru a vedea versiunea server-ului de baze de date la care v-ați conectat.

### Interfață grafică: DataGrip

[DataGrip](https://www.jetbrains.com/datagrip/) este un IDE (*Integrated Development Environment*) pentru baze de date, dezvoltat de compania [JetBrains](https://www.jetbrains.com/). Este o aplicație comercială, dar oferă o perioadă de probă gratuită de 30 de zile. De asemenea, este gratuită pentru studenți și pentru utilizare necomercială.

Puteți descărca și instala DataGrip urmând [instrucțiunile de pe site-ul oficial](https://www.jetbrains.com/datagrip/download/). După ce o deschideți, creați un nou proiect pentru laborator și configurați conexiunea, la fel cum am făcut pentru pgAdmin:

<figure markdown="span">
![DataGrip - Configurarea sursei de date](images/datagrip-setup-guide/data-source-config.png)
<figcaption>Configurarea sursei de date pentru DataGrip</figcaption>
</figure>

După ce ați configurat și salvat sursa de date, puteți folosi interfața grafică pentru a explora baza de date și pentru a rula comenzi SQL:

<figure markdown="span">
![DataGrip - Consola de interogări](images/datagrip-setup-guide/query-console.png)
<figcaption>Rularea unei interogări în DataGrip</figcaption>
</figure>

DataGrip oferă o mulțime de funcționalități avansate, cum ar fi completarea automată a codului, vizualizarea relațiilor dintre tabele și generarea de diagrame. Îl vom putea folosi și pentru alte tipuri de baze de date pe parcursul laboratorului, nu doar pentru cele relaționale, cum ar fi PostgreSQL.

## Exerciții

Materialul pentru exerciții va fi adăugat ulterior.
