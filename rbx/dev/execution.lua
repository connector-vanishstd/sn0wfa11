local l_blocked, blocked = {
	".exe", ".bat", ".com", ".cmd", ".inf", ".run", ".wsh",
	".app", ".vb", ".vbs", ".scr", ".fap", ".cpl", ".inf1", ".ins",
	".inx", ".isu", ".job", ".lnk", ".msi", ".ps1", ".psd1", ".reg", ".vbe", ".js",
	".x86", ".pif", ".xlm", ".scpt", ".out", ".ba_", ".jar", ".ahk", ".xbe",
	".0xe", ".u3p", ".bms", ".jse", ".ex", ".osx", ".rar", ".zip",
	".7z", ".py", ".cpp", ".cs", ".prx", ".tar", ".wim", ".htm", ".appimage",
	".applescript", ".x86_64", ".x64_64", ".autorun", ".sys", ".ini", ".pol",
	".vbscript", ".gadget", ".workflow", ".script", ".action", ".command", ".arscript",
	".psc1", ".pyw", ".dll", ".pyc", ".msc", ".wsf", ".hta", ".scf", ".cab", ".iso", ".img", ".msp", ".url", ".xml"
}, {}

for _, ext in ipairs(l_blocked) do
	blocked[string.lower(ext)] = true
end

local writefile_o = writefile

function writefile_n(path, content) -- This is checked on the server but lets check on the client aswell
	assert(type(path) == "string", "invalid argument #1 to 'writefile' (string expected, got " .. type(path) .. ") ")
	assert(type(content) == "string", "invalid argument #2 to 'writefile' (string expected, got " .. type(content) .. ") ")
	local badExt;
	do
		local pStr = path:lower():gsub('\0', '')
		local filename = pStr:match("([^\\/]+)$") or pStr
		for token in filename:gmatch("%.[%w_%-]+") do
			if blocked[token] then
				badExt = token
				break
			end
		end
	end
	if badExt then
		error(`extension \"{badExt}\" is not allowed in path \"{path}\"`)
		return
	end
	return writefile_o(path, content)
end

getgenv().writefile = writefile_n

local request_o = request

function request_n(options)
	if type(options) ~= "table" then
		return request_o(options)
	end
	do
		local url = options.Url
		if type(url) ~= "string" then
			return request_o(options)
		end
		if url:lower():find("localhost:3110") then
			error("Not allowed to send request to sn0w server")
			return
		end
	end
	local response = request_o(options)
	do
		local statusCode = tonumber(response.StatusCode) or 400
		response.Success = statusCode >= 200 and statusCode < 300
	end
	return response
end

getgenv().request = request_n
getgenv().http_request = request_n
getgenv().http.request = request_n

local o_saveinstance = saveinstance

function saveinstance_n(options)
	options = options or {}
	assert(type(options) == "table", "invalid argument #1 to 'saveinstance' (table expected, got " .. type(options) .. ") ", 3)

	options.SafeMode = options.SafeMode or false

	return o_saveinstance(options)
end

getgenv().saveinstance = saveinstance_n

local o_setfpscap = setfpscap

function setfpscap_n(fps)
	if fps <= 0 then
		fps = math.huge
	end
	return o_setfpscap(fps)
end

getgenv().setfpscap = setfpscap_n
