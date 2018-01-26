# Secure Note

## Setup

change `.env.example` file to `.env` and populate as follows:

```dotenv
RACK_ENV=development
DB_HOST=localhost
DB_USERNAME={ YOUR POSTGRES USERNAME }
DB_PASSWORD={ YOUR POSTGRES PASSWORD }
NOTES_DIR=notes
``` 

#### Dependencies

ensure PostgreSQL is installed (ideally >= 9.4):

***Reason to choose PG:***
 
uuid is created/handled at the database layer and assigned to id column itself directly, instead of using plain ruby `SecureRandom.uuid`. 
PostgreSQL uses `pgcrypto` extension after v9.4 to generate uuid v4

```shell
bundle install
```

#### Database

Database is created to maintain record of uuid as well as persisting password digests to retrieve notes from the file system later on.
However, note text is not recorded to the database, rather as a .txt file system matching their filenames to the id column in the database

```shell 
rake db:create
rake db:migrate
```

#### Run

```shell
rackup -p 8080
```

then go to localhost:8080/secure-notes/new

#### Available Routes

- /secure-notes (GET, POST)
- /secure-notes/new (GET)
- /secure-notes/:id (GET, POST)

## Tests

``` 
RACK_ENV=test rake db:create
RACK_ENV=test rake db:migrate
```

```shell
rspec
```
