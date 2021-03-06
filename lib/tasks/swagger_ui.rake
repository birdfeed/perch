require 'fileutils'

namespace :swagger_ui do

	task :clone_repo do 
		p "Fetching birdfeed/swagger_ui"
		unless system "git clone https://github.com/birdfeed/swagger-ui"
			abort "Something went wrong"
		end
	end

	task :fetch_schema do
		p "Fetching latest schema from birdfeed/api-schema"
		unless system "git clone https://github.com/birdfeed/api-schema"
			abort "Something went wrong"
		end

		p "Placing in public"
		FileUtils.mv("#{Rails.root}/api-schema/swagger.json", "#{Rails.root}/public/swagger.json")
		p "Deleting api-schema directory"
		FileUtils.rm_rf("#{Rails.root}/api-schema")
	end

	task :install_deps do
		Dir.chdir('./swagger-ui') do 
			p "Installing dependencies from npm"
			system "npm install"
		end
	end

	task :gulp_to_public do 
		Dir.chdir('./swagger-ui') do 
			unless system "gulp"
				system "npm install -g gulp"
				system "gulp"
			end
		end
	end

	task :cleanup do 
		Dir.chdir(Rails.root) do 
			FileUtils.rm_rf("#{Rails.root}/public/docs") if Dir.exist?("#{Rails.root}/public/docs")
			FileUtils.rm_rf("#{Rails.root}/swagger-ui") if Dir.exist?("#{Rails.root}/swagger-ui")
		end
	end

	task :build => [:cleanup, :clone_repo, :fetch_schema, :install_deps, :gulp_to_public] do 
		p "Docs deployed to public assets directory"
	end
end