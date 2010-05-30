class WinProgramsSearch
	def initialize(paras)
		@paras = paras
		
		@gui = Gtk::Builder.new
		@gui.add("glade/win_programs_search.ui")
		@gui.connect_signals(){|handler|method(handler)}
		
		@window = @gui.get_object("window")
		@window.title = @paras["program"]["title"] + " - " + gettext("Search")
		
		@tv = @gui.get_object("tvResults")
		require "knjrbfw/libknjgtk_tv"
		gtk_tv_init(@tv, ["ID", "Title"])
		@tv.columns[0].visible = false
		
		@window.show_all
	end
	
	def on_window_destroy
		if @paras["parent_window"]
			@paras["parent_window"].show
		end
		
		@gui = nil
		@window = nil
		@paras = nil
	end
	
	def on_btnQuit_clicked
		@window.destroy
	end
	
	def on_txtSearch_changed
		doSearch(false)
	end
	
	def on_btnSearchForce_clicked
		doSearch(true)
	end
	
	def doSearch(force)
		text = @gui.get_object("txtSearch").text.gsub(":", "")
		@tv.model.clear
		
		if (!force and text.strip.length < 4)
			return nil
		end
		
		$socket.puts("search:" + @paras["search"][0] + ":" + text + "\n")
		while true
			line = readLine
			linearr = line.strip.split(":")
			
			if line == "endresults\n"
				break
			elsif(linearr[0] == "result")
				gtk_tv_append(@tv, [linearr[1], linearr[2]])
			end
		end
	end
	
	def on_btnExecute_clicked
		sel = gtk_tv_getsel(@tv)
		if (sel)
			$socket.puts("search_execute:" + @paras["search"][0] + ":" + sel[0] + "\n")
		end
	end
end