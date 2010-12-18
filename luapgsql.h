#include <lua.h>
#include <lauxlib.h>
#include <libpq-fe.h>

#define MYNAME "pgsql"
#define MYVERSION MYNAME " library for " LUA_VERSION " 2008.04.01"

#define TYPE_CONNECTION "PgSQL.Connection"
#define TYPE_RESULT "PgSQL.Result"

#define lua_boxpointer(L, u) (*(void **)(lua_newuserdata(L, sizeof(void *))) = (u))
#define lua_unboxpointer(L, i) (*(void **)(lua_touserdata(L, i)))

#define lua_newconn(L) ((con_t *)(lua_newuserdata(L, sizeof(con_t))))
#define lua_toconn(L, i) ((con_t *)(lua_touserdata(L, i)))

#define lua_newresult(L) ((rs_t *)(lua_newuserdata(L, sizeof(rs_t))))
#define lua_toresult(L, i) ((rs_t *)(lua_touserdata(L, i)))

#define bool int
#define false 0
#define true 1

#define BOOLOID         16
#define INT8OID         20
#define INT2OID         21
#define INT4OID         23
#define FLOAT4OID		700
#define FLOAT8OID		701
#define NUMERICOID      1700


/** wrapper structs **/

struct con_t {
	PGconn *ptr;
	bool open;
};

struct rs_t {
	PGresult *ptr;
	bool open;
	int row;
};

#define con_t struct con_t
#define rs_t struct rs_t


/** module registration **/

/* open the library - used by require() */
LUALIB_API int luaopen_pgsql(lua_State *L);


/** exported functions **/

/* pg.connect - connect to a database */
LUALIB_API int L_connect(lua_State *L);


/** PgSQL.Connection object **/

/* con:escape - escape a string for use in queries */
LUALIB_API int L_con_escape(lua_State *L);
/* con:exec - execute a sql command, with or without parameters */
LUALIB_API int L_con_exec(lua_State *L);
/* con:notifywait - wait for any NOTIFY message from server */
LUALIB_API int L_con_notifywait(lua_State *L);
/* con:close - close the connection and free the client resources */
LUALIB_API int L_con_close(lua_State *L);
/* connection object garbage collector */
LUALIB_API int L_con_gc(lua_State *L);


/** PgSQL.Result object **/

/* rs:count - the number of rows returned OR affected by the sql command */
LUALIB_API int L_res_count(lua_State *L);
/* rs:fetch - tranditional 'fetch' interface */
LUALIB_API int L_res_fetch(lua_State *L);
/* rs:cols generator */
LUALIB_API int L_res_cols(lua_State *L);
/* rs:cols iterator */
LUALIB_API int L_res_col_iter (lua_State *L);
/* rs:rows generator */
LUALIB_API int L_res_rows(lua_State *L);
/* rs:rows iterator */
LUALIB_API int L_res_row_iter (lua_State *L);
/* rs:clear - free the result set */
LUALIB_API int L_res_clear(lua_State *L);
/* result object garbage collector */
LUALIB_API int L_res_gc(lua_State *L);
