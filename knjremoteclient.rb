#!/usr/bin/ruby

Dir.chdir(File.dirname(__FILE__))

require "knj/autoload"
require "knj/gtk2_tv"
include Knj

autoload :WinConnect, "windows/win_connect"
autoload :WinPrograms, "windows/win_programs"
autoload :WinProgramsSearch, "windows/win_programs_search"
autoload :WinProgramsChoose, "windows/win_programs_choose"

#Load config.
homedir = Os.homedir
data_dir = homedir + "/.knj/knjremoteclient"
db_fn = homedir + "/.knj/knjremoteclient/knjremoteclient.sqlite3"

if !File.exists?(data_dir)
	print "Making config-dir in home...\n"
	FileUtils.mkdir_p(data_dir)
end

if !File.exists?(db_fn)
	print "Making database in config-dir...\n"
	FileUtils.copy("db/knjremoteclient.sqlite3", db_fn)
end


#Load database.
db = Db.new(
	"type" => "sqlite3",
	"path" => db_fn
)


#Load options.
Opts.init("knjdb" => db, "table" => "options")


#Load language-module.
include GetText
bindtextdomain("locale", "locale")


$tempstring = ""
def readLine
	while(true)
		tha_char = $socket.recv(1)
		
		$tempstring += tha_char
		pos = $tempstring.index("\n")
		
		if (tha_char == "\n")
			tha_line = $tempstring
			$tempstring = ""
			
			return tha_line
		end
	end
end

win_connect = WinConnect.new
Gtk.main