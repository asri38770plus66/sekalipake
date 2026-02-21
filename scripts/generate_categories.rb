require "yaml"
require "fileutils"

posts = Dir.glob("_posts/**/*.{md,markdown,html}")

categories = {}

posts.each do |file|
  next unless File.file?(file)

  content = File.read(file)
  parts = content.split("---")
  next if parts.length < 3

  data = YAML.safe_load(parts[1])
  next unless data && data["categories"]

  Array(data["categories"]).each do |cat|
    slug = cat.downcase.strip.gsub(" ", "-")

    categories[slug] ||= []
    categories[slug] << {
      "title" => data["title"],
      "url" => "/" + File.basename(file)
        .sub(".md", "")
        .sub(".markdown", "")
        .sub(".html", "")
        .split("-", 4)[3]
    }
  end
end

# hapus folder lama
FileUtils.rm_rf("categories")
FileUtils.mkdir_p("categories")

categories.each do |slug, posts|
  dir = "categories/#{slug}"
  FileUtils.mkdir_p(dir)

  File.open("#{dir}/index.html", "w") do |f|
    f.puts "<!DOCTYPE html>"
    f.puts "<html><head>"
    f.puts "<meta charset='utf-8'>"
    f.puts "<title>Category: #{slug}</title>"
    f.puts "</head><body>"
    f.puts "<h1>Category: #{slug}</h1>"
    f.puts "<ul>"

    posts.each do |post|
      f.puts "<li><a href='#{post["url"]}'>#{post["title"]}</a></li>"
    end

    f.puts "</ul>"
    f.puts "</body></html>"
  end
end
