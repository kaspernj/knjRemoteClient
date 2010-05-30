class WinConnect
	def initialize
		require "libglade2"
		@glade = GladeXML.new("glade/win_connect.glade"){|handler|method(handler)}
		@glade["window"].show_all
		
		str_server = Opts.get("default_server")
		str_port = Opts.get("default_port")
		
		@glade["txtServer"].text = str_server
		@glade["txtPort"].text = str_port
		
		$programs = {}
	end
	
	def on_btnConnect_clicked
		str_server = @glade["txtServer"].text
		str_port = @glade["txtPort"].text
		
		swindow = Gtk2::StatusWindow.new("transient_for" => @window)
		@win_programs = WinPrograms.new
		
		Thread.new do
			swindow.label = _("Connecting.")
			swindow.percent = 0.2
			
			begin
				$socket = TCPSocket.new(str_server, str_port)
			rescue => e
				puts e.inspect
				puts e.backtrace
				
				swindow.percent = 0
				swindow.label = _("Could not connect to server.")
				
				GLib::Timeout.add(2500) do
					print "Destroy\n"
					swindow.destroy
				end
				
				return nil
			end
			
			swindow.percent = 0.4
			swindow.label = _("Sending hello-message.")
			$socket.puts "Hello knjRemoteServer\n"
			
			swindow.percent = 0.6
			swindow.label = _("Getting settings from server.")
			
			begin
				while(line = readLine)
					len = line.length - 1
					line = line.slice(0, len)
					line_arr = line.split(":")
					
					if (line_arr[0] == "program")
						$programs[line_arr[1]] = {
							"id" => line_arr[1],
							"title" => line_arr[2],
							"cmds" => {},
							"schs" => {}
						}
						
						current_program_id = line_arr[1]
					elsif(line_arr[0] == "cmd")
						$programs[current_program_id]["cmds"][line_arr[1]] = {
							"id" => line_arr[1],
							"title" => line_arr[2],
							"type" => "cmd"
						}
					elsif(line_arr[0] == "sch")
						$programs[current_program_id]["schs"][line_arr[1]] = {
							"id" => line_arr[1],
							"title" => line_arr[2],
							"type" => "sch"
						}
					elsif(line == "endprogram")
						print "Ending program read\n"
						break
					end
				end
				
				@glade["window"].hide
				@win_programs.show
			rescue => e
				puts e.inspect
				puts e.backtrace
				
				swindow.percent = 0
				swindow.label = _("Could not get settings from the server.")
				
				GLib::Timeout.add(2500) do
					swindow.destroy
				end
				
				return nil
			end
			
			swindow.destroy
			@glade["window"].hide
		end
	end
	
	def on_btnQuit_clicked
		self.on_window_destroy
	end
	
	def on_window_destroy
		str_server = @glade["txtServer"].text
		str_port = @glade["txtPort"].text
		
		Opts.set("default_server", str_server)
		Opts.set("default_port", str_port)
		
		Gtk.main_quit
	end
end