# Demo for data_migrate issue #82

This repository demonstrates a bug with the `data_migrate` gem, described in [Issue #82](https://github.com/ilyakatz/data-migrate/issues/82).

To see the bug in action, clone this repo, `bundle` to get all gems, then run:

```
$ rails db:setup
...
... Database is created, schema is loaded, and data gets seeded.
...
$ rails data:migrate:status

database: db/development.sqlite3

 Status   Migration ID    Migration Name
--------------------------------------------------
  down    20180406083114  Set name for users

$ rails data:migrate
== 20180406083114 SetNameForUsers: migrating ==================================
rails aborted!
StandardError: An error has occurred, this and all later migrations canceled:

undefined method `first_name' for #<User:0x00007f81cb0a6938>
/.../data-migrate-bug-demo/db/data/20180406083114_set_name_for_users.rb:4:in `block in up'
/.../data-migrate-bug-demo/db/data/20180406083114_set_name_for_users.rb:3:in `up'
...
```

## What should have happened?

The above crash occurred because the data-migration file refers to code that is not valid _anymore_. The data-migration ran in _&ldquo;production&rdquo;_ in the _past_, and so doesn't need to be run again because _seeds_ have been updated to reflect new data structure.

Running `rails db:setup` sets up the database with the current schema. When data migrations are present, it should also mark data migrations up to the version indicated in `db/data_schema.rb` as complete.

In fact, that's exactly what the code in `db/data_schema.rb` _does_. See workaround for this issue below.

## Workaround

A workaround for this issue is to _manually_ run the contents of `db/data_schema.rb` in a `rails console` after setting up the database. This will mark all pending data migrations as complete.

```
$ rails console

irb(main):001:0> DataMigrate::Data.define(version: 20180406083114)
-- quote_table_name("data_migrations")
   -> 0.0001s
-- select_values("SELECT version FROM \"data_migrations\"")
   (0.1ms)  SELECT version FROM "data_migrations"
   -> 0.0004s
-- execute("INSERT INTO \"data_migrations\" (version) VALUES ('20180406083114')")
   (1.9ms)  INSERT INTO "data_migrations" (version) VALUES ('20180406083114')
   -> 0.0021s
=> [20180406083114]

irb(main):002:0> exit

$ rails data:migrate:status

database: db/development.sqlite3

 Status   Migration ID    Migration Name
--------------------------------------------------
   up     20180406083114  Set name for users
```
