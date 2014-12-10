module Helpers
    
    require 'date'
      
    TODAY = Date.today().strftime('%F')
    NOW = DateTime.now().strftime('%F %T')

    class PostPage
        attr_reader :title, :category, :origin_directory, :link_to_directory, :filename_nodate, :filename, :abs_filename

        def initialize args
            @title = args[:title]
            @category = args[:category]
            @origin_directory = args[:base_path] + '/_posts'
            @link_to_directory = args[:base_path] + '/_pages'
            
            @filename_nodate = sanitize_title + ".md"
            @filename = "#{TODAY}-#{filename_nodate}"
            @abs_filename = "#{origin_directory}/#{filename}"

            abort "The Post directory does not exist: #{origin_directory}" unless Dir.exists?( origin_directory )
        end

        def create
            if is_duplicate?
                abort "File #{abs_filename} already exists" 
            end

            create_with_seed
        end

        private
        def seed_content
            return <<-EOT.gsub /^\s*/, ''
            ---
            layout: page
            title: \"#{@title}\"
            category: #{@category}
            date: #{NOW}
            ---
            EOT
        end

        def is_duplicate?
            File.exists?(abs_filename)
        end

        def sanitize_title
            if title.nil?
                return ""
            end

            title.downcase.gsub(/[^a-z0-9\s]/, '').gsub(/\s+/, '-')
        end

        def create_with_seed
            File.open(abs_filename, 'w') do |file|
                file.puts seed_content
            end
        end

    end

    class Symlinker
        attr_reader :from_dir, :to_dir
        attr_accessor :current_file_name, :symlink_file_name

        def initialize page
            @from_dir = page.origin_directory
            @to_dir = page.link_to_directory

            # required if using create_symlink w/o link_all
            @current_file_name = page.filename
            @symlink_file_name = page.filename_nodate
        end

        def link_all
            truncate_destination_dir

            create_linked_dir

            Dir.foreach( from_dir ) do |filename|
                next if filename[0] == '.'

                # binding.pry
                create_symlinks( filename, sanitize(filename) )
            end
        end

        
        private
        def create_symlinks current_file_name, symlink_file_name
            from = "#{from_dir}/#{current_file_name}"
            to = "#{to_dir}/#{symlink_file_name}"

            delete_symlink( to ) 

            File.symlink( from, to ) 
        end

        def delete_symlink file
            File.delete( file ) if File.symlink?( file ) # will throw error if you try to overwrite a symlink       
        end

        def create_linked_dir
            Dir.mkdir(to_dir) unless Dir.exists? (to_dir)
        end

        def truncate_destination_dir
            Dir.glob(to_dir + '/*.md') {|md_file| File.delete( md_file ) }
        end

        def sanitize filename
            strip_date_from( filename )
        end

        def strip_date_from filename
            filename[/\d{4}-\d{2}-\d{2}-(?<part_to_keep>.*)/, 'part_to_keep']           
        end
    end

    class Editor
        attr_reader :abs_filename

        def initialize abs_filename
            @abs_filename = abs_filename

            open_document
        end

        def open_document
            abort 'No $EDITOR variable set' unless set?

            puts "opening in " + ENV['EDITOR'] + "..."
            exec("#{ENV['EDITOR']} #{abs_filename}")
        end

        private

        def set?
            ENV['EDITOR']
        end
    end

end
