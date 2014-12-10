require "./lib/helpers"
require 'thor'

class Page < Thor
	include Helpers

	desc "new TITLE CATEGORY", "Create a new page and symlink to _pages"
	 method_option :edit, :aliases => "-e", :desc => "Edit the page you're creating"
	 method_option :path, :aliases => "-p", :desc => "Provide the path to the project root"
	def new(title, category)

		args = {
			edit: options[:edit],
			base_path: options[:path] || Dir.pwd,
			title: title,
			category: category
		}

		page = PostPage.new(args)
		page.create
		
		Symlinker.new( page ).link_all

		puts "success!"

		if args[:edit]
			Editor.new(page.abs_filename) 
		end

	end


	desc "relink", "Regenerate all the symlinks from posts to pages & clear broken symlinks"
	 method_option :path, :aliases => "-p", :desc => "Provide the path to the project root"
	def relink

		arg = { base_path: options[:path] || Dir.pwd }

		pages = PostPage.new( arg )

		Symlinker.new( pages ).link_all

		puts "success!"

	end

	# default_task :new
end