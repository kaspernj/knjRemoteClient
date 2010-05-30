class WinProgramsChoose
	def initialize(win_programs, program)
		@win_programs = win_programs
		@program = program
		
		@glade = GladeXML.new("glade/win_programs_choose.glade"){|handler|method(handler)}
		@window = @glade.get_widget("window")
		
		@window.title = @program["title"] + " - " + gettext("Choose command")
		
		@tv = @glade.get_widget("tvCmds")
		gtk_tv_init(@tv, ["ID", "Type", "Title"])
		
		@tv.columns[0].set_visible(false)
		@tv.columns[1].set_visible(false)
		self.updateCmds
		
		
		@window.show_all
	end
	
	def updateCmds
		@program["cmds"].each do |pair|
			gtk_tv_append(@tv, [pair[1]["id"], "cmd", pair[1]["title"]])
		end
		
		@program["schs"].each do |pair|
			gtk_tv_append(@tv, [pair[1]["id"], "sch", pair[1]["title"]])
		end
	end
	
	def on_tvCmds_row_activated
		sel = gtk_tv_getsel(@tv)
		if sel and sel[0].to_i > 0
			if sel[1] == "cmd"
				$socket.send("execute:" + sel[0] + "\n", 0);
			elsif sel[1] == "sch"
				require "windows/win_programs_search.rb"
				WinProgramsSearch.new({"parent_window" => @window, "search" => sel, "program" => @program})
				@window.hide
			end
			
			@tv.unselect_all
		end
	end
	
	def on_btnBack_clicked
		@glade.get_widget("window").destroy
	end
	
	def on_window_destroy
		@win_programs.glade.get_widget("window").show
	end
end