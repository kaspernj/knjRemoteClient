class WinPrograms
	def glade
		return @glade
	end
	
	def initialize
		require "libglade2"
		@glade = GladeXML.new("glade/win_programs.glade"){|handler|method(handler)}
		
		require "knjrbfw/libknjgtk_tv.rb"
		@tv = @glade.get_widget("tvPrograms")
		
		gtk_tv_init(@tv, ["ID", "Title"]);
		@tv.columns[0].set_visible(false)
	end
	
	def show
		self.updatePrograms
		@glade.get_widget("window").show_all
	end
	
	def on_window_destroy
		Gtk::main_quit
	end
	
	def on_btnQuit_clicked
		@glade.get_widget("window").destroy
	end
	
	def on_tvPrograms_row_activated
		sel = gtk_tv_getsel(@tv)
		if (sel and sel[0].to_i > 0)
			program = $programs[sel[0]]
			require "windows/win_programs_choose.rb"
			win_programs_choose = WinProgramsChoose.new(self, program)
			
			@glade.get_widget("window").hide
		end
	end
	
	def updatePrograms
		$programs.each do |pair|
			gtk_tv_append(@tv, [pair[1]["id"], pair[1]["title"]])
		end
	end
end