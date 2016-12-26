namespace :doggohub do
  namespace :import_export do
    desc "DoggoHub | Show Import/Export version"
    task version: :environment do
      puts "Import/Export v#{Gitlab::ImportExport.version}"
    end

    desc "DoggoHub | Display exported DB structure"
    task data: :environment do
      puts YAML.load_file(Gitlab::ImportExport.config_file)['project_tree'].to_yaml(:SortKeys => true)
    end
  end
end
