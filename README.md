# vim-dbcp

**D**ata**b**ase **C**ompletion **P**rovider for Vim/Neovim.

Completion framework for database queries, works with [vim-dadbod](https://github.com/tpope/vim-dadbod).

## Supported

### SQL Databases
- **PostgreSQL** - table names, column names (with alias support), auto-quoting
- **MySQL/MariaDB** - table names, column names (with alias support), auto-quoting
- **SQLite** - table names, column names (with alias support), auto-quoting
- **SQL Server** - table names, column names (with alias support), auto-quoting
- **Oracle** - table names, column names (with alias support), auto-quoting

### NoSQL Databases
- **MongoDB** - collection names, db/collection methods, cursor chain methods, operators
- **Redis** - command names

## Requirements

- Vim 8.0+ or Neovim 0.5+
- [vim-dadbod](https://github.com/tpope/vim-dadbod)

**Note:** SQLite column completion requires SQLite 3.37.0+ for best results.

## Installation

```lua
-- lazy.nvim
{ "gh-liu/vim-dbcp", dependencies = { "tpope/vim-dadbod" } }
```

## Usage

### Using completefunc (recommended)

```vim
" Set completion function
setlocal completefunc=dbcp#complete

" Trigger with <C-x><C-u>
```

### Using omnifunc

```vim
" Set omni completion function
setlocal omnifunc=dbcp#omnifunc

" Trigger with <C-x><C-o>
```

### Database Connection

Set `b:db` or `g:db` to your database URL:

```vim
" SQLite
let b:db = 'sqlite:mydb.sqlite3'

" PostgreSQL
let b:db = 'postgresql://user:pass@localhost/mydb'

" MySQL
let b:db = 'mysql://user:pass@localhost/mydb'

" MongoDB
let b:db = 'mongodb://localhost/mydb'
```

### SQL Completion Features

**Table name completion** - triggers after `FROM`, `JOIN`, `UPDATE`, `INTO`, etc:
```sql
SELECT * FROM <C-x><C-u>
-- Completes table names
```

**Column name completion** - triggers after `table.` or `alias.`:
```sql
SELECT * FROM users u WHERE u.<C-x><C-u>
-- Completes column names from 'users' table
```

**Auto-quoting** - identifiers that need quoting (reserved words, special chars) are automatically quoted:
```sql
-- If you have a table named "order" (reserved word):
SELECT * FROM "order"  -- PostgreSQL/SQLite/Oracle
SELECT * FROM `order`  -- MySQL
SELECT * FROM [order]  -- SQL Server
```

### MongoDB Completion Features

**db methods and collections** - after `db.`:
```javascript
db.<C-x><C-u>
// Completes: getCollection, createCollection, ..., and your collection names
```

**Collection methods** - after `db.collection.`:
```javascript
db.users.<C-x><C-u>
// Completes: find, findOne, insertOne, updateMany, ...
```

**Cursor chain methods** - after `db.collection.find().`:
```javascript
db.users.find().<C-x><C-u>
// Completes: limit, skip, sort, toArray, ...
```

**Operators** - after `$`:
```javascript
{ $<C-x><C-u> }
// Completes: $eq, $gt, $in, $match, $group, ...
```

## Writing an Adapter

Create `autoload/dbcp/adapter/{db_type}.vim`:

```vim
function! dbcp#adapter#{db_type}#complete(findstart, base, db_url) abort
  if a:findstart
    " Return start column
  endif
  " Return completion items
endfunction
```

For SQL databases, you can reuse the generic SQL engine:

```vim
function! dbcp#adapter#{db_type}#complete(findstart, base, db_url) abort
  return dbcp#sql#complete(a:findstart, a:base, a:db_url, '{dialect}')
endfunction
```

Available dialects: `sqlite`, `postgres`, `mysql`, `sqlserver`, `oracle`

## License

MIT
