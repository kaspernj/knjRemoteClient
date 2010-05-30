class WinConnect
	def initialize
		require "libglade2"
		@glade = GladeXML.new("glade/win_connect.glade"){|handler|method(handler)}
		@glade.get_widget("window").show_all
		
		str_server = opt_get("default_server")
		str_port = opt_get("default_port")
		
		@glade.get_widget("txtServer").set_text(str_server)
		@glade.get_widget("txtPort").set_text(str_port)
		
		@window = @glade.get_widget("window")
		
		$programs = {}
	end
	
	def on_btnConnect_clicked
		str_server = @glade.get_widget("txtServer").text
		str_port = @glade.get_widget("txtPort").text
		
		require "socket"
		swindow = KnjStatusWindow.new({"transient_for" => @window})
		
		require "windows/win_programs.rb"
		@win_programs = WinPrograms.new
		
		Thread.new do
			swindow.label = gettext("Connecting.")
			swindow.percent = 0.2
			
			begin
				$socket = TCPSocket.new(str_server, str_port)
			rescue => e
				puts e.inspect
				puts e.backtrace
				
				swindow.percent = 0
				swindow.label = gettext("Could not connect to server.")
				
				GLib::Timeout.add(2500) do
					print "Destroy\n"
					swindow.destroy
				end
				
				return nil
			end
			
			swindow.percent = 0.4
			swindow.label = gettext("Sending hello-message.")
			$socket.puts "Hello knjRemoteServer\n"
			
			swindow.percent = 0.6
			swindow.label = gettext("Getting settings from server.")
			
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
				
				@glade.get_widget("window").hide
				@win_programs.show
			rescue => e
				puts e.inspect
				puts e.backtrace
				
				swindow.percent = 0
				swindow.label = gettext("Could not get settings from the server.")
				
				GLib::Timeout.add(2500) do
					swindow.destroy
				end
				
				return nil
			end
			
			swindow.destroy
			@window.hide
		end
	end
	
	def on_btnQuit_clicked
		self.on_window_destroy
	end
	
	def on_window_destroy
		str_server = @glade.get_widget("txtServer").text
		str_port = @glade.get_widget("txtPort").text
		
		opt_set("default_server", str_server)
		opt_set("default_port", str_port)
		
		Gtk::main_quit
	end
end