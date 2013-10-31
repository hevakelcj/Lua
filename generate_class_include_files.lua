#!/usr/bin/env lua

-------------------------------------------------------------------------------
-- this LUA script is aim to generate include shutcut file in ./inc/
-- First, it will find all *.h and *.hpp files in current path. Then, find out 
-- all class which defined in head file. Next, build a file in ./inc/ which be 
-- named with class name. Last, write "#include "./<headfile>"" into that file.
-- auth : Chunjun Li <hevakelcj@gmail.com>
-- date : 2013-10-02
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- get_class_list_in_file
-- \berif find all class which is defined in head file, and return class name 
--        table.
-------------------------------------------------------------------------------
function get_class_list_in_file(file_name)
    local class_list = {}
    local headfile = assert(io.open(file_name, "r"))
    while true do
        local line = headfile:read("*line") 
        if line == nil then break end
        if string.find(line, "^class%s+") then
            if not string.find(line, "^class%s+%a[%w_]*%s*;$") then
                local _, _, class_name = string.find(line, "^class%s+(%a[%w_]*)")
                if class_name then
                    table.insert(class_list, class_name)
                end
            end
        end
    end
    headfile:close()
    return class_list
end

-------------------------------------------------------------------------------
-- build_class_include_file
-- \berif build a file in ./inc/ and named as class name. then write C include 
--        statent inside.
-------------------------------------------------------------------------------
function build_class_include_file(class_name, file_name)
    local context = "#include \"../" .. file_name .. "\"\n"
    local outfile = assert(io.open("inc/" .. class_name, "a"))
    outfile:write(context)
    outfile:close()
end

-------------------------------------------------------------------------------
-- do_file
-- \berif find classes and build class include files in ./inc/
-------------------------------------------------------------------------------
function do_file(file_name)
    class_list = get_class_list_in_file(file_name)
    for _, class_name in pairs(class_list) do
        build_class_include_file(class_name, file_name)
        print(class_name .. " --> " .. file_name)
    end
end

-------------------------------------------------------------------------------
-- scan_head_files
-- \berif find all head file and run do_file() each
-------------------------------------------------------------------------------
function scan_head_files(path)
    local tmp_file_name = "head_file_list.tmp"
    local find_cmd = "find " .. path .. " -type f -name \"*.h\" -or -name \"*.hpp\" > " .. tmp_file_name

    os.execute "rm -rf ./inc"
    os.execute "mkdir ./inc"

    os.execute(find_cmd)
    local file = assert(io.open(tmp_file_name, "r"))
    while true do 
        local line = file:read("*line")
        if line == nil then break end
        do_file(line)
    end
    file:close()
    os.remove(tmp_file_name)
end

scan_head_files("./")
