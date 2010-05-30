class WinPrograms
	def glade
		return @glade
	end
	
	def initialize
		@glade = GladeXML.new("glade/win_programs.glade"){|handler|method(handler)}
		
		@tv = @glade["tvPrograms"]
		@tv.init(["ID", "Title"])
		@tv.columns[0].set_visible(false)
	end
	
	def show
		self.updatePrograms
		@glade["window"].show_all
	end
	
	def on_window_destroy
		Gtk.main_quit
	end
	
	def on_btnQuit_clicked
		@glade["window"].destroy
	end
	
	def on_tvPrograms_row_activated
		sel = @tv.sel
		if sel and sel[0].to_i > 0
			program = $programs[sel[0]]
			win_programs_choose = WinProgramsChoose.new(self, program)
			@glade["window"].hide
		end
	end
	
	def updatePrograms
		$programs.each do |pair|
			@tv.append([pair[1]["id"], pair[1]["title"]])
		end
	end
end