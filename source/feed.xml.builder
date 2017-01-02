@articles ||= blog.articles
title = settings.casper[:blog][:name]
subtitle = settings.casper[:blog][:description]

xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  site_url = settings.casper[:blog][:url]
  xml.title @tagname.present? ? "#{title}: #{@tagname}" : title
  xml.subtitle @tagname.present? ? "Posts tagged with #{@tagname}" : subtitle
  xml.id URI.join(site_url, blog.options.prefix.to_s)
  xml.link "href" => URI.join(site_url, blog.options.prefix.to_s)
  xml.link "href" => URI.join(site_url, current_page.path), "rel" => "self"
  xml.updated @articles.first.date.to_time.iso8601 unless @articles.empty?
  xml.author { xml.name blog_author.name }

  @articles[0..9].each do |article|
    tagline = "<p>The post <a href=\"#{h URI.join(site_url, article.url)}\">#{h article.title}</a> appeared first on <a href=\"#{h settings.casper[:blog][:url]}\">#{h settings.casper[:blog][:url].sub(%r{^https?://}, '')}</a>.</p>".html_safe

    xml.entry do
      xml.title article.title
      xml.link "rel" => "alternate", "href" => URI.join(site_url, article.url)
      xml.id URI.join(site_url, article.url)
      xml.published article.date.to_time.iso8601
      xml.updated File.mtime(article.source_file).iso8601
      xml.author { xml.name blog_author(article.data.author).name }
      xml.summary summary(article), "type" => "html"
      xml.content article.body + tagline, "type" => "html"
    end
  end
end
