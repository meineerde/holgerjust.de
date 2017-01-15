helpers do
  def figure(caption, figure_options = {}, caption_options = {}, &block)
    @_out_buf << content_tag(:figure, figure_options) do
      [
        markdown(&block),
        content_tag(:figcaption, markdown(caption, true), caption_options)
      ].inject(&:concat)
    end
  end

  def unicode_escape(str)
    str.unpack("U*").map { |c| "&##{c};"}.join
  end

  def markdown(source=nil, single_line = nil, &block)
    source = capture(&block) if block_given?
    html = Tilt['markdown'].new(markdown_options){ source.to_s }.render

    single_line = !source.to_s.include?("\n") if single_line.nil?
    if single_line
      doc = Nokogiri::HTML::DocumentFragment.parse(html)
      doc.search('p').each do |node|
        node.replace node.children
      end
      html = doc.to_html
    end

    html.strip
  end
end

###
# Markdown settings (early to use it in settings)
###

set :markdown_engine, :redcarpet
set :markdown_options, fenced_code_blocks: true, smartypants: true, footnotes: true, tables: true, with_toc_data: true, no_intra_emphasis: true
set :markdown, markdown_options
activate :syntax, line_numbers: true

###
# Blog settings
###

Time.zone = "UTC"

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  # blog.prefix = "blog"

  blog.permalink = "{year}/{title}.html"
  # Matcher for blog source files
  blog.sources = 'articles/{year}/{title}.html'
  blog.taglink = 'tag/{tag}.html'
  blog.layout = "layout"
  blog.summary_separator = /(READMORE)/
  blog.summary_length = 250
  blog.year_link = "{year}.html"
  blog.month_link = "{year}/{month}.html"
  blog.day_link = "{year}/{month}/{day}.html"
  blog.default_extension = ".md.erb"

  blog.tag_template = "tag.html"
  # blog.calendar_template = "calendar.html"

  # Enable pagination
  blog.paginate = true
  blog.per_page = 10
  blog.page_link = "page/{num}"

  blog.custom_collections = {
    author: {
      link: '/author/:author.html',
      template: '/author.html'
    }
  }
end

set :casper, {
  blog: {
    url: 'https://holgerjust.de',
    name: 'Everything is broken',
    description: 'Stories about Life and Technology',
    date_format: '%Y-%m-%d',
    navigation: true,
    default_license: 'cc_by_sa',
    author: 'Holger Just'
  },
  authors: [
    # When adding an author here, be sure to also create a matching author site
    # in source/partials/author
    {
      name: 'Holger Just',
      email: '&#104;&#101;&#108;&#108;&#111;&#64;&#104;&#111;&#108;&#103;&#101;&#114;&#106;&#117;&#115;&#116;&#46;&#100;&#101;',
      bio: markdown(<<-MARKDOWN.gsub(/^[ ]*/, ' ').strip),
        I spend most of my life pressing buttons on a computer to change its
        pattern of lights. I support the DevOps culture by creating,
        maintaining, and operating software systems. I want to understand the world.
      MARKDOWN
      location: 'Berlin, Germany',
      website: 'https://holgerjust.de',
      avatar_url: '//www.gravatar.com/avatar/b2c6828974b9192f619c6206d4d20f1d',
      twitter: 'meineerde',
      profile_links: {
        twitter: {
          name: 'Twitter',
          user: 'meineerde',
          link: 'https://twitter.com/meineerde'
        },
        instagram: {
          name: 'Instagram',
          user: 'holger_just',
          link: 'https://www.instagram.com/holger_just/'
        },
        github: {
          name: 'GitHub',
          user: 'meineerde',
          link: 'https://github.com/meineerde'
        },
        stackoverflow: {
          name: 'Stack Overflow',
          link: 'https://stackoverflow.com/users/421705/holger-just'
        },
        xing: {
          name: 'XING',
          link: 'https://www.xing.com/profile/Holger_Just'
        }
      }
    }
  ],
  navigation: {
    'Home' => ->{ url_for '/index.html' },
    'About Me' => ->{ author_path },
    'Contact' => -> { url_for '/impressum.html' }
  }
}

page '/feed.xml', layout: false
page '/sitemap.xml', layout: false

ignore '/partials/*'

# Ignore draft articles and their associated images
drafts_dir = File.expand_path('../source/drafts', __FILE__)
ignore '/drafts/*'
Dir["#{drafts_dir}/*/*"].each do |draft|
  draft_article = draft
    .sub(/\A#{Regexp.escape drafts_dir}\//, '')
    .sub(/\.[^\/]+\z/, '')
  ignore "/images/#{draft_article}/*"
end

ready do
  blog.tags.each do |tagname, articles|
    proxy "/tag/#{tagname.downcase.parameterize}/feed.xml", '/feed.xml', layout: false do
      @tagname = tagname
      @articles = articles
    end
  end

  proxy '/.htaccess', '/.htaccess.html', ignore: true
end

###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", layout: false
#
# With alternative layout
# page "/path/to/file.html", layout: :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
activate :automatic_image_sizes

# Reload the browser automatically whenever files change
activate :livereload

# Pretty URLs - http://middlemanapp.com/basics/pretty-urls/
activate :directory_indexes

# Middleman-Syntax - https://github.com/middleman/middleman-syntax
set :haml, {
  ugly: true,
  escape_attrs: :once
}

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'
set :partials_dir, 'partials'

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  activate :gzip

  # Enable cache buster
  activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end

activate :deploy do |deploy|
  deploy.method = :rsync
  deploy.host   = 'holgerjust.de'
  deploy.path   = '/var/www/virtual/holger/holgerjust.de'

  deploy.clean  = true # remove orphaned files on remote host
  deploy.flags  = '-az'

  # Build middleman before deploying
  deploy.build_before = true
end
