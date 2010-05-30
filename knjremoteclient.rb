#!/usr/bin/ruby

Dir.chdir(File.dirname(__FILE__))

require "gtk2"
require "knjrbfw/libknjgtk"
require "knjrbfw/libknjgtk_statuswindow"
require "knjrbfw/libknjos"
require "knjrbfw/libknjphpfuncs"



#Load config.
homedir = KnjOS.homedir
data_dir = homedir + "/.knj/knjremoteclient"
db_fn = homedir + "/.knj/knjremoteclient/knjremoteclient.sqlite3"

if (!File.exists?(data_dir))
	print "Making config-dir in home...\n"
	require "fileutils"
	FileUtils.mkdir_p(data_dir)
end

if (!File.exists?(db_fn))
	print "Making database in config-dir...\n"
	require "fileutils"
	FileUtils.copy("db/knjremoteclient.sqlite3", db_fn)
end


#Load database.
require "knjrbfw/knjdb/libknjdb.rb"
db = KnjDB.new({
	"type" => "sqlite3",
	"path" => db_fn
})


#Load options.
require "knjrbfw/libknjoptions.rb"
opt_setOpts({"knjdb" => db, "table" => "options"})


#Load language-module.
require "gettext"
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

require "windows/win_connect.rb"
win_connect = WinConnect.new

Gtk::main