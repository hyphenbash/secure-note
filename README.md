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

ensure PostgreSQL server is installed

```shell
bundle install
```

#### Database

Database is created to maintain record of uuid as well as persisting password digests to retrieve notes from the file system later on.
However, note text is not recorded to the database, rather as a .txt filesystem name associated to the id column in the database

```shell 
rake db:create
rake db:migrate
```

## Run

```shell
rackup -p 8080
```

then go to localhost:8080/secure-notes/new

#### Available Routes

- /secure-notes (GET, POST)
- /secure-notes/new (GET)
- /secure-notes/:uuid (GET, POST)

## Tests

``` 
RACK_ENV=test rake db:create
RACK_ENV=test rake db:migrate
```

```shell
rspec
```

## Design Decisions & Challenges

#### Database vs. Flat Files

Due to the requirement having note text saved to a file system 
(assuming the file access speend being fast was considered in the design question), 
the application was structured in a way that database is already integrated 
along side the file system approach for the following reasons:

- Future integration of more complex relational data
- Tracking/Indexing the notes metadata in a relational way.
- Data encryption requires metadata to be persisted on future retrievals

uuid is now created/handled in the application layer using `SecureRandom.uuid` 
and assigned to uuid column in the database. 
It turns out that the advantage to create in the application layer
than the database is in parallel tasks on failure to save data on 
either of db or the file system, where in this case if file system fails, 
data won't be orphaned and saved on db, which is the main reason of having 
the data saved in the db so to track the file system data.

#### Migrations

DB Schema is managed via migrations. As this is a working branch and 
the migrations are not being used anywhere else or any other branch, 
while data structure being modified, `db:rollback` was only used and 
no other migration was introduced. 

However, if the reviewer of the code is using the code on this branch already, 
please ensure to run fresh rollback/migration (incl. all steps) 
each time pulling from remote.
