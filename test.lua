package.cpath = "./?.so"
require("pgsql")

db = {
	dbname = "postgres",
	user = "pgsql",
	connect_timeout = 5
}

print("\nRunning tests...")

passed = true

if passed then 
	print("--connect")
	local info = ''
	-- we shall move this next line to C soon...
	for k, v in pairs(db) do info = string.format("%s%s=%s ", info, tostring(k), tostring(v)) end
	con, errmsg = pg.connect(string.format(info))
	if not con then
		print(errmsg)
		passed = false
	else
		print(string.format("con = %s", tostring(con)))
	end
end

if passed then 
	print("--string escape")
	s = "The quick brown fox's hide"
	print(string.format("%s = %s", s, con:escape(s)))
	if con:escape(s) ~= "The quick brown fox''s hide" then passed = false end
end

if passed then 
	print("--sql error")
	local rs, errmsg = con:exec("select * from test where val1 = 1")
	if not rs then
		print(errmsg)
	else
		passed = false
		print(string.format("rs = %s, %d rows affected", tostring(rs), rs:count()))
	end
end

if passed then 
	print("--sql type conversion")
	local rs, errmsg = con:exec("select null::varchar as \"null\", 't'::bool, 2::int2, 4::int4, 8::int8, 4.4::float4, 8.8::float8, '1970-01-01'::date")
	if not rs then
		print(errmsg)
		passed = false
	else
		data = rs:fetch()
		if data then 
			print(string.format("[null](%s) = %s", type(data.null), tostring(data.null)))
			for k, v in pairs(data) do
				if type(k) == 'string' then
					print(string.format("[%s](%s) = %s", k, type(v), tostring(v)))
				end
			end
		else
			print("no data!")
			passed = false
		end
	end
	rs:clear()
end

q = [[ 
create temp table test (
	val1 int primary key,
	val2 varchar
)
]]

if passed then 
	print("--sql create")
	local rs, errmsg = con:exec(q)
	if not rs then
		print(errmsg)
		passed = false
	else
		print(string.format("rs = %s", tostring(rs)))
	end
	rs:clear()
end

if passed then 
	print("--sql insert")
	for i = 1, 3 do
		local rs, errmsg = con:exec("insert into test (val1, val2) values ($1, $2)", {i, string.char(64 + i)})
		if not rs then
			print(errmsg)
			passed = false
		else
			print(string.format("rs = %s, %d rows affected", tostring(rs), rs:count()))
		end
		rs:clear()
	end
end

if passed then 
	print("--sql update")
	for i = 1, 3 do
		local rs, errmsg = con:exec(string.format("update test set val2 = val2 || '*' where val1 = %d", i))
		if not rs then
			print(errmsg)
			passed = false
		else
			print(string.format("rs = %s, %d rows affected", tostring(rs), rs:count()))
		end
		rs:clear()
	end
end

if passed then 
	print("--sql select")
	rs, errmsg = con:exec("select * from test")
	if not rs then
		print(errmsg)
		passed = false
	else
		print(string.format("rs = %s, %d rows found", tostring(rs), rs:count()))
	end
end

if passed then 
	print("--result fetch")
	local data = rs:fetch()
	while data do
		print(string.format("%s, %s", data.val1, data.val2))
		data = rs:fetch()
	end
end

if passed then 
	print("--sql select (using params)")
	rs, errmsg = con:exec("select * from test where val1 >= $1 and val2 >= $2", {0, 'A'})
	if not rs then
		print(errmsg)
		passed = false
	else
		print(string.format("rs = %s, %d rows found", tostring(rs), rs:count()))
	end
end

if passed then 
	print("--sql insert & select (using params with nulls)")
	local rs, errmsg = con:exec("insert into test (val1, val2) values ($1, $2)", {4, nil}, 2)
	if not rs then
		print(errmsg)
		passed = false
	else
		local rs, errmsg = con:exec("select * from test where val1 >= $1 and val2 is null", {0})
		if not rs then
			print(errmsg)
			passed = false
		else
			print(string.format("rs = %s, %d rows found", tostring(rs), rs:count()))
		end
	end
end

if passed then 
	print("--column iterator")
	local h = ''
	for index, name in rs:cols() do
		h = h .. string.format("[%d]%s, ", index, name)
	end
	print(h)
	print("--row iterator by index")
	for data in rs:rows() do 
		-- column access by index
		local s = ''
		for i, v in ipairs(data) do
			s = s .. string.format("[%d]%s, ", i, v)
		end
		print(s)
		-- column access by name
		print(string.format("%d, %s", data.val1, data.val2))
	end
end

if passed then print('All tests passed!') end
