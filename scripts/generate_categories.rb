require "yaml"
require "fileutils"

posts = Dir.glob("_posts/**/*.{md,markdown,html}")

categories = {}

posts.each do |file|
  next unless File.file?(file)

  content = File.read(file)
  parts = content.split("---")
  next if parts.length < 3

  data = YAML.safe_load(parts[1]) rescue nil
  next unless data && data["categories"] && data["title"]

  # Ambil permalink kalau ada
  if data["permalink"]
    post_url = data["permalink"]
  else
    # fallback: ambil nama file tanpa tanggal
    filename = File.basename(file)
    name = filename.sub(/\.(md|markdown|html)/, "")
    name = name.gsub(/^\d{4}-\d{2}-\d{2}-/, "")
    post_url = "/" + name + "/"
  end

  Array(data["categories"]).each do |cat|
    slug = cat.to_s.downcase.strip.gsub(" ", "-")

    categories[slug] ||= []
    categories[slug] << {
      "title" => data["title"],
      "url" => post_url
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
