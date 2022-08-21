
# Challenge code

* Node js V14
* Mysql V5


Install dependecies with the next command:

```
npm i
```

and execute to run the project with the next command:
```
node index.js
```

## Summary:
The project implements the next libraries like
*express
*cors
*Knex
*Mysql

## Migrations:
To create a new migration execute the next command
```
knex migrate:make migration_name 
```

To run migrations execute next command:
```
knex migrate:up
```

To run the project, you can execute the script up.sh

**warning** 
If you run the project with docker, be careful with the enviroments and set the rigth values