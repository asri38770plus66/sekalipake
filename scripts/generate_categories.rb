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
    f.puts "---"
    f.puts "layout: null"
    f.puts "---"
    f.puts "<!DOCTYPE html><html lang="en" loading="lazy"><head loading="lazy"><meta charset="UTF-8" />""
    f.puts "<title>#{slug}</title>"
    f.puts "{%  head-categories.html %}</head><body loading="lazy">{% include header1.html %}<main loading="lazy">{% include main-categories.html %}</main>{% include awal-search.html %}<br /><br /><div loading="lazy">{% include /ads/gobloggugel/sosmed.html %}</div>{% include footer-categories.html %}</body></html>"
  end
end
