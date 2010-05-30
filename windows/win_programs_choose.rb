class WinProgramsChoose
	def initialize(win_programs, program)
		@win_programs = win_programs
		@program = program
		
		@glade = GladeXML.new("glade/win_programs_choose.glade"){|handler|method(handler)}
		
		@glade["window"].title = @program["title"] + " - " + gettext("Choose command")
		
		@tv = @glade["tvCmds"]
		@tv.init(["ID", "Type", "Title"])
		
		@tv.columns[0].set_visible(false)
		@tv.columns[1].set_visible(false)
		updateCmds
		
		@glade["window"].show_all
	end
	
	def updateCmds
		@program["cmds"].each do |pair|
			@tv.append([pair[1]["id"], "cmd", pair[1]["title"]])
		end
		
		@program["schs"].each do |pair|
			@tv.append([pair[1]["id"], "sch", pair[1]["title"]])
		end
	end
	
	def on_tvCmds_row_activated
		sel = @tv.sel
		if sel and sel[0].to_i > 0
			if sel[1] == "cmd"
				$socket.send("execute:" + sel[0] + "\n", 0);
			elsif sel[1] == "sch"
				WinProgramsSearch.new("parent_window" => @glade["window"], "search" => sel, "program" => @program)
				@glade["window"].hide
			end
			
			@tv.unselect_all
		end
	end
	
	def on_btnBack_clicked
		@glade["window"].destroy
	end
	
	def on_window_destroy
		@win_programs.glade["window"].show
	end
end